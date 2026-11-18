// CPU reference for the same block-FFT Wiener deconvolution.
// 256x256 blocks, hop 128, per-block analytic sinc OTF, Y only.
#include "deblur/deblur.h"

#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>

#include <algorithm>
#include <cmath>
#include <stdexcept>
#include <vector>

namespace deblur {
namespace {

constexpr int kBlock = 256;
constexpr int kHop = 128;

inline int sfreq(int k) { return (k < kBlock / 2) ? k : k - kBlock; }

}  // namespace

class CpuEngine final : public Engine {
public:
    const char* name() const override { return "cpu"; }

    void process(cv::InputArray src, cv::OutputArray dst, const MotionParams& p) override {
        cv::Mat s = src.getMat();
        if (s.empty()) throw std::runtime_error("deblur: empty input");
        const int W = s.cols, H = s.rows;
        if (W < kBlock || H < kBlock) throw std::runtime_error("deblur: frame smaller than 256x256");

        cv::Mat yuv, y;
        if (s.channels() == 3) {
            cv::cvtColor(s, yuv, cv::COLOR_BGR2YUV);
            cv::extractChannel(yuv, y, 0);
        } else {
            y = s;
        }

        cv::Mat yf;
        y.convertTo(yf, CV_32F);
        cv::Mat acc(H, W, CV_32F, cv::Scalar(0));

        const float cx = 0.5f * W, cy = 0.5f * H;
        const float Tx = p.exposure * p.dx;
        const float Ty = p.exposure * p.dy;
        const float Phi = p.exposure * p.dalpha;
        const float cph = std::cos(Phi), sph = std::sin(Phi);
        const float nsr = p.nsr;

        std::vector<int> vys, vxs;
        for (int vy = 0; vy <= H - kHop; vy += kHop) vys.push_back(vy);
        if ((H - kHop) % kHop) vys.push_back(H - kHop);
        for (int vx = 0; vx <= W - kHop; vx += kHop) vxs.push_back(vx);

        cv::Mat blk(kBlock, kBlock, CV_32F);
        cv::Mat blkc(kBlock, kBlock, CV_32FC2);
        cv::Mat spec(kBlock, kBlock, CV_32FC2);
        cv::Mat g(kBlock, kBlock, CV_32FC2);
        cv::Mat prod(kBlock, kBlock, CV_32FC2);
        cv::Mat rec(kBlock, kBlock, CV_32FC2);
        cv::Mat recr(kBlock, kBlock, CV_32F);
        cv::Mat planes[2] = {cv::Mat(kBlock, kBlock, CV_32F), cv::Mat(kBlock, kBlock, CV_32F)};

        for (int vy : vys) {
            for (int vx : vxs) {
                const int bx = std::clamp(vx - kHop / 2, 0, W - kBlock);
                const int by = std::clamp(vy - kHop / 2, 0, H - kBlock);
                const int ox = vx - bx;
                const int oy = vy - by;

                yf(cv::Rect(bx, by, kBlock, kBlock)).copyTo(blk);

                // local motion at the valid tile centre
                const float rx = static_cast<float>(vx + kHop / 2) - cx;
                const float ry = static_cast<float>(vy + kHop / 2) - cy;
                const float sx = Tx + (cph - 1.0f) * rx - sph * ry;
                const float sy = Ty + sph * rx + (cph - 1.0f) * ry;
                const float L = std::hypot(sx, sy);
                const float th = std::atan2(sy, sx);
                const float ct = std::cos(th), st = std::sin(th);

                // analytic sinc OTF -> Wiener filter
                for (int ky = 0; ky < kBlock; ++ky) {
                    cv::Vec2f* gr = g.ptr<cv::Vec2f>(ky);
                    const float syf = static_cast<float>(sfreq(ky));
                    for (int kx = 0; kx < kBlock; ++kx) {
                        const float a = (L / kBlock) *
                                        (sfreq(kx) * ct + syf * st);
                        const float pa = static_cast<float>(M_PI) * a;
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

                recr(cv::Rect(ox, oy, kHop, kHop))
                    .copyTo(acc(cv::Rect(vx, vy, kHop, kHop)));
            }
        }

        cv::max(acc, 0.0f, acc);
        cv::min(acc, 255.0f, acc);
        cv::Mat yo;
        acc.convertTo(yo, CV_8U);

        if (s.channels() == 3) {
            cv::insertChannel(yo, yuv, 0);
            cv::Mat bgr;
            cv::cvtColor(yuv, bgr, cv::COLOR_YUV2BGR);
            dst.assign(bgr);
        } else {
            dst.assign(yo);
        }
    }
};

std::unique_ptr<Engine> makeCpuEngine() {
    return std::unique_ptr<Engine>(new CpuEngine());
}

}  // namespace deblur
