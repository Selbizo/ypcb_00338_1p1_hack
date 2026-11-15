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

#include <memory>

#include "pipeline.hpp"
#include "axidma.hpp"
#include "filters.hpp"
#include "userbar.hpp"
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
    bool vdma = false;
    bool compare = false;
    std::string filter = "gauss";
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
        "  --dma          run the frame through DDR3 -> AXI DMA -> DDR3 (M0)\n"
        "  --vdma         alias for --dma (old name)\n"
        "  --compare      show source | FPGA result | amplified difference\n"
        "  --filter NAME  convolution preset: gauss (default), sharp, edge, box, raw\n"
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
        else if (a == "--dma" || a == "--vdma") o.vdma = true;
        else if (a == "--compare") o.compare = true;
        else if (a == "--filter") o.filter = next("--filter");
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

// Side-by-side view: source | FPGA result | amplified |difference|.
// Panels are scaled down so that the window stays a reasonable size.
cv::Mat compare_view(const cv::Mat& src, const cv::Mat& out, const std::string& status,
                     double maxdiff, bool show_diff) {
    const int bar = 26;
    const int panel_w = 640;
    const int panels = show_diff ? 3 : 2;
    const double sc = std::min(1.0, static_cast<double>(panel_w) / src.cols);
    const int pw = static_cast<int>(src.cols * sc);
    const int ph = static_cast<int>(src.rows * sc);

    cv::Mat a, b, d;
    cv::resize(src, a, {pw, ph}, 0, 0, cv::INTER_AREA);
    cv::resize(out, b, {pw, ph}, 0, 0, cv::INTER_AREA);
    if (show_diff) {
        cv::Mat diff;
        cv::absdiff(src, out, diff);
        cv::Mat gray;
        cv::cvtColor(diff, gray, cv::COLOR_BGR2GRAY);
        gray *= 16;  // amplify small differences
        cv::cvtColor(gray, d, cv::COLOR_GRAY2BGR);
        cv::resize(d, d, {pw, ph}, 0, 0, cv::INTER_AREA);
    }

    cv::Mat canvas(ph + bar, pw * panels, CV_8UC3, cv::Scalar(28, 28, 28));
    a.copyTo(canvas(cv::Rect(0, bar, pw, ph)));
    b.copyTo(canvas(cv::Rect(pw, bar, pw, ph)));
    if (show_diff) d.copyTo(canvas(cv::Rect(2 * pw, bar, pw, ph)));

    const auto txt = [&](const std::string& s, int x, cv::Scalar color) {
        cv::putText(canvas, s, {x + 8, 18}, cv::FONT_HERSHEY_SIMPLEX, 0.5, color, 1, cv::LINE_AA);
    };
    txt("source (host)", 0, {210, 210, 210});
    txt("FPGA result (conv2d 5x5)", pw, {210, 210, 210});
    if (show_diff) {
        const std::string dl =
            maxdiff == 0.0 ? "|source - result| x16  max=0" : cv::format("|source - result| x16  max=%g", maxdiff);
        txt(dl, 2 * pw, maxdiff == 0.0 ? cv::Scalar(120, 255, 120) : cv::Scalar(120, 180, 255));
        if (maxdiff == 0.0) {
            cv::putText(canvas, "no difference", {2 * pw + pw / 2 - 80, bar + ph / 2},
                        cv::FONT_HERSHEY_SIMPLEX, 0.7, cv::Scalar(90, 90, 90), 1, cv::LINE_AA);
        }
    }
    const int tw = cv::getTextSize(status, cv::FONT_HERSHEY_SIMPLEX, 0.4, 1, nullptr).width;
    cv::putText(canvas, status, {pw * panels - tw - 8, 18}, cv::FONT_HERSHEY_SIMPLEX, 0.4,
                {180, 200, 255}, 1, cv::LINE_AA);
    return canvas;
}

