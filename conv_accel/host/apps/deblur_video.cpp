// Video deblurring: per-frame motion (GFTT + LK + estimateAffine2D), then the
// selected deblur backend.  Mirrors the motion extraction of the OpenCL example.
#include "deblur/deblur.h"

#include <opencv2/calib3d.hpp>
#include <opencv2/core.hpp>
#include <opencv2/features2d.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/video/tracking.hpp>
#include <opencv2/videoio.hpp>

#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iomanip>
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

// ---------------------------------------------------------------------------
// PSF debug dump (visualisation only, does not affect the filtered output).
//
// The backends never build a spatial kernel: they evaluate the analytic sinc
// OTF.  For debugging we materialise the PSF that the trajectory model used by
// the engines implies, at every block centre:
//
//     s(u) = u*T + (R(u*Phi) - I)*(p - c),   u in [0, 1]
//
// and splat it into a block-sized kernel, normalised to sum 1.  The kernel is
// fftshifted for display, i.e. the same "build PSF -> normalise -> fftshift"
// sequence as GcalcPSF()/Gfftshift() in
// just_for_reference/prj_1/src/filters/wiener_filter.cpp.  With rotation the
// result is the actual arc, not the straight-line approximation used by the
// OTF, so the picture shows the real PSF shape.
// ---------------------------------------------------------------------------

constexpr int kPsfBlock   = 256;  // must match the backend block size
constexpr int kPsfHop     = 128;  // must match the backend hop
constexpr int kPsfSamples = 256;
constexpr int kPsfTile    = 96;   // display tile size, px

// Bilinear splat of one (sub-pixel) displacement into a wrapped B x B kernel.
inline void psf_splat(cv::Mat& k, float sx, float sy, float w) {
    const int n = k.rows;
    const int x0 = static_cast<int>(std::floor(sx));
    const int y0 = static_cast<int>(std::floor(sy));
    const float fx = sx - static_cast<float>(x0);
    const float fy = sy - static_cast<float>(y0);
    const float wx[2] = {1.0f - fx, fx};
    const float wy[2] = {1.0f - fy, fy};
    for (int j = 0; j < 2; ++j) {
        for (int i = 0; i < 2; ++i) {
            int x = (x0 + i) % n;
            int y = (y0 + j) % n;
            if (x < 0) x += n;
            if (y < 0) y += n;
            k.at<float>(y, x) += w * wx[i] * wy[j];
        }
    }
}

// Move the origin (u = 0) to the centre, like the reference Gfftshift().
void psf_fftshift(const cv::Mat& src, cv::Mat& dst) {
    dst = src.clone();
    const int cx = dst.cols / 2, cy = dst.rows / 2;
    cv::Mat q0(dst, cv::Rect(0, 0, cx, cy));
    cv::Mat q1(dst, cv::Rect(cx, 0, cx, cy));
    cv::Mat q2(dst, cv::Rect(0, cy, cx, cy));
    cv::Mat q3(dst, cv::Rect(cx, cy, cx, cy));
    cv::Mat tmp;
    q0.copyTo(tmp); q3.copyTo(q0); tmp.copyTo(q3);
    q1.copyTo(tmp); q2.copyTo(q1); tmp.copyTo(q2);
}

void psf_print_ascii(const cv::Mat& tile8, int vx, int vy, float L, float theta_deg) {
    const int aw = 41, ah = 19;
    cv::Mat small;
    cv::resize(tile8, small, cv::Size(aw, ah), 0, 0, cv::INTER_AREA);
    double peak = 0.0;
    cv::minMaxLoc(small, nullptr, &peak);
    if (peak <= 0.0) peak = 1.0;

    static const char ramp[] = " .:-=+*#%@";
    std::cout << "[psf] centre block (" << vx << "," << vy << ")  L=" << L
              << " px  theta=" << theta_deg << " deg\n";
    for (int y = 0; y < ah; ++y) {
        std::cout << "      ";
        for (int x = 0; x < aw; ++x) {
            const int v = static_cast<int>(9.0 * small.at<uchar>(y, x) / peak + 0.5);
            std::cout << ramp[std::clamp(v, 0, 9)];
        }
        std::cout << "\n";
    }
}

