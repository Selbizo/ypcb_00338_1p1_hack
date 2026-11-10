// conv_demo - OpenCV front-end for the FPGA video platform.
//
//   conv_demo [--camera N] [--width W] [--height H] [--frames N]
//             [--headless] [--synthetic] [--out DIR] [--verify]
//
// Stage 0 behaviour: capture -> DDR3 (H2C) -> DDR3 (C2H) -> display.
// The same binary is the base for the VDMA + kernel pipeline (M0/M1).
#include <opencv2/opencv.hpp>

#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>

#include "pipeline.hpp"
#include "xdma.hpp"

namespace {

struct Options {
    int camera = 0;
    int width = 1280;
    int height = 720;
    int frames = 0;  // 0 = unlimited
    bool headless = false;
    bool synthetic = false;
    bool verify = false;
    std::string out = ".";
};

void usage(const char* argv0) {
    std::printf(
        "usage: %s [options]\n"
        "  --camera N     camera index (default 0)\n"
        "  --width W      requested capture width (default 1280)\n"
        "  --height H     requested capture height (default 720)\n"
        "  --frames N     stop after N frames, 0 = unlimited\n"
        "  --headless     no window, save one PNG and print stats\n"
        "  --synthetic    do not open a camera, generate a moving pattern\n"
        "  --verify       compare loopback output with the input\n"
        "  --out DIR      directory for --headless output\n",
        argv0);
}

Options parse(int argc, char** argv) {
    Options o;
    for (int i = 1; i < argc; ++i) {
        std::string a = argv[i];
        auto next = [&](const char* what) -> std::string {
            if (i + 1 >= argc) {
                std::fprintf(stderr, "%s requires a value\n", what);
                std::exit(2);
            }
            return argv[++i];
        };
        if (a == "--camera") o.camera = std::stoi(next("--camera"));
        else if (a == "--width") o.width = std::stoi(next("--width"));
        else if (a == "--height") o.height = std::stoi(next("--height"));
        else if (a == "--frames") o.frames = std::stoi(next("--frames"));
        else if (a == "--headless") o.headless = true;
        else if (a == "--synthetic") o.synthetic = true;
        else if (a == "--verify") o.verify = true;
        else if (a == "--out") o.out = next("--out");
        else if (a == "-h" || a == "--help") { usage(argv[0]); std::exit(0); }
        else { std::fprintf(stderr, "unknown option: %s\n", a.c_str()); usage(argv[0]); std::exit(2); }
    }
    return o;
}

cv::Mat synthetic_frame(cv::Size sz, int idx) {
    cv::Mat m(sz, CV_8UC3);
    for (int y = 0; y < sz.height; ++y) {
        auto* row = m.ptr<cv::Vec3b>(y);
        for (int x = 0; x < sz.width; ++x)
            row[x] = cv::Vec3b(static_cast<uchar>((x + idx * 3) & 0xff),
                               static_cast<uchar>((y) & 0xff),
                               static_cast<uchar>(((x + y) / 2) & 0xff));
    }
    const int cx = sz.width / 2 + static_cast<int>(120.0 * std::sin(idx * 0.05));
    cv::circle(m, {cx, sz.height / 2}, sz.height / 8, {255, 255, 255}, -1);
    return m;
}

double now_s() {
    using clk = std::chrono::steady_clock;
    return std::chrono::duration<double>(clk::now().time_since_epoch()).count();
}

}  // namespace

int main(int argc, char** argv) {
    const Options opt = parse(argc, argv);

    cv::VideoCapture cap;
    if (!opt.synthetic) {
        cap.open(opt.camera, cv::CAP_V4L2);
        if (!cap.isOpened()) {
            std::fprintf(stderr, "cannot open camera %d\n", opt.camera);
            return 1;
        }
        cap.set(cv::CAP_PROP_FOURCC, cv::VideoWriter::fourcc('M', 'J', 'P', 'G'));
        cap.set(cv::CAP_PROP_FRAME_WIDTH, opt.width);
        cap.set(cv::CAP_PROP_FRAME_HEIGHT, opt.height);
        cap.set(cv::CAP_PROP_BUFFERSIZE, 1);
    }

    accel::Xdma xdma;
    accel::DdrLoopback pipe(xdma);

    std::printf("pipeline: %s\n", pipe.name());
    if (opt.synthetic) std::printf("source: synthetic %dx%d\n", opt.width, opt.height);
    else std::printf("source: camera %d, %dx%d\n", opt.camera,
                     static_cast<int>(cap.get(cv::CAP_PROP_FRAME_WIDTH)),
                     static_cast<int>(cap.get(cv::CAP_PROP_FRAME_HEIGHT)));

    const bool headless = opt.headless || std::getenv("DISPLAY") == nullptr;
    if (headless) std::printf("display: off (headless)\n");

    int frame_no = 0;
    double fps_t0 = now_s();
    const double t_start = fps_t0;
    int fps_n = 0;
    bool saved = false;
    double sum_up = 0.0, sum_down = 0.0;

    for (;;) {
        cv::Mat frame;
        if (opt.synthetic) {
            const int w = opt.width, h = opt.height;
            frame = synthetic_frame({w, h}, frame_no);
        } else {
            cap >> frame;
            if (frame.empty()) {
                std::fprintf(stderr, "empty frame\n");
                break;
            }
        }

        cv::Mat out = pipe.process(frame);
        sum_up += pipe.timing().upload_ms;
        sum_down += pipe.timing().download_ms;

        if (opt.verify) {
            const double inf = cv::norm(out, frame, cv::NORM_INF);
            if (inf != 0.0) std::fprintf(stderr, "loopback mismatch: norm_inf=%g\n", inf);
        }

        ++frame_no;
        ++fps_n;
        const double t = now_s();
        if (t - fps_t0 >= 1.0) {
            const auto& tm = pipe.timing();
            std::printf("fps=%.1f  up=%.2f ms  down=%.2f ms  (%dx%d, %.2f MB)\n",
                        fps_n / (t - fps_t0), tm.upload_ms, tm.download_ms, out.cols, out.rows,
                        frame.total() * frame.elemSize() / 1e6);
            std::fflush(stdout);
            fps_t0 = t;
            fps_n = 0;
        }

        if (headless) {
            if (!saved) {
                const std::string path = opt.out + "/conv_demo.png";
                cv::imwrite(path, out);
                std::printf("saved %s\n", path.c_str());
                saved = true;
            }
        } else {
            cv::imshow("conv_accel", out);
            if (cv::waitKey(1) == 27) break;
        }

        if (opt.frames > 0 && frame_no >= opt.frames) break;
    }

    if (!headless) cv::destroyAllWindows();
    const double elapsed = now_s() - t_start;
    if (frame_no > 0) {
        std::printf("summary: %d frames in %.3f s = %.1f fps, up=%.2f ms, down=%.2f ms, total=%.2f ms\n",
                    frame_no, elapsed, frame_no / elapsed, sum_up / frame_no, sum_down / frame_no,
                    (sum_up + sum_down) / frame_no);
    }
    std::printf("frames: %d\n", frame_no);
    return 0;
}