// Software reference for the HLS kernel: 5x5 Gaussian (sum 256), integer
// accumulation, truncating >>8, saturate to [0,255].
// Border handling: xf::cv::filter2D behaves as zero padding in Vitis Vision
// 2024.2 (verified in C simulation), not replicate as the enum suggests.
cv::Mat conv_reference(const cv::Mat& bgr, const accel::Filter& f) {
    const int16_t* K = f.k;
    cv::Mat ref(bgr.size(), CV_8UC3);
    const int rows = bgr.rows, cols = bgr.cols;
    for (int y = 0; y < rows; ++y) {
        uchar* o = ref.ptr<uchar>(y);
        for (int x = 0; x < cols; ++x) {
            for (int c = 0; c < 3; ++c) {
                int sum = 0;
                for (int ky = 0; ky < 5; ++ky) {
                    const int yy = y + ky - 2;
                    if (yy < 0 || yy >= rows) continue;
                    const uchar* row = bgr.ptr<uchar>(yy);
                    for (int kx = 0; kx < 5; ++kx) {
                        const int xx = x + kx - 2;
                        if (xx < 0 || xx >= cols) continue;
                        sum += K[ky * 5 + kx] * static_cast<int>(row[xx * 3 + c]);
                    }
                }
                int v = sum >> f.shift;
                o[x * 3 + c] = static_cast<uchar>(std::min(std::max(v, 0), 255));
            }
        }
    }
    return ref;
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
    std::unique_ptr<accel::UserBar> bar;
    std::unique_ptr<accel::IVideoPipeline> pipe;
    accel::AxidmaConv2d* conv_pipe = nullptr;
    if (opt.vdma) {
        const accel::Filter* f = accel::find_filter(opt.filter.c_str());
        if (!f) {
            std::fprintf(stderr, "unknown filter: %s\n", opt.filter.c_str());
            return 2;
        }
        bar = std::make_unique<accel::UserBar>();
        auto p = std::make_unique<accel::AxidmaConv2d>(xdma, *bar, *f);
        conv_pipe = p.get();
        pipe = std::move(p);
    } else {
        pipe = std::make_unique<accel::DdrLoopback>(xdma);
    }

    std::printf("pipeline: %s", pipe->name());
    if (conv_pipe) std::printf("  filter: %s (%s)", conv_pipe->filter().name, conv_pipe->filter().title);
    std::printf("\n");
    if (opt.synthetic) std::printf("source: synthetic %dx%d\n", opt.width, opt.height);
    else std::printf("source: camera %d, %dx%d\n", opt.camera,
                     static_cast<int>(cap.get(cv::CAP_PROP_FRAME_WIDTH)),
                     static_cast<int>(cap.get(cv::CAP_PROP_FRAME_HEIGHT)));

    const bool headless = opt.headless || std::getenv("DISPLAY") == nullptr;
    if (headless) std::printf("display: off (headless)\n");

    bool verified = false;
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

        cv::Mat out = pipe->process(frame);
        sum_up += pipe->timing().upload_ms;
        sum_down += pipe->timing().download_ms;

        if (opt.verify && !verified) {
            const cv::Mat ref = conv_reference(frame, conv_pipe->filter());
            const double d = cv::norm(out, ref, cv::NORM_INF);
            std::printf("reference: max|fpga - software| = %g  (filter %s)\n", d,
                        conv_pipe->filter().name);
            verified = true;
        }
        const double maxdiff = opt.compare ? cv::norm(out, frame, cv::NORM_INF) : 0.0;

        ++frame_no;
        ++fps_n;
        const double t = now_s();
        if (t - fps_t0 >= 1.0) {
            const auto& tm = pipe->timing();
            std::printf("fps=%.1f  up=%.2f ms  down=%.2f ms  (%dx%d, %.2f MB)\n",
                        fps_n / (t - fps_t0), tm.upload_ms, tm.download_ms, out.cols, out.rows,
                        frame.total() * frame.elemSize() / 1e6);
            std::fflush(stdout);
            fps_t0 = t;
            fps_n = 0;
        }

        if (headless) {
            if (!saved) {
                const std::string path = opt.out + (opt.compare ? "/compare.png" : "/conv_demo.png");
                const cv::Mat img =
                    opt.compare
                        ? compare_view(frame, out,
                                       cv::format("%dx%d  up %.2f / dma %.2f / down %.2f ms",
                                                  out.cols, out.rows, pipe->timing().upload_ms,
                                                  pipe->timing().process_ms,
                                                  pipe->timing().download_ms),
                                       maxdiff, opt.verify)
                        : out;
                cv::imwrite(path, img);
                std::printf("saved %s\n", path.c_str());
                saved = true;
            }
        } else {
            cv::Mat view = out;
            if (opt.compare) {
                const auto& tm = pipe->timing();
                const std::string st =
                    cv::format("%dx%d  %s  up %.2f / dma %.2f / down %.2f ms", out.cols, out.rows,
                               conv_pipe ? conv_pipe->filter().title : "", tm.upload_ms,
                               tm.process_ms, tm.download_ms);
                view = compare_view(frame, out, st, maxdiff, opt.verify);
            }
            cv::imshow("conv_accel", view);
            const int key = cv::waitKey(1);
            if (key == 27) break;
            if (conv_pipe && key >= '1' && key < '1' + accel::kFilterCount) {
                const accel::Filter& nf = accel::kFilters[key - '1'];
                if (&nf != &conv_pipe->filter()) {
                    conv_pipe->set_filter(nf);
                    verified = false;
                    std::printf("filter: %s (%s)\n", nf.name, nf.title);
                    std::fflush(stdout);
                }
            }
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
