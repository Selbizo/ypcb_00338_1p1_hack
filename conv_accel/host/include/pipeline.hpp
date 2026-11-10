#pragma once
#include <cstdint>
#include <opencv2/core.hpp>

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

}  // namespace accel
