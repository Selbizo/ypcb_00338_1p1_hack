// Interactive PSF lab: one image is blurred once with a known motion PSF
// (translation + roll around the view axis); the loop then re-runs the real
// deblur engine with a user-controlled PSF estimate (length, angle, roll,
// nsr), like a frozen video stream.
//
// The blur is rendered with the same trailing-integration model the engines
// assume:
//     W_u(p) = c + u*T + R(u*Phi)*(p - c),   u in [0, 1]
//     blurred(x) = mean_u sharp(W_u^{-1}(x))
// The deconvolution phase therefore matches, and a correct estimate restores
// the sharp frame.  With roll != 0 the PSF differs from block to block: that
// is exactly the case the engines approximate with a per-block PSF.
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
#include <stdexcept>
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

// Trailing motion blur with roll around the view axis, modeled as the engine
// does it:
//     W_u(p) = c + u*T + R(u*Phi)*(p - c),   u in [0, 1]
//     blurred(x) = (1/N) * sum_u sharp(W_u^{-1}(x))
cv::Mat motion_blur(const cv::Mat& src, float len, float angle_deg,
                    float roll_deg, int samples = 0) {
    const float th = angle_deg * static_cast<float>(CV_PI) / 180.0f;
    const float tx = len * std::cos(th);
    const float ty = len * std::sin(th);
    const float phi = roll_deg * static_cast<float>(CV_PI) / 180.0f;

    const float cx = 0.5f * src.cols, cy = 0.5f * src.rows;
    const float arc = std::abs(phi) * 0.5f * std::hypot(
        static_cast<float>(src.cols), static_cast<float>(src.rows));
    const int full = std::clamp(
        static_cast<int>(std::ceil(2.0f * (len + arc))), 32, 512);
    const int N = samples > 0 ? std::min(samples, full) : full;

    cv::Mat acc(src.size(), CV_32FC3, cv::Scalar(0));
    cv::Mat tmp;
    for (int i = 0; i < N; ++i) {
        const float u = static_cast<float>(i) / (N - 1);
        const float ph = u * phi;
        const float cu = std::cos(ph), su = std::sin(ph);
        const cv::Mat M = (cv::Mat_<float>(2, 3) <<
            cu, -su, cx + u * tx - (cu * cx - su * cy),
            su,  cu, cy + u * ty - (su * cx + cu * cy));
        cv::warpAffine(src, tmp, M, src.size(), cv::INTER_LINEAR,
                       cv::BORDER_REFLECT);
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

// ---------------------------------------------------------------------------
// Per-block PSF preview (true field vs estimated field).
// ---------------------------------------------------------------------------

constexpr int kLabBlock = 256;
constexpr int kLabHop   = 128;

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

// Draw the PSF used at each block centre: T = len*(cos,sin), Phi = roll.
// arc=true traces the actual trajectory (true blur); arc=false draws the
// straight-line (L, theta) approximation the analytic sinc OTF uses.
// The kernel is normalized, fftshifted and shown in a fixed-size tile; the
// green dot is u = 0.  With roll the field visibly rotates/fans out.
cv::Mat psf_grid(int W, int H, float len, float angle_deg, float roll_deg,
                 bool arc, const std::string& title) {
    constexpr int kB = 128;      // preview kernel only; engines use 256
    constexpr int kTile = 48;
    constexpr int kGap = 2;
    constexpr int kLabel = 18;

    std::vector<int> vys, vxs;
    for (int vy = 0; vy <= H - kLabHop; vy += kLabHop) vys.push_back(vy);
    if ((H - kLabHop) % kLabHop) vys.push_back(H - kLabHop);
    for (int vx = 0; vx <= W - kLabHop; vx += kLabHop) vxs.push_back(vx);
    if ((W - kLabHop) % kLabHop) vxs.push_back(W - kLabHop);

    const int rows = static_cast<int>(vys.size());
    const int cols = static_cast<int>(vxs.size());
    const int cw = kTile + kGap, ch = kTile + kGap;
    cv::Mat g(kLabel + rows * ch, cols * cw, CV_8UC3, cv::Scalar(16, 16, 16));
    cv::putText(g, title, cv::Point(4, 13), cv::FONT_HERSHEY_SIMPLEX, 0.38,
                cv::Scalar(220, 220, 220), 1, cv::LINE_AA);

    const float th = angle_deg * static_cast<float>(CV_PI) / 180.0f;
    const float tx = len * std::cos(th);
    const float ty = len * std::sin(th);
    const float phi = roll_deg * static_cast<float>(CV_PI) / 180.0f;
    const float cx = 0.5f * W, cy = 0.5f * H;
    const int B2 = kB / 2;

    for (int r = 0; r < rows; ++r) {
        for (int c = 0; c < cols; ++c) {
            const int vx = vxs[c], vy = vys[r];
            const float rx = static_cast<float>(vx + kLabHop / 2) - cx;
            const float ry = static_cast<float>(vy + kLabHop / 2) - cy;
            const float ex = tx + (std::cos(phi) - 1.0f) * rx - std::sin(phi) * ry;
            const float ey = ty + std::sin(phi) * rx + (std::cos(phi) - 1.0f) * ry;

            cv::Mat k = cv::Mat::zeros(kB, kB, CV_32F);
            float minx = 1e9f, maxx = -1e9f, miny = 1e9f, maxy = -1e9f;
            for (int i = 0; i < 64; ++i) {
                const float u = static_cast<float>(i) / 63.0f;
                float sx, sy;
                if (arc) {
                    const float cu = std::cos(u * phi);
                    const float su = std::sin(u * phi);
                    sx = u * tx + (cu - 1.0f) * rx - su * ry;
                    sy = u * ty + su * rx + (cu - 1.0f) * ry;
                } else {
                    sx = u * ex;
                    sy = u * ey;
                }
                psf_splat(k, sx, sy, 1.0f / 64.0f);
                minx = std::min(minx, sx); maxx = std::max(maxx, sx);
                miny = std::min(miny, sy); maxy = std::max(maxy, sy);
            }

            cv::Mat ks;
            psf_fftshift(k, ks);
            int S = static_cast<int>(std::ceil(std::max(maxx - minx, maxy - miny))) + 7;
            S = std::clamp(S, 21, kB - 1);
            if ((S & 1) == 0) ++S;
            const int ccx = static_cast<int>(std::lround(B2 + 0.5 * (minx + maxx)));
            const int ccy = static_cast<int>(std::lround(B2 + 0.5 * (miny + maxy)));
            const int x0 = std::clamp(ccx - S / 2, 0, kB - S);
            const int y0 = std::clamp(ccy - S / 2, 0, kB - S);
            cv::Mat crop = ks(cv::Rect(x0, y0, S, S));
            double peak = 0.0;
            cv::minMaxLoc(crop, nullptr, &peak);
            cv::Mat t8;
            crop.convertTo(t8, CV_8U, peak > 0.0 ? 255.0 / peak : 0.0);
            cv::Mat tile;
            cv::resize(t8, tile, cv::Size(kTile, kTile), 0, 0, cv::INTER_LINEAR);
            cv::Mat tile_bgr;
            cv::cvtColor(tile, tile_bgr, cv::COLOR_GRAY2BGR);

            const double sc = kTile / static_cast<double>(S);
            const int ox = static_cast<int>(std::lround((B2 - x0) * sc));
            const int oy = static_cast<int>(std::lround((B2 - y0) * sc));
            if (ox >= 0 && ox < kTile && oy >= 0 && oy < kTile)
                cv::circle(tile_bgr, cv::Point(ox, oy), 2, cv::Scalar(0, 220, 0),
                           1, cv::LINE_AA);

            tile_bgr.copyTo(g(cv::Rect(c * cw, kLabel + r * ch, kTile, kTile)));
            cv::rectangle(g, cv::Rect(c * cw, kLabel + r * ch, kTile, kTile),
                          cv::Scalar(40, 40, 40), 1);
        }
    }
    return g;
}

// CPU-only reference with soft block blending.  Same per-block analytic OTF
// as the engines, but instead of copying the central 128x128 tile, the whole
// 256x256 filtered block is accumulated with a Hann window (WOLA, hop 128).
// This is the "CLAHE-like" weighted blend of neighbouring PSF estimates.
cv::Mat soft_deblur_cpu(const cv::Mat& src, const deblur::MotionParams& p) {
    constexpr int B = 256, HOP = 128;
    const int W = src.cols, H = src.rows;
    if (W < B || H < B) throw std::runtime_error("image must be at least 256x256");

    cv::Mat yuv, y;
    if (src.channels() == 3) {
        cv::cvtColor(src, yuv, cv::COLOR_BGR2YUV);
        cv::extractChannel(yuv, y, 0);
    } else {
        y = src;
    }
    cv::Mat yf;
    y.convertTo(yf, CV_32F);

    cv::Mat acc(H, W, CV_32F, cv::Scalar(0));
    cv::Mat wacc(H, W, CV_32F, cv::Scalar(0));

    // Periodic Hann with a small floor: the floor keeps the very frame border
    // alive, the 50% overlap still sums to a constant (normalized at the end).
    cv::Mat h1(1, B, CV_32F);
    for (int x = 0; x < B; ++x)
        h1.at<float>(0, x) = 0.05f + 0.95f * 0.5f *
            (1.0f - std::cos(2.0f * static_cast<float>(CV_PI) * x / B));
    cv::Mat win = h1.t() * h1;

    const float cx = 0.5f * W, cy = 0.5f * H;
    const float Tx = p.exposure * p.dx;
    const float Ty = p.exposure * p.dy;
    const float Phi = p.exposure * p.dalpha;
    const float cph = std::cos(Phi), sph = std::sin(Phi);
    const float nsr = p.nsr;
    auto sf = [](int k) { return (k < B / 2) ? k : k - B; };

    std::vector<int> vys, vxs;
    for (int vy = 0; vy <= H - HOP; vy += HOP) vys.push_back(vy);
    if ((H - HOP) % HOP) vys.push_back(H - HOP);
    for (int vx = 0; vx <= W - HOP; vx += HOP) vxs.push_back(vx);
    if ((W - HOP) % HOP) vxs.push_back(W - HOP);

    cv::Mat blk(B, B, CV_32F), blkc, g(B, B, CV_32FC2), prod, rec, recr;

    for (int vy : vys) {
        for (int vx : vxs) {
            const int bx = std::clamp(vx - HOP / 2, 0, W - B);
            const int by = std::clamp(vy - HOP / 2, 0, H - B);

            yf(cv::Rect(bx, by, B, B)).copyTo(blk);

            const float rx = static_cast<float>(vx + HOP / 2) - cx;
            const float ry = static_cast<float>(vy + HOP / 2) - cy;
            const float sx = Tx + (cph - 1.0f) * rx - sph * ry;
            const float sy = Ty + sph * rx + (cph - 1.0f) * ry;
            const float L = std::hypot(sx, sy);
            const float th = std::atan2(sy, sx);
            const float ct = std::cos(th), st = std::sin(th);

            for (int ky = 0; ky < B; ++ky) {
                cv::Vec2f* gr = g.ptr<cv::Vec2f>(ky);
                const float syf = static_cast<float>(sf(ky));
                for (int kx = 0; kx < B; ++kx) {
                    const float a = (L / B) * (sf(kx) * ct + syf * st);
                    const float pa = static_cast<float>(CV_PI) * a;
                    const float sc = (std::fabs(a) < 1e-9f) ? 1.0f : std::sin(pa) / pa;
                    const float d = sc * sc + nsr;
                    gr[kx] = cv::Vec2f(sc * std::cos(pa) / d,
                                       sc * std::sin(pa) / d);
                }
            }

            cv::dft(blk, blkc, cv::DFT_COMPLEX_OUTPUT, 0);
            cv::mulSpectrums(blkc, g, prod, 0);
            cv::dft(prod, rec, cv::DFT_INVERSE | cv::DFT_SCALE, 0);
            cv::extractChannel(rec, recr, 0);

            cv::Mat accRoi = acc(cv::Rect(bx, by, B, B));
            cv::Mat wRoi = wacc(cv::Rect(bx, by, B, B));
            accRoi += win.mul(recr);
            wRoi += win;
        }
    }

    cv::max(wacc, 1e-6f, wacc);
    cv::divide(acc, wacc, acc);
    cv::max(acc, 0.0f, acc);
    cv::min(acc, 255.0f, acc);
    cv::Mat yo;
    acc.convertTo(yo, CV_8U);

    if (src.channels() == 3) {
        cv::insertChannel(yo, yuv, 0);
        cv::Mat bgr;
        cv::cvtColor(yuv, bgr, cv::COLOR_YUV2BGR);
        return bgr;
    }
    return yo;
}

}  // namespace

int main(int argc, char** argv) {
    std::string in, out, backend = "cpu";
    double true_len = 20.0, true_ang = 0.0, true_roll = 0.0;
    double est_len = -1.0, est_ang = 0.0, est_roll = 0.0;
    bool have_est_ang = false, have_est_roll = false;
    double view_scale = 0.0;
    float exposure = 0.5f, nsr0 = 0.01f, noise = 0.0f;
    int iters = 0;
    bool gui = true, cli = false, wola = false;

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
        else if (a == "--roll")      true_roll = std::stod(next());
        else if (a == "--est-len")   est_len = std::stod(next());
        else if (a == "--est-angle") { est_ang = std::stod(next()); have_est_ang = true; }
        else if (a == "--est-roll")  { est_roll = std::stod(next()); have_est_roll = true; }
        else if (a == "--exposure")  exposure = std::stof(next());
        else if (a == "--nsr")       nsr0 = std::stof(next());
        else if (a == "--noise")     noise = std::stof(next());
        else if (a == "--view-scale") view_scale = std::stod(next());
        else if (a == "--iters")     iters = std::stoi(next());
        else if (a == "--no-gui")    gui = false;
        else if (a == "--cli")       { cli = true; gui = false; }
        else if (a == "--wola")      wola = true;
        else if (a == "-h" || a == "--help") {
            std::cout <<
                "usage: deblur_lab [--in IMG] [--out IMG] [--backend cpu|opencl|cuda|fpga]\n"
                "                  [--len 20] [--angle 0] [--roll 0]   true motion PSF\n"
                "                  [--est-len L] [--est-angle A] [--est-roll R]\n"
                "                  [--exposure 0.5] [--nsr 0.01] [--noise 0]\n"
                "                  [--view-scale S] [--iters N] [--no-gui] [--cli] [--wola]\n"
                "  --len/--angle: translation at the frame centre, --roll: deg around view axis\n"
                "  --exposure: only maps L/roll to MotionParams; the lab PSF is set in px\n"
                "  --wola: lab CPU reference with soft Hann block blending (vs hard tiles)\n"
                "  --in omitted: synthetic 1920x1080 test chart\n"
                "  GUI: TRUE PSF sliders in a separate window, ESTIMATE PSF in the main one\n"
                "  GUI keys: q/ESC quit, r reset estimate to true, b toggle hard/soft blend\n"
                "  --cli commands: l/a/roll (estimate), tl/ta/troll (true), n, b, r, q\n";
            return 0;
        } else { std::cerr << "unknown option: " << a << "\n"; return 1; }
    }
    if (exposure < 1e-3f) { std::cerr << "exposure must be > 0\n"; return 1; }
    if (!gui && !cli && iters == 0) iters = 1;  // batch without a stop condition

    // Integer slider values for the true PSF (same units as the estimate).
    int t_len = std::clamp(static_cast<int>(std::lround(true_len)), 0, 160);
    int t_ang = static_cast<int>(std::lround(true_ang)) % 360;
    if (t_ang < 0) t_ang += 360;
    int t_roll = std::clamp(static_cast<int>(std::lround(true_roll)) + 180, 0, 360);

    if (est_len < 0.0) est_len = t_len;
    if (!have_est_ang) est_ang = t_ang;
    if (!have_est_roll) est_roll = t_roll - 180;

    cv::Mat sharp = in.empty() ? make_chart() : cv::imread(in, cv::IMREAD_COLOR);
    if (sharp.empty()) { std::cerr << "cannot read " << in << "\n"; return 1; }
    if (sharp.cols < 256 || sharp.rows < 256) {
        std::cerr << "image must be at least 256x256\n";
        return 1;
    }

    std::cout << "true blur: L=" << t_len << " px  theta=" << t_ang
              << " deg  roll=" << (t_roll - 180)
              << " deg  (trailing, u in [0,1])\n";

    cv::Mat noise_img;
    if (noise > 0.0f) {
        noise_img.create(sharp.size(), CV_32FC3);
        cv::randn(noise_img, cv::Scalar::all(0), cv::Scalar::all(noise));
    }
    auto add_noise = [&](cv::Mat& img) {
        if (noise_img.empty()) return;
        cv::Mat f;
        img.convertTo(f, CV_32F);
        f += noise_img;
        f.convertTo(img, CV_8U);
    };

    cv::Mat blurred = motion_blur(sharp, static_cast<float>(t_len),
                                  static_cast<float>(t_ang),
                                  static_cast<float>(t_roll - 180));
    add_noise(blurred);
    double psnr_in = psnr_gray(blurred, sharp);
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

    const std::string win = "ESTIMATE PSF + filter  (q=quit, r=reset, b=blend)";
    const std::string win_true = "TRUE PSF  (real blur)";
    int s_len = static_cast<int>(std::lround(est_len));
    int s_ang = static_cast<int>(std::lround(est_ang)) % 360;
    if (s_ang < 0) s_ang += 360;
    int s_roll = static_cast<int>(std::lround(est_roll)) + 180;  // slider 0..360
    s_roll = std::clamp(s_roll, 0, 360);
    int s_nsr = static_cast<int>(std::lround(nsr0 * 1e4f));
    int s_blend = wola ? 1 : 0;
    if (gui) {
        // Group 1: the real blur applied to the input image.
        cv::namedWindow(win_true, cv::WINDOW_AUTOSIZE);
        cv::createTrackbar("L, px", win_true, &t_len, 160);
        cv::createTrackbar("theta, deg", win_true, &t_ang, 359);
        cv::createTrackbar("roll+180, deg", win_true, &t_roll, 360);

        // Group 2: the PSF estimate used by the filter.
        cv::namedWindow(win, cv::WINDOW_AUTOSIZE);
        cv::createTrackbar("EST L, px", win, &s_len, 160);
        cv::createTrackbar("EST theta, deg", win, &s_ang, 359);
        cv::createTrackbar("EST roll+180, deg", win, &s_roll, 360);
        cv::createTrackbar("nsr x1e-4", win, &s_nsr, 500);
        cv::createTrackbar("blend 0=hard 1=soft", win, &s_blend, 1);
    }
    if (wola)
        std::cout << "soft WOLA: lab CPU reference (backend ignored in this mode)\n";

    double vs = view_scale > 0.0
                    ? view_scale
                    : std::min(1.0, std::min(1800.0 / (2.0 * sharp.cols),
                                            1000.0 / (2.0 * sharp.rows)));
    const int pw = std::max(1, static_cast<int>(std::lround(sharp.cols * vs)));
    const int ph = std::max(1, static_cast<int>(std::lround(sharp.rows * vs)));
    std::cout << "view " << pw << "x" << ph << " per panel\n";

    cv::Mat mont, psf_side;
    long frame = 0;
    const double t0 = static_cast<double>(cv::getTickCount());
    int rendered_len = t_len, rendered_ang = t_ang, rendered_roll = t_roll;
    int prev_len = t_len, prev_ang = t_ang, prev_roll = t_roll;
    double last_true_change = static_cast<double>(cv::getTickCount()) /
                              cv::getTickFrequency();

    while (true) {
        const double now = static_cast<double>(cv::getTickCount()) /
                           cv::getTickFrequency();
        if (t_len != prev_len || t_ang != prev_ang || t_roll != prev_roll) {
            prev_len = t_len; prev_ang = t_ang; prev_roll = t_roll;
            last_true_change = now;
        }
        // Re-render the input only after the true-PSF slider has settled
        // (GUI); CLI changes are applied immediately.
        if (t_len != rendered_len || t_ang != rendered_ang ||
            t_roll != rendered_roll) {
            if (!gui || now - last_true_change > 0.25) {
                blurred = motion_blur(sharp, static_cast<float>(t_len),
                                      static_cast<float>(t_ang),
                                      static_cast<float>(t_roll - 180));
                add_noise(blurred);
                psnr_in = psnr_gray(blurred, sharp);
                rendered_len = t_len;
                rendered_ang = t_ang;
                rendered_roll = t_roll;
                std::cout << "[lab] true PSF -> L=" << t_len << " px  theta="
                          << t_ang << " deg  roll=" << (t_roll - 180)
                          << " deg  (input " << psnr_in << " dB)\n";
            }
        }

        const float L = static_cast<float>(s_len);
        const float th = static_cast<float>(s_ang) * static_cast<float>(CV_PI) / 180.0f;
        const int roll_deg = s_roll - 180;
        const float roll_rad = static_cast<float>(roll_deg) *
                               static_cast<float>(CV_PI) / 180.0f;
        const float nsr = std::max(0, s_nsr) * 1e-4f;

        deblur::MotionParams p;
        p.exposure = exposure;
        p.nsr = nsr;
        p.dx = L * std::cos(th) / exposure;
        p.dy = L * std::sin(th) / exposure;
        p.dalpha = roll_rad / exposure;

        cv::Mat deb;
        const bool soft = s_blend != 0;
        if (soft)
            deb = soft_deblur_cpu(blurred, p);
        else
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

            char t[200];
            panel_label(a, "sharp (ground truth)");
            std::snprintf(t, sizeof t,
                          "blurred  L=%d th=%d roll=%d  PSNR=%.2f dB",
                          rendered_len, rendered_ang, rendered_roll - 180, psnr_in);
            panel_label(b, t);
            std::snprintf(t, sizeof t,
                          "deblurred %s  est L=%.1f th=%d roll=%d nsr=%.4f  PSNR=%.2f dB",
                          soft ? "soft WOLA" : "hard tiles",
                          L, s_ang, roll_deg, nsr, psnr_d);
            panel_label(c, t);
            panel_label(d, "|deblurred - sharp| x4");

            mont.create(ph * 2, pw * 2, CV_8UC3);
            mont.setTo(cv::Scalar(18, 18, 18));
            a.copyTo(mont(cv::Rect(0, 0, pw, ph)));
            b.copyTo(mont(cv::Rect(pw, 0, pw, ph)));
            c.copyTo(mont(cv::Rect(0, ph, pw, ph)));
            d.copyTo(mont(cv::Rect(pw, ph, pw, ph)));
        }

        if (gui || cli || !out.empty() || frame == 0) {
            char tt[128];
            std::snprintf(tt, sizeof tt, "true PSF  L=%d th=%d roll=%d  (arc)",
                          rendered_len, rendered_ang, rendered_roll - 180);
            cv::Mat psf_true = psf_grid(sharp.cols, sharp.rows,
                                        static_cast<float>(rendered_len),
                                        static_cast<float>(rendered_ang),
                                        static_cast<float>(rendered_roll - 180),
                                        true, tt);
            std::snprintf(tt, sizeof tt, "engine PSF  L=%.0f th=%d roll=%d  (line)",
                          L, s_ang, roll_deg);
            cv::Mat psf_est = psf_grid(sharp.cols, sharp.rows, L, s_ang,
                                       static_cast<float>(roll_deg), false, tt);
            cv::Mat sep(psf_true.rows, 4, CV_8UC3, cv::Scalar(50, 50, 50));
            cv::hconcat(std::vector<cv::Mat>{psf_true, sep, psf_est}, psf_side);
            if (gui) {
                cv::imshow(win_true, psf_true);  // keep the TRUE control window visible
                cv::imshow("PSF per block: true | estimate", psf_side);
            }
        }

        if (cli || frame % 15 == 0) {
            const double sec = (static_cast<double>(cv::getTickCount()) - t0) /
                               cv::getTickFrequency();
            std::printf("[lab] iter %ld  est L=%.0f th=%d roll=%d nsr=%.4f  "
                        "%s  PSNR %.2f dB  (input %.2f dB)  %.1f fps\n",
                        frame, L, s_ang, roll_deg, nsr,
                        soft ? "soft" : "hard", psnr_d, psnr_in,
                        sec > 0 ? (frame + 1) / sec : 0.0);
            std::fflush(stdout);
        }

        if (gui) {
            cv::imshow(win, mont);
            const int key = cv::waitKey(1) & 0xff;
            if (key == 27 || key == 'q') break;
            if (key == 'b')
                cv::setTrackbarPos("blend 0=hard 1=soft", win, soft ? 0 : 1);
            if (key == 'r') {
                cv::setTrackbarPos("EST L, px", win, t_len);
                cv::setTrackbarPos("EST theta, deg", win, t_ang);
                cv::setTrackbarPos("EST roll+180, deg", win, t_roll);
                cv::setTrackbarPos("nsr x1e-4", win,
                                   static_cast<int>(std::lround(nsr0 * 1e4f)));
            }
        } else if (cli) {
            if (out.empty()) out = "deblur_lab.png";
            if (!cv::imwrite(out, mont))
                std::cerr << "cannot write " << out << "\n";
            const std::string psf_out = out + ".psf.png";
            if (!psf_side.empty() && !cv::imwrite(psf_out, psf_side))
                std::cerr << "cannot write " << psf_out << "\n";
            std::cout << "[lab] images: " << out << " , " << psf_out << "\n> "
                      << std::flush;

            std::string line;
            if (!std::getline(std::cin, line)) break;
            if (line == "q" || line == "quit" || line == "exit") break;
            if (line == "r") {
                s_len = t_len;
                s_ang = t_ang;
                s_roll = t_roll;
                s_nsr = static_cast<int>(std::lround(nsr0 * 1e4f));
            } else if (!line.empty()) {
                std::istringstream iss(line);
                std::string cmd;
                double val = 0.0;
                if (!(iss >> cmd >> val)) {
                    std::cout << "commands: l/a/roll (estimate), tl/ta/troll (true), "
                                 "n <nsr>, b <0|1>, r, q\n";
                } else if (cmd == "l") {
                    s_len = std::clamp(static_cast<int>(std::lround(val)), 0, 160);
                } else if (cmd == "a") {
                    int a = static_cast<int>(std::lround(val)) % 360;
                    if (a < 0) a += 360;
                    s_ang = a;
                } else if (cmd == "roll") {
                    s_roll = std::clamp(
                        static_cast<int>(std::lround(val)) + 180, 0, 360);
                } else if (cmd == "tl") {
                    t_len = std::clamp(static_cast<int>(std::lround(val)), 0, 160);
                } else if (cmd == "ta") {
                    int a = static_cast<int>(std::lround(val)) % 360;
                    if (a < 0) a += 360;
                    t_ang = a;
                } else if (cmd == "troll") {
                    t_roll = std::clamp(
                        static_cast<int>(std::lround(val)) + 180, 0, 360);
                } else if (cmd == "n") {
                    s_nsr = std::clamp(static_cast<int>(std::lround(val * 1e4)), 0, 500);
                } else if (cmd == "b") {
                    s_blend = (val >= 0.5) ? 1 : 0;
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
    if (!out.empty() && !psf_side.empty()) {
        const std::string p = out + ".psf.png";
        if (!cv::imwrite(p, psf_side))
            std::cerr << "cannot write " << p << "\n";
        else
            std::cout << "wrote " << p << "\n";
    }
    std::cout << "last estimate: L=" << s_len << " px  theta=" << s_ang
              << " deg  roll=" << (s_roll - 180) << " deg  nsr="
              << (s_nsr * 1e-4) << "\n";
    return 0;
}
