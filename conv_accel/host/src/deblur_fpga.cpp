// FPGA backend for deblur::Engine (Y-plane Wiener on YPCB-00338-1P1).
//
// Data path:
//   BGR frame -> Y (cv::cvtColor) -> 32-bit words -> DDR3 (XDMA)
//   AXI DMA #1 -> wiener kernel -> 16 xfft -> AXI DMA #1 -> DDR3
//   Y -> merge with original chroma -> BGR
#include "deblur/deblur.h"

#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>

#include <chrono>
#include <cmath>
#include <cstring>
#include <stdexcept>
#include <thread>
#include <vector>

#include "axidma.hpp"
#include "userbar.hpp"
#include "xdma.hpp"

namespace deblur {
namespace {

constexpr uint32_t kDmaBase    = 0x2000;  // AXI DMA #1 (user BAR offset)
constexpr uint32_t kKernelBase = 0x4000;  // wiener s_axilite (8 KB window)
constexpr uint32_t kParamsOff  = 0x1000;  // params[3][256] inside s_axilite
constexpr uint64_t kInAddr     = 0x10000000ull;
constexpr uint64_t kOutAddr    = 0x20000000ull;
constexpr int kBlock = 256;
constexpr int kHop   = 128;
constexpr int kMaxBlocks = 256;

// Q1.15 packing: the kernel takes the low 16 bits of each 32-bit word and
// reinterprets them as ap_fixed<16,1> (no float IP inside the kernel).
inline uint32_t q15(float v) {
    float x = v * 32768.0f;
    if (x > 32767.0f) x = 32767.0f;
    if (x < -32768.0f) x = -32768.0f;
    return static_cast<uint32_t>(static_cast<int32_t>(std::lrintf(x)));
}

}  // namespace

class FpgaEngine final : public Engine {
public:
    FpgaEngine()
        : bar_(), dma_(bar_, kDmaBase), xdma_() {}

    const char* name() const override { return "fpga"; }

    void process(cv::InputArray src, cv::OutputArray dst, const MotionParams& p) override {
        cv::Mat s = src.getMat();
        if (s.empty()) throw std::runtime_error("deblur: empty input");
        const int W = s.cols, H = s.rows;
        if (W < kBlock || H < kBlock) throw std::runtime_error("deblur: frame smaller than 256x256");

        // luma
        cv::Mat yuv, y;
        if (s.channels() == 3) {
            cv::cvtColor(s, yuv, cv::COLOR_BGR2YUV);
            cv::extractChannel(yuv, y, 0);
        } else {
            y = s;
        }

        const size_t n = static_cast<size_t>(W) * H;
        const size_t bytes = n * 4;
        if (bytes > accel::Axidma::kMaxBytes)
            throw std::runtime_error("deblur: frame exceeds the AXI DMA limit");

        // Y -> 32-bit words (low byte carries luma)
        std::vector<uint32_t> in(n);
        for (size_t i = 0; i < n; ++i) in[i] = y.data[i];

        xdma_.write(kInAddr, in.data(), bytes);

        // per-block G parameters: (L/N, cos theta, sin theta)
        std::vector<uint32_t> params(3 * kMaxBlocks, 0u);
        const float cx = 0.5f * W, cy = 0.5f * H;
        const float Tx = p.exposure * p.dx;
        const float Ty = p.exposure * p.dy;
        const float Phi = p.exposure * p.dalpha;
        const float cph = std::cos(Phi), sph = std::sin(Phi);

        int idx = 0;
        auto add_block = [&](int vy, int vx) {
            const float rx = (vx + kBlock / 4) - cx;  // valid tile centre = vx + 64
            const float ry = (vy + kBlock / 4) - cy;
            const float sx = Tx + (cph - 1.0f) * rx - sph * ry;
            const float sy = Ty + sph * rx + (cph - 1.0f) * ry;
            const float L = std::hypot(sx, sy);
            const float th = std::atan2(sy, sx);
            if (idx >= kMaxBlocks) throw std::runtime_error("deblur: too many blocks");
            params[0 * kMaxBlocks + idx] = q15(L / static_cast<float>(kBlock));
            params[1 * kMaxBlocks + idx] = q15(std::cos(th));
            params[2 * kMaxBlocks + idx] = q15(std::sin(th));
            ++idx;
        };

        const int last_vy = H - kHop;
        for (int vy = 0; vy <= last_vy; vy += kHop)
            for (int vx = 0; vx <= W - kHop; vx += kHop) add_block(vy, vx);
        if ((last_vy % kHop) != 0)
            for (int vx = 0; vx <= W - kHop; vx += kHop) add_block(last_vy, vx);

        for (int i = 0; i < 3 * kMaxBlocks; ++i)
            bar_.wr(kKernelBase + kParamsOff + 4u * i, params[i]);
        bar_.wr(kKernelBase + 0x10, static_cast<uint32_t>(W));  // width
        bar_.wr(kKernelBase + 0x18, static_cast<uint32_t>(H));  // height
        bar_.wr(kKernelBase, 1u);                               // ap_start

        std::vector<uint32_t> ob(n);
        dma_.setup(kInAddr, kOutAddr, static_cast<uint32_t>(bytes));
        dma_.start();
        if (!dma_.wait_done(5000)) throw std::runtime_error("deblur: AXI DMA failed");

        bool done = false;
        for (int t = 0; t < 10000; ++t) {
            if (bar_.rd(kKernelBase) & 2u) { done = true; break; }
            std::this_thread::sleep_for(std::chrono::milliseconds(1));
        }
        if (!done) throw std::runtime_error("deblur: kernel timeout");

        xdma_.read(kOutAddr, ob.data(), bytes);

        cv::Mat yo(H, W, CV_8U);
        for (size_t i = 0; i < n; ++i) yo.data[i] = static_cast<uchar>(ob[i] & 0xFFu);

        if (s.channels() == 3) {
            cv::insertChannel(yo, yuv, 0);
            cv::Mat bgr;
            cv::cvtColor(yuv, bgr, cv::COLOR_YUV2BGR);
            dst.assign(bgr);
        } else {
            dst.assign(yo);
        }
    }

private:
    accel::UserBar bar_;
    accel::Axidma dma_;
    accel::Xdma xdma_;
};

std::unique_ptr<Engine> makeFpgaEngine() {
    return std::unique_ptr<Engine>(new FpgaEngine());
}

}  // namespace deblur
