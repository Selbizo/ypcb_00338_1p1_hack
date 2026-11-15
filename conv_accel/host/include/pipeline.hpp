#pragma once
#include <cstdint>
#include <opencv2/core.hpp>

#include "axidma.hpp"
#include "conv2d.hpp"
#include "userbar.hpp"
#include "xdma.hpp"

namespace accel {

struct Timing {
    double upload_ms = 0.0;   // host -> card
    double process_ms = 0.0;  // on-card processing (0 for loopback)
    double download_ms = 0.0; // card -> host
};

// A video stage: takes a BGR frame, returns a BGR frame of the same size.
// The current implementation round-trips the frame through DDR3; the VDMA +
// kernel implementation will use the same interface.
class IVideoPipeline {
public:
    virtual ~IVideoPipeline() = default;
    virtual cv::Mat process(const cv::Mat& frame) = 0;
    virtual const Timing& timing() const = 0;
    virtual const char* name() const = 0;
};

// Stage 0: frame -> DDR3 -> frame. Proves the host/PCIe/DDR3 path.
class DdrLoopback final : public IVideoPipeline {
public:
    explicit DdrLoopback(Xdma& xdma, uint64_t addr = 0x0);

    cv::Mat process(const cv::Mat& frame) override;
    const Timing& timing() const override { return t_; }
    const char* name() const override { return "ddr-loopback"; }

private:
    Xdma& xdma_;
    uint64_t addr_;
    Timing t_;
};

// M1: frame -> DDR3 -> AXI DMA -> conv2d (5x5) -> AXI DMA -> DDR3 -> frame.
// The on-card stream is 32 bits/pixel (RGBX), so a BGR8 frame is widened to
// BGRA on the way in and narrowed back on the way out.
class AxidmaConv2d final : public IVideoPipeline {
public:
    // must match the HLS kernel (sum-256 5x5 Gaussian, shift 8)
    static constexpr int kShift = 8;

    AxidmaConv2d(Xdma& xdma, UserBar& bar,
                 uint64_t in_addr = 0x10000000ull,
                 uint64_t out_addr = 0x20000000ull);

    cv::Mat process(const cv::Mat& frame) override;
    const Timing& timing() const override { return t_; }
    const char* name() const override { return "axidma-conv2d-5x5"; }

private:
    Xdma& xdma_;
    UserBar& bar_;
    Axidma dma_;
    Conv2d conv_;
    uint64_t in_;
    uint64_t out_;
    Timing t_;
};

}  // namespace accel
