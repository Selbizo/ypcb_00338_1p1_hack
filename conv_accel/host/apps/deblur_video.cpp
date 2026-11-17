// Video deblurring: per-frame motion (GFTT + LK + estimateAffine2D), then the
// selected deblur backend.  Mirrors the motion extraction of the OpenCL example.
#include "deblur/deblur.h"

#include <opencv2/calib3d.hpp>
#include <opencv2/core.hpp>
#include <opencv2/features2d.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/video/tracking.hpp>
#include <opencv2/videoio.hpp>

#include <cmath>
#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>

namespace {

deblur::Backend parse_backend(const std::string& s) {
    if (s == "auto")   return deblur::Backend::Auto;
    if (s == "cpu")    return deblur::Backend::CPU;
    if (s == "opencl") return deblur::Backend::OpenCL;
    if (s == "cuda")   return deblur::Backend::CUDA;
    if (s == "fpga")   return deblur::Backend::FPGA;
    throw std::runtime_error("unknown backend: " + s);
}

bool parse_fixed(const std::string& s, float& dx, float& dy, float& da) {
    return std::sscanf(s.c_str(), "%f,%f,%f", &dx, &dy, &da) == 3;
}

}  // namespace

int main(int argc, char** argv) {
    std::string in, out, backend = "auto", fixed;
    int max_frames = 0;
    bool display = false;
    float exposure = 0.5f, nsr = 0.01f;

    for (int i = 1; i < argc; ++i) {
        const std::string a = argv[i];
        auto next = [&]() -> std::string {
            if (++i >= argc) { std::cerr << "missing value for " << a << "\n"; std::exit(1); }
            return argv[i];
        };
        if (a == "--in")            in = next();
        else if (a == "--out")      out = next();
        else if (a == "--backend")  backend = next();
        else if (a == "--exposure") exposure = std::stof(next());
        else if (a == "--nsr")      nsr = std::stof(next());
        else if (a == "--fixed")    fixed = next();
        else if (a == "--max-frames") max_frames = std::stoi(next());
        else if (a == "--display")  display = true;
        else if (a == "-h" || a == "--help") {
            std::cout << "usage: deblur_video --in VID [--out VID] [--backend ...]\n"
                         "                     [--exposure 0.5] [--nsr 0.01] [--fixed dx,dy,da]\n"
                         "                     [--max-frames N] [--display]\n";
            return 0;
        } else { std::cerr << "unknown option: " << a << "\n"; return 1; }
    }
    if (in.empty()) { std::cerr << "usage: deblur_video --in VID [options]\n"; return 1; }

    cv::VideoCapture cap(in);
    if (!cap.isOpened()) { std::cerr << "cannot open " << in << "\n"; return 1; }
    const double fps = cap.get(cv::CAP_PROP_FPS) > 1.0 ? cap.get(cv::CAP_PROP_FPS) : 30.0;

    cv::VideoWriter wr;
    if (!out.empty()) {
        wr.open(out, cv::VideoWriter::fourcc('m', 'p', '4', 'v'), fps,
                cv::Size(static_cast<int>(cap.get(cv::CAP_PROP_FRAME_WIDTH)),
                         static_cast<int>(cap.get(cv::CAP_PROP_FRAME_HEIGHT))));
        if (!wr.isOpened()) { std::cerr << "cannot write " << out << "\n"; return 1; }
    }

    float fdx = 0, fdy = 0, fda = 0;
    const bool use_fixed = !fixed.empty() && parse_fixed(fixed, fdx, fdy, fda);

    auto eng = deblur::Engine::create(parse_backend(backend));
    std::cout << "backend=" << eng->name() << "  video=" << in << "\n";

    auto det = cv::GFTTDetector::create(200, 0.005, 7.0, 9, true, 0.005);
    const auto lk = cv::TermCriteria(cv::TermCriteria::COUNT | cv::TermCriteria::EPS, 10, 0.03);
    cv::Mat prev_gray;
    std::vector<cv::Point2f> p0;
    int frame_no = 0, used = 0;

    cv::Mat frame;
    while (cap.read(frame)) {
        if (max_frames > 0 && frame_no >= max_frames) break;

        cv::Mat gray;
        cv::cvtColor(frame, gray, cv::COLOR_BGR2GRAY);

        deblur::MotionParams p;
        p.exposure = exposure;
        p.nsr = nsr;

        if (use_fixed) {
            p.dx = fdx; p.dy = fdy; p.dalpha = fda;
        } else if (!prev_gray.empty() && p0.size() >= 6) {
            std::vector<cv::Point2f> p1;
            std::vector<uchar> st;
            std::vector<float> err;
            cv::calcOpticalFlowPyrLK(prev_gray, gray, p0, p1, st, err,
                                     cv::Size(9, 9), 5, lk);
            std::vector<cv::Point2f> g0, g1;
            for (size_t i = 0; i < st.size(); ++i)
                if (st[i]) { g0.push_back(p0[i]); g1.push_back(p1[i]); }
            if (g0.size() >= 6) {
                cv::Mat T = cv::estimateAffine2D(g0, g1, cv::noArray(),
                                                 cv::RANSAC, 3.0);
                if (!T.empty()) {
                    p.dx = static_cast<float>(T.at<double>(0, 2));
                    p.dy = static_cast<float>(T.at<double>(1, 2));
                    p.dalpha = static_cast<float>(std::atan2(T.at<double>(1, 0),
                                                            T.at<double>(0, 0)));
                    ++used;
                }
                p0.swap(g1);
            } else {
                std::vector<cv::KeyPoint> kp;
                det->detect(gray, kp);
                p0.clear();
                for (const auto& k : kp) p0.push_back(k.pt);
            }
        } else {
            std::vector<cv::KeyPoint> kp;
            det->detect(gray, kp);
            p0.clear();
            for (const auto& k : kp) p0.push_back(k.pt);
        }

        cv::Mat dst;
        eng->process(frame, dst, p);
        if (wr.isOpened()) wr.write(dst);

        if (display) {
            cv::Mat side;
            cv::hconcat(frame, dst, side);
            cv::imshow("source | deblurred", side);
            if (cv::waitKey(1) == 27) break;
        }

        prev_gray = gray;
        ++frame_no;
    }

    std::cout << "frames=" << frame_no << "  motion_ok=" << used << "\n";
    return 0;
}
