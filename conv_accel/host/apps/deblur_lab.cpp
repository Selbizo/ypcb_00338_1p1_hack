// Interactive PSF lab: one image is blurred once with a known linear motion
// PSF; the loop then re-runs the real deblur engine with a user-controlled PSF
// estimate (length, angle, nsr), like a frozen video stream.
//
// The blur is rendered with the same trailing-integration model the engines
// assume:  blurred(x) = mean_{u in [0,1]} sharp(x - u*T).  The deconvolution
// phase therefore matches, and a correct estimate restores the sharp frame.
#include "deblur/deblur.h"

#include <opencv2/highgui.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>

#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <sstream>
#include <string>

namespace {

deblur::Backend parse_backend(const std::string& s) {
    if (s == "auto")   return deblur::Backend::Auto;
    if (s == "cpu")    return deblur::Backend::CPU;
    if (s == "opencl") return deblur::Backend::OpenCL;
    if (s == "cuda")   return deblur::Backend::CUDA;
    if (s == "fpga")   return deblur::Backend::FPGA;
    throw std::runtime_error("unknown backend: " + s);
}

// Synthetic sharp test chart used when --in is not given.
cv::Mat make_chart(int W = 1920, int H = 1080) {
    cv::Mat c(H, W, CV_8UC3, cv::Scalar(90, 90, 90));
    cv::putText(c, "WIENER LAB", cv::Point(140, 320), cv::FONT_HERSHEY_SIMPLEX,
                5.0, cv::Scalar(250, 250, 250), 12, cv::LINE_AA);
    cv::putText(c, "ground truth test", cv::Point(140, 450),
                cv::FONT_HERSHEY_SIMPLEX, 1.8, cv::Scalar(15, 15, 15), 6,
                cv::LINE_AA);
    for (int i = 0; i < 8; ++i) {
        const cv::Scalar col = (i % 2) ? cv::Scalar(240, 240, 240)
                                       : cv::Scalar(20, 20, 20);
        cv::rectangle(c, cv::Point(140 + 215 * i, 540),
                      cv::Point(250 + 215 * i, 650), col, cv::FILLED);
        cv::circle(c, cv::Point(195 + 215 * i, 760), 48, col, cv::FILLED);
    }
    cv::putText(c, "small text", cv::Point(1320, 930), cv::FONT_HERSHEY_SIMPLEX,
                1.0, cv::Scalar(245, 245, 245), 3, cv::LINE_AA);

    cv::Mat zp(256, 256, CV_32F);
    for (int y = 0; y < 256; ++y) {
        for (int x = 0; x < 256; ++x) {
            const float r2 = static_cast<float>((x - 128) * (x - 128) +
                                                (y - 128) * (y - 128));
            zp.at<float>(y, x) = 127.5f + 127.5f *
                std::sin(r2 * (2.0f * static_cast<float>(CV_PI) / 2400.0f));
        }
    }
    cv::Mat zp8;
    zp.convertTo(zp8, CV_8U);
    cv::Mat zp3;
    cv::cvtColor(zp8, zp3, cv::COLOR_GRAY2BGR);
    cv::Mat roi = c(cv::Rect(60, 790, 256, 256));
    cv::max(roi, zp3, roi);

    cv::setRNGSeed(3);
    cv::Mat noise(H, W, CV_32FC3);
    cv::randn(noise, cv::Scalar::all(0), cv::Scalar::all(8));
    cv::Mat f;
    c.convertTo(f, CV_32F);
    f += noise;
    f.convertTo(c, CV_8U);
    return c;
}

// Trailing linear motion blur, modeled as the engine does it:
//     blurred(x) = (1/N) * sum_u sharp(x - u*T),  u in [0, 1]
cv::Mat motion_blur(const cv::Mat& src, float len, float angle_deg) {
    const float th = angle_deg * static_cast<float>(CV_PI) / 180.0f;
    const float tx = len * std::cos(th);
    const float ty = len * std::sin(th);
    const int N = std::clamp(static_cast<int>(std::ceil(2.0f * len)), 32, 256);

    cv::Mat acc(src.size(), CV_32FC3, cv::Scalar(0));
    cv::Mat tmp;
    for (int i = 0; i < N; ++i) {
        const float u = static_cast<float>(i) / (N - 1);
        const cv::Mat M = (cv::Mat_<float>(2, 3) << 1, 0, u * tx, 0, 1, u * ty);
        cv::warpAffine(src, tmp, M, src.size(), cv::INTER_LINEAR, cv::BORDER_REFLECT);
        cv::accumulate(tmp, acc);
    }
    cv::Mat out;
    acc.convertTo(out, CV_8U, 1.0 / N);
    return out;
}

double psnr_gray(const cv::Mat& a, const cv::Mat& b) {
    cv::Mat ga, gb, d;
    cv::cvtColor(a, ga, cv::COLOR_BGR2GRAY);
    cv::cvtColor(b, gb, cv::COLOR_BGR2GRAY);
    cv::absdiff(ga, gb, d);
    d.convertTo(d, CV_32F);
    d = d.mul(d);
    const double mse = cv::mean(d)[0];
    return mse <= 1e-12 ? 99.0 : 10.0 * std::log10(255.0 * 255.0 / mse);
}

cv::Mat scaled(const cv::Mat& src, int w, int h) {
    cv::Mat out;
    const bool down = src.cols > w || src.rows > h;
    cv::resize(src, out, cv::Size(w, h), 0, 0,
               down ? cv::INTER_AREA : cv::INTER_LINEAR);
    return out;
}

void panel_label(cv::Mat& img, const std::string& text) {
    cv::rectangle(img, cv::Rect(0, 0, img.cols, 24), cv::Scalar(0, 0, 0),
                  cv::FILLED);
    cv::putText(img, text, cv::Point(6, 17), cv::FONT_HERSHEY_SIMPLEX, 0.45,
                cv::Scalar(255, 255, 255), 1, cv::LINE_AA);
}

}  // namespace