void dump_psf_frame(const std::string& dir, int frame_no,
                    const deblur::MotionParams& p, int W, int H) {
    if (W < kPsfBlock || H < kPsfBlock) return;  // engines reject these too

    // Same tile grid as the CPU/OpenCL/CUDA backends.
    std::vector<int> vys, vxs;
    for (int vy = 0; vy <= H - kPsfHop; vy += kPsfHop) vys.push_back(vy);
    if ((H - kPsfHop) % kPsfHop) vys.push_back(H - kPsfHop);
    for (int vx = 0; vx <= W - kPsfHop; vx += kPsfHop) vxs.push_back(vx);
    if ((W - kPsfHop) % kPsfHop) vxs.push_back(W - kPsfHop);

    const int rows = static_cast<int>(vys.size());
    const int cols = static_cast<int>(vxs.size());
    const int pad = 2, lab = 26, hdr = 24;
    const int cw = kPsfTile + 2 * pad;
    const int ch = kPsfTile + lab + 2 * pad;
    const int mont_w = std::max(cols * cw, 1200);  // room for the header line
    cv::Mat mont(hdr + rows * ch, mont_w, CV_8UC3, cv::Scalar(16, 16, 16));

    char name[64];
    std::snprintf(name, sizeof name, "/psf_%04d", frame_no);
    const std::string base = dir + name;

    std::ofstream csv(base + ".csv");
    csv << "frame,vx,vy,cx,cy,L,theta_deg,end_x,end_y,guard\n";
    csv << std::fixed << std::setprecision(3);

    const float cx = 0.5f * W, cy = 0.5f * H;
    const float Tx = p.exposure * p.dx;
    const float Ty = p.exposure * p.dy;
    const float Phi = p.exposure * p.dalpha;

    float Lmin = 1e9f, Lmax = -1e9f;
    int over_guard = 0;
    float best_d = 1e18f;
    cv::Mat centre_tile8;
    float centre_L = 0.0f, centre_th = 0.0f;
    int centre_vx = 0, centre_vy = 0;

    for (int r = 0; r < rows; ++r) {
        for (int c = 0; c < cols; ++c) {
            const int vx = vxs[c], vy = vys[r];
            // Block centre, exactly as the engines compute it.
            const float rx = static_cast<float>(vx + kPsfHop / 2) - cx;
            const float ry = static_cast<float>(vy + kPsfHop / 2) - cy;

            cv::Mat k = cv::Mat::zeros(kPsfBlock, kPsfBlock, CV_32F);
            float minx = 1e9f, maxx = -1e9f, miny = 1e9f, maxy = -1e9f;
            float ex = 0.0f, ey = 0.0f;
            for (int i = 0; i < kPsfSamples; ++i) {
                const float u = static_cast<float>(i) / (kPsfSamples - 1);
                const float cu = std::cos(u * Phi);
                const float su = std::sin(u * Phi);
                const float sx = u * Tx + (cu - 1.0f) * rx - su * ry;
                const float sy = u * Ty + su * rx + (cu - 1.0f) * ry;
                psf_splat(k, sx, sy, 1.0f / kPsfSamples);
                minx = std::min(minx, sx); maxx = std::max(maxx, sx);
                miny = std::min(miny, sy); maxy = std::max(maxy, sy);
                ex = sx; ey = sy;
            }
            const float L = std::hypot(ex, ey);
            const float th = std::atan2(ey, ex);
            Lmin = std::min(Lmin, L);
            Lmax = std::max(Lmax, L);
            if (L > kPsfHop / 2.0f) ++over_guard;

            csv << frame_no << ',' << vx << ',' << vy << ','
                << (vx + kPsfHop / 2) << ',' << (vy + kPsfHop / 2) << ','
                << L << ',' << th * 180.0f / static_cast<float>(CV_PI) << ','
                << ex << ',' << ey << ','
                << (L > kPsfHop / 2.0f ? 1 : 0) << '\n';

            cv::Mat ks;
            psf_fftshift(k, ks);

            // Window that contains the whole PSF (with a small margin).
            int S = static_cast<int>(std::ceil(std::max(maxx - minx, maxy - miny))) + 11;
            S = std::clamp(S, 33, kPsfBlock - 1);
            if ((S & 1) == 0) ++S;
            const int ccx = static_cast<int>(std::lround(kPsfBlock / 2 + 0.5 * (minx + maxx)));
            const int ccy = static_cast<int>(std::lround(kPsfBlock / 2 + 0.5 * (miny + maxy)));
            const int x0 = std::clamp(ccx - S / 2, 0, kPsfBlock - S);
            const int y0 = std::clamp(ccy - S / 2, 0, kPsfBlock - S);
            cv::Mat crop = ks(cv::Rect(x0, y0, S, S));
            double peak = 0.0;
            cv::minMaxLoc(crop, nullptr, &peak);
            cv::Mat tile8;
            crop.convertTo(tile8, CV_8U, peak > 0.0 ? 255.0 / peak : 0.0);
            cv::Mat tile;
            cv::resize(tile8, tile, cv::Size(kPsfTile, kPsfTile), 0, 0, cv::INTER_LINEAR);
            cv::Mat tile_bgr;
            cv::cvtColor(tile, tile_bgr, cv::COLOR_GRAY2BGR);

            // Mark the trajectory origin (u = 0): the filter's PSF starts there
            // and runs to s(1).  A centred kernel would have the ring mid-line.
            const double disp_scale = kPsfTile / static_cast<double>(S);
            const int ox = static_cast<int>(std::lround((kPsfBlock / 2 - x0) * disp_scale));
            const int oy = static_cast<int>(std::lround((kPsfBlock / 2 - y0) * disp_scale));
            if (ox >= 0 && ox < kPsfTile && oy >= 0 && oy < kPsfTile)
                cv::circle(tile_bgr, cv::Point(ox, oy), 2, cv::Scalar(0, 220, 0),
                           1, cv::LINE_AA);

            cv::Mat cell(ch, cw, CV_8UC3, cv::Scalar(16, 16, 16));
            tile_bgr.copyTo(cell(cv::Rect(pad, pad, kPsfTile, kPsfTile)));
            char buf[64];
            std::snprintf(buf, sizeof buf, "L=%.1f th=%.0f", L,
                          th * 180.0f / static_cast<float>(CV_PI));
            cv::putText(cell, buf, cv::Point(pad + 2, pad + kPsfTile + 11),
                        cv::FONT_HERSHEY_SIMPLEX, 0.30, cv::Scalar(205, 205, 205),
                        1, cv::LINE_AA);
            std::snprintf(buf, sizeof buf, "x=%d y=%d", vx, vy);
            cv::putText(cell, buf, cv::Point(pad + 2, pad + kPsfTile + 23),
                        cv::FONT_HERSHEY_SIMPLEX, 0.30, cv::Scalar(205, 205, 205),
                        1, cv::LINE_AA);
            cv::rectangle(cell, cv::Rect(0, 0, cw - 1, ch - 1),
                          cv::Scalar(48, 48, 48), 1);
            cell.copyTo(mont(cv::Rect(c * cw, hdr + r * ch, cw, ch)));

            const float d = std::hypot(static_cast<float>(vx + kPsfHop / 2) - cx,
                                       static_cast<float>(vy + kPsfHop / 2) - cy);
            if (d < best_d) {
                best_d = d;
                centre_tile8 = tile8.clone();
                centre_L = L;
                centre_th = th;
                centre_vx = vx;
                centre_vy = vy;
            }
        }
    }

    char text[256];
    std::snprintf(text, sizeof text,
                  "frame %d  dx=%.2f dy=%.2f dalpha=%.4f  D=%.2f nsr=%.3f  "
                  "blocks %dx%d  L=%.1f..%.1f px  (green ring = PSF origin u=0)",
                  frame_no, p.dx, p.dy, p.dalpha, p.exposure, p.nsr,
                  cols, rows, Lmin, Lmax);
    cv::putText(mont, text, cv::Point(6, 17), cv::FONT_HERSHEY_SIMPLEX, 0.45,
                cv::Scalar(230, 230, 230), 1, cv::LINE_AA);

    if (!cv::imwrite(base + ".png", mont))
        std::cerr << "[psf] cannot write " << base << ".png\n";

    std::cout << "[psf] frame " << frame_no << " -> " << base << ".png"
              << "  blocks=" << cols << "x" << rows
              << "  L=" << Lmin << ".." << Lmax << " px";
    if (over_guard)
        std::cout << "  WARN: " << over_guard << " block(s) with L > " << kPsfHop / 2
                  << " px (PSF reaches outside the 50% tile guard)";
    std::cout << "\n";

    if (!centre_tile8.empty())
        psf_print_ascii(centre_tile8, centre_vx, centre_vy, centre_L,
                        centre_th * 180.0f / static_cast<float>(CV_PI));
}

}  // namespace

