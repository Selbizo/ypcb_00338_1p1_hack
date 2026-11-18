// OpenCL backend: same block-FFT Wiener, OpenCV T-API (cv::UMat).
// DFT, multiply and colour conversion run on the OpenCL device when available.
#include "deblur/deblur.h"

#include <opencv2/core.hpp>
#include <opencv2/core/ocl.hpp>
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

class OclEngine final : public Engine {
public:
    OclEngine() {
        if (!cv::ocl::haveOpenCL())
            throw std::runtime_error("deblur: OpenCL is not available");
        cv::ocl::setUseOpenCL(true);
    }

    const char* name() const override { return "opencl"; }

    void process(cv::InputArray src, cv::OutputArray dst, const MotionParams& p) override {
        cv::Mat s = src.getMat();
        if (s.empty()) throw std::runtime_error("deblur: empty input");
        const int W = s.cols, H = s.rows;
        if (W < kBlock || H < kBlock) throw std::runtime_error("deblur: frame smaller than 256x256");

        cv::UMat yuv, y;
        if (s.channels() == 3) {
            cv::cvtColor(s.getUMat(cv::ACCESS_READ), yuv, cv::COLOR_BGR2YUV);
            cv::extractChannel(yuv, y, 0);
        } else {
            y = s.getUMat(cv::ACCESS_READ);
        }

        cv::UMat yf;
        y.convertTo(yf, CV_32F);
        cv::UMat acc(H, W, CV_32F);
        acc.setTo(0);

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

        cv::UMat blk(kBlock, kBlock, CV_32F);
        cv::UMat blkc, spec, prod, rec, recr, g_um;
        cv::Mat g(kBlock, kBlock, CV_32FC2);

        for (int vy : vys) {
            for (int vx : vxs) {
                const int bx = std::clamp(vx - kHop / 2, 0, W - kBlock);
                const int by = std::clamp(vy - kHop / 2, 0, H - kBlock);
                const int ox = vx - bx;
                const int oy = vy - by;

                yf(cv::Rect(bx, by, kBlock, kBlock)).copyTo(blk);

                const float rx = static_cast<float>(vx + kHop / 2) - cx;
                const float ry = static_cast<float>(vy + kHop / 2) - cy;
                const float sx = Tx + (cph - 1.0f) * rx - sph * ry;
                const float sy = Ty + sph * rx + (cph - 1.0f) * ry;
                const float L = std::hypot(sx, sy);
                const float th = std::atan2(sy, sx);
                const float ct = std::cos(th), st = std::sin(th);

                // G is cheap on the host; upload the finished filter once
                for (int ky = 0; ky < kBlock; ++ky) {
                    cv::Vec2f* gr = g.ptr<cv::Vec2f>(ky);
                    const float syf = static_cast<float>(sfreq(ky));
                    for (int kx = 0; kx < kBlock; ++kx) {
                        const float a = (L / kBlock) * (sfreq(kx) * ct + syf * st);
                        const float pa = static_cast<float>(M_PI) * a;
                        const float sc = (std::fabs(a) < 1e-9f) ? 1.0f : std::sin(pa) / pa;
                        const float d = sc * sc + nsr;
                        gr[kx] = cv::Vec2f(sc * std::cos(pa) / d,
                                           sc * std::sin(pa) / d);
                    }
                }
                g.copyTo(g_um);

                cv::dft(blk, blkc, cv::DFT_COMPLEX_OUTPUT, 0);
                cv::mulSpectrums(blkc, g_um, prod, 0);
                cv::dft(prod, rec, cv::DFT_INVERSE | cv::DFT_SCALE, 0);
                cv::extractChannel(rec, recr, 0);

                recr(cv::Rect(ox, oy, kHop, kHop))
                    .copyTo(acc(cv::Rect(vx, vy, kHop, kHop)));
            }
        }

        cv::max(acc, 0.0f, acc);
        cv::min(acc, 255.0f, acc);
        cv::UMat yo;
        acc.convertTo(yo, CV_8U);

        if (s.channels() == 3) {
            cv::insertChannel(yo, yuv, 0);
            cv::UMat bgr;
            cv::cvtColor(yuv, bgr, cv::COLOR_YUV2BGR);
            dst.assign(bgr);
        } else {
            dst.assign(yo);
        }
    }
};

std::unique_ptr<Engine> makeOclEngine() {
    return std::unique_ptr<Engine>(new OclEngine());
}

}  // namespace deblur