int main(int argc, char** argv) {
    std::string in, out, backend = "cpu";
    double true_len = 20.0, true_ang = 0.0;
    double est_len = -1.0, est_ang = 0.0;
    bool have_est_ang = false;
    double view_scale = 0.0;
    float exposure = 0.5f, nsr0 = 0.01f, noise = 0.0f;
    int iters = 0;
    bool gui = true, cli = false;

    for (int i = 1; i < argc; ++i) {
        const std::string a = argv[i];
        auto next = [&]() -> std::string {
            if (++i >= argc) { std::cerr << "missing value for " << a << "\n"; std::exit(1); }
            return argv[i];
        };
        if (a == "--in")             in = next();
        else if (a == "--out")       out = next();
        else if (a == "--backend")   backend = next();
        else if (a == "--len")       true_len = std::stod(next());
        else if (a == "--angle")     true_ang = std::stod(next());
        else if (a == "--est-len")   est_len = std::stod(next());
        else if (a == "--est-angle") { est_ang = std::stod(next()); have_est_ang = true; }
        else if (a == "--exposure")  exposure = std::stof(next());
        else if (a == "--nsr")       nsr0 = std::stof(next());
        else if (a == "--noise")     noise = std::stof(next());
        else if (a == "--view-scale") view_scale = std::stod(next());
        else if (a == "--iters")     iters = std::stoi(next());
        else if (a == "--no-gui")    gui = false;
        else if (a == "--cli")       { cli = true; gui = false; }
        else if (a == "-h" || a == "--help") {
            std::cout <<
                "usage: deblur_lab [--in IMG] [--out IMG] [--backend cpu|opencl|cuda|fpga]\n"
                "                  [--len 20] [--angle 0]        true linear blur PSF\n"
                "                  [--est-len L] [--est-angle A] initial PSF estimate\n"
                "                  [--exposure 0.5] [--nsr 0.01] [--noise 0]\n"
                "                  [--view-scale S] [--iters N] [--no-gui] [--cli]\n"
                "  --in omitted: synthetic 1920x1080 test chart\n"
                "  GUI keys: q/ESC quit, r reset estimate to the true PSF\n"
                "  --cli: terminal fallback, commands: l <px>, a <deg>, n <nsr>, r, q\n";
            return 0;
        } else { std::cerr << "unknown option: " << a << "\n"; return 1; }
    }
    if (exposure < 1e-3f) { std::cerr << "exposure must be > 0\n"; return 1; }
    if (!gui && !cli && iters == 0) iters = 1;  // batch without a stop condition
    if (est_len < 0.0) est_len = true_len;
    if (!have_est_ang) est_ang = true_ang;

    cv::Mat sharp = in.empty() ? make_chart() : cv::imread(in, cv::IMREAD_COLOR);
    if (sharp.empty()) { std::cerr << "cannot read " << in << "\n"; return 1; }
    if (sharp.cols < 256 || sharp.rows < 256) {
        std::cerr << "image must be at least 256x256\n";
        return 1;
    }

    std::cout << "true blur: L=" << true_len << " px  theta=" << true_ang
              << " deg  (trailing, u in [0,1])\n";
    cv::Mat blurred = motion_blur(sharp, static_cast<float>(true_len),
                                  static_cast<float>(true_ang));
    if (noise > 0.0f) {
        cv::Mat f;
        blurred.convertTo(f, CV_32F);
        cv::Mat n(f.size(), CV_32FC3);
        cv::randn(n, cv::Scalar::all(0), cv::Scalar::all(noise));
        f += n;
        f.convertTo(blurred, CV_8U);
    }
    const double psnr_in = psnr_gray(blurred, sharp);
    std::cout << "blurred vs sharp: " << psnr_in << " dB\n";

    std::unique_ptr<deblur::Engine> eng;
    try {
        eng = deblur::Engine::create(parse_backend(backend));
    } catch (const std::exception& e) {
        std::cerr << "error: " << e.what() << "\n";
        return 1;
    }
    std::cout << "backend=" << eng->name() << "  image=" << sharp.cols << "x"
              << sharp.rows << "\n";

    const std::string win = "deblur lab  (q=quit, r=reset)";
    int s_len = static_cast<int>(std::lround(est_len));
    int s_ang = static_cast<int>(std::lround(est_ang)) % 360;
    if (s_ang < 0) s_ang += 360;
    int s_nsr = static_cast<int>(std::lround(nsr0 * 1e4f));
    if (gui) {
        cv::namedWindow(win, cv::WINDOW_AUTOSIZE);
        cv::createTrackbar("est L, px", win, &s_len, 160);
        cv::createTrackbar("est theta, deg", win, &s_ang, 359);
        cv::createTrackbar("nsr x1e-4", win, &s_nsr, 500);
    }

    double vs = view_scale > 0.0
                    ? view_scale
                    : std::min(1.0, std::min(1800.0 / (2.0 * sharp.cols),
                                            1000.0 / (2.0 * sharp.rows)));
    const int pw = std::max(1, static_cast<int>(std::lround(sharp.cols * vs)));
    const int ph = std::max(1, static_cast<int>(std::lround(sharp.rows * vs)));
    std::cout << "view " << pw << "x" << ph << " per panel\n";

    cv::Mat mont;
    long frame = 0;
    const double t0 = static_cast<double>(cv::getTickCount());

    while (true) {
        const float L = static_cast<float>(s_len);
        const float th = static_cast<float>(s_ang) * static_cast<float>(CV_PI) / 180.0f;
        const float nsr = std::max(0, s_nsr) * 1e-4f;

        deblur::MotionParams p;
        p.exposure = exposure;
        p.nsr = nsr;
        p.dx = L * std::cos(th) / exposure;
        p.dy = L * std::sin(th) / exposure;
        p.dalpha = 0.0f;

        cv::Mat deb;
        eng->process(blurred, deb, p);

        const double psnr_d = psnr_gray(deb, sharp);

        if (gui || cli || !out.empty() || frame == 0) {
            cv::Mat diff;
            cv::absdiff(deb, sharp, diff);
            diff.convertTo(diff, CV_32F, 4.0);
            cv::Mat diff8;
            diff.convertTo(diff8, CV_8U);

            cv::Mat dg;
            cv::cvtColor(diff8, dg, cv::COLOR_BGR2GRAY);
            cv::Mat dcolor;
            cv::applyColorMap(dg, dcolor, cv::COLORMAP_JET);

            cv::Mat a = scaled(sharp, pw, ph);
            cv::Mat b = scaled(blurred, pw, ph);
            cv::Mat c = scaled(deb, pw, ph);
            cv::Mat d = scaled(dcolor, pw, ph);

            char t[160];
            panel_label(a, "sharp (ground truth)");
            std::snprintf(t, sizeof t, "blurred  L=%.1f px  th=%.1f deg  PSNR=%.2f dB",
                          true_len, true_ang, psnr_in);
            panel_label(b, t);
            std::snprintf(t, sizeof t,
                          "deblurred  est L=%.1f  th=%d  nsr=%.4f  PSNR=%.2f dB",
                          L, s_ang, nsr, psnr_d);
            panel_label(c, t);
            panel_label(d, "|deblurred - sharp| x4");

            mont.create(ph * 2, pw * 2, CV_8UC3);
            mont.setTo(cv::Scalar(18, 18, 18));
            a.copyTo(mont(cv::Rect(0, 0, pw, ph)));
            b.copyTo(mont(cv::Rect(pw, 0, pw, ph)));
            c.copyTo(mont(cv::Rect(0, ph, pw, ph)));
            d.copyTo(mont(cv::Rect(pw, ph, pw, ph)));
        }

        if (cli || frame % 15 == 0) {
            const double sec = (static_cast<double>(cv::getTickCount()) - t0) /
                               cv::getTickFrequency();
            std::printf("[lab] iter %ld  est L=%.0f th=%d nsr=%.4f  PSNR %.2f dB  "
                        "(input %.2f dB)  %.1f fps\n",
                        frame, L, s_ang, nsr, psnr_d, psnr_in,
                        sec > 0 ? (frame + 1) / sec : 0.0);
            std::fflush(stdout);
        }

        if (gui) {
            cv::imshow(win, mont);
            const int key = cv::waitKey(1) & 0xff;
            if (key == 27 || key == 'q') break;
            if (key == 'r') {
                cv::setTrackbarPos("est L, px", win,
                                   static_cast<int>(std::lround(true_len)));
                int a0 = static_cast<int>(std::lround(true_ang)) % 360;
                if (a0 < 0) a0 += 360;
                cv::setTrackbarPos("est theta, deg", win, a0);
                cv::setTrackbarPos("nsr x1e-4", win,
                                   static_cast<int>(std::lround(nsr0 * 1e4f)));
            }
        } else if (cli) {
            if (out.empty()) out = "deblur_lab.png";
            if (!cv::imwrite(out, mont))
                std::cerr << "cannot write " << out << "\n";
            std::cout << "[lab] image: " << out << "\n> " << std::flush;

            std::string line;
            if (!std::getline(std::cin, line)) break;
            if (line == "q" || line == "quit" || line == "exit") break;
            if (line == "r") {
                s_len = static_cast<int>(std::lround(true_len));
                s_ang = static_cast<int>(std::lround(true_ang)) % 360;
                if (s_ang < 0) s_ang += 360;
                s_nsr = static_cast<int>(std::lround(nsr0 * 1e4f));
            } else if (!line.empty()) {
                std::istringstream iss(line);
                std::string cmd;
                double val = 0.0;
                if (!(iss >> cmd >> val)) {
                    std::cout << "commands: l <px>, a <deg>, n <nsr>, r, q\n";
                } else if (cmd == "l") {
                    s_len = std::clamp(static_cast<int>(std::lround(val)), 0, 160);
                } else if (cmd == "a") {
                    int a = static_cast<int>(std::lround(val)) % 360;
                    if (a < 0) a += 360;
                    s_ang = a;
                } else if (cmd == "n") {
                    s_nsr = std::clamp(static_cast<int>(std::lround(val * 1e4)), 0, 500);
                } else {
                    std::cout << "unknown command\n";
                }
            }
        }

        ++frame;
        if (iters > 0 && frame >= iters) break;
    }

    if (!out.empty() && !mont.empty()) {
        if (!cv::imwrite(out, mont))
            std::cerr << "cannot write " << out << "\n";
        else
            std::cout << "wrote " << out << "\n";
    }
    std::cout << "last estimate: L=" << s_len << " px  theta=" << s_ang
              << " deg  nsr=" << (s_nsr * 1e-4) << "\n";
    return 0;
}
