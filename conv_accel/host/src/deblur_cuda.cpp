// CUDA backend: same block-FFT Wiener on cv::cuda::GpuMat.
// The analytic G is built on the host (cheap) and uploaded once per block.
#include "deblur/deblur.h"

#include <opencv2/core.hpp>
#include <opencv2/core/cuda.hpp>
#include <opencv2/cudaarithm.hpp>
#include <opencv2/cudaimgproc.hpp>

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

class CudaEngine final : public Engine {
public:
    CudaEngine() {
        if (cv::cuda::getCudaEnabledDeviceCount() <= 0)
            throw std::runtime_error("deblur: no CUDA device");
        cv::cuda::setDevice(0);
    }

    const char* name() const override { return "cuda"; }

    void process(cv::InputArray src, cv::OutputArray dst, const MotionParams& p) override {
        cv::Mat s = src.getMat();
        if (s.empty()) throw std::runtime_error("deblur: empty input");
        const int W = s.cols, H = s.rows;
        if (W < kBlock || H < kBlock) throw std::runtime_error("deblur: frame smaller than 256x256");

        cv::cuda::GpuMat sg;
        sg.upload(s);

        cv::cuda::GpuMat yuv, yf;
        std::vector<cv::cuda::GpuMat> chans;
        if (s.channels() == 3) {
            cv::cuda::cvtColor(sg, yuv, cv::COLOR_BGR2YUV);
            cv::cuda::split(yuv, chans);
            chans[0].convertTo(yf, CV_32F);
        } else {
            sg.convertTo(yf, CV_32F);
        }

        cv::cuda::GpuMat acc(H, W, CV_32F);
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

        cv::cuda::GpuMat blk(kBlock, kBlock, CV_32F);
        cv::cuda::GpuMat zero(kBlock, kBlock, CV_32F);
        zero.setTo(0);
        cv::cuda::GpuMat blk2;
        std::vector<cv::cuda::GpuMat> planes(2);
        std::vector<cv::cuda::GpuMat> rch;
        cv::cuda::GpuMat blkc, prod, rec, g_gpu;
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
                g_gpu.upload(g);

                planes[0] = blk; planes[1] = zero;
                cv::cuda::merge(planes, blk2);
                cv::cuda::dft(blk2, blkc, cv::Size(kBlock, kBlock));
                cv::cuda::mulSpectrums(blkc, g_gpu, prod, 0);
                cv::cuda::dft(prod, rec, cv::Size(kBlock, kBlock),
                              cv::DFT_INVERSE | cv::DFT_SCALE);
                cv::cuda::split(rec, rch);

                rch[0](cv::Rect(ox, oy, kHop, kHop))
                    .copyTo(acc(cv::Rect(vx, vy, kHop, kHop)));
            }
        }

        cv::cuda::GpuMat yo;
        acc.convertTo(yo, CV_8U);  // saturates to [0,255]

        if (s.channels() == 3) {
            yo.copyTo(chans[0]);
            cv::cuda::GpuMat yuv2, bgr;
            cv::cuda::merge(chans, yuv2);
            cv::cuda::cvtColor(yuv2, bgr, cv::COLOR_YUV2BGR);
            cv::Mat out;
            bgr.download(out);
            dst.assign(out);
        } else {
            cv::Mat out;
            yo.download(out);
            dst.assign(out);
        }
    }
};

std::unique_ptr<Engine> makeCudaEngine() {
    return std::unique_ptr<Engine>(new CudaEngine());
}

}  // namespace deblur