int main(int argc, char** argv) {
    std::string in, out, backend = "auto", fixed, psf_dir;
    int max_frames = 0, psf_frames = 5;
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
        else if (a == "--dump-psf")  psf_dir = next();
        else if (a == "--psf-frames") psf_frames = std::stoi(next());
        else if (a == "--display")  display = true;
        else if (a == "-h" || a == "--help") {
            std::cout << "usage: deblur_video --in VID [--out VID] [--backend ...]\n"
                         "                     [--exposure 0.5] [--nsr 0.01] [--fixed dx,dy,da]\n"
                         "                     [--max-frames N] [--display]\n"
                         "                     [--dump-psf DIR] [--psf-frames N]\n"
                         "  --dump-psf DIR   write per-block PSF montages (psf_NNNN.png/.csv);\n"
                         "                   also honoured via DEBLUR_PSF_DIR\n"
                         "  --psf-frames N   number of frames to dump (default 5, 0 = all)\n";
            return 0;
        } else { std::cerr << "unknown option: " << a << "\n"; return 1; }
    }
    if (in.empty()) { std::cerr << "usage: deblur_video --in VID [options]\n"; return 1; }

    if (psf_dir.empty()) {
        if (const char* e = std::getenv("DEBLUR_PSF_DIR")) psf_dir = e;
    }
    if (!psf_dir.empty()) {
        std::error_code ec;
        std::filesystem::create_directories(psf_dir, ec);
        if (ec) {
            std::cerr << "cannot create " << psf_dir << ": " << ec.message() << "\n";
            psf_dir.clear();
        }
    }

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
    int frame_no = 0, used = 0, psf_dumped = 0;

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

        if (!psf_dir.empty() && (psf_frames == 0 || psf_dumped < psf_frames)) {
            dump_psf_frame(psf_dir, frame_no, p, frame.cols, frame.rows);
            ++psf_dumped;
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
