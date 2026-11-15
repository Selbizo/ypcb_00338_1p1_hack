#include "pipeline.hpp"

#include <opencv2/imgproc.hpp>

#include <chrono>
#include <stdexcept>

namespace accel {

namespace {

double since_ms(std::chrono::steady_clock::time_point t0) {
    return std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - t0).count();
}

}  // namespace

DdrLoopback::DdrLoopback(Xdma& xdma, uint64_t addr) : xdma_(xdma), addr_(addr) {}

cv::Mat DdrLoopback::process(const cv::Mat& frame) {
    // DMA needs one contiguous buffer: BGR8 is 3 bytes/pixel.
    cv::Mat src = frame.isContinuous() ? frame : frame.clone();
    cv::Mat dst(src.size(), src.type());

    const size_t bytes = src.total() * src.elemSize();

    auto t0 = std::chrono::steady_clock::now();
    xdma_.write(addr_, src.data, bytes);
    t_.upload_ms = since_ms(t0);

    t_.process_ms = 0.0;

    t0 = std::chrono::steady_clock::now();
    xdma_.read(addr_, dst.data, bytes);
    t_.download_ms = since_ms(t0);

    return dst;
}

AxidmaConv2d::AxidmaConv2d(Xdma& xdma, UserBar& bar, uint64_t in_addr, uint64_t out_addr)
    : xdma_(xdma), bar_(bar), dma_(bar, 0x0), conv_(bar, 0x1000), in_(in_addr), out_(out_addr) {}

cv::Mat AxidmaConv2d::process(const cv::Mat& frame) {
    cv::Mat bgr = frame.isContinuous() ? frame : frame.clone();
    cv::Mat bgra;
    if (bgr.channels() == 3) {
        cv::cvtColor(bgr, bgra, cv::COLOR_BGR2BGRA);
    } else {
        bgra = bgr;
    }

    const size_t bytes = bgra.total() * bgra.elemSize();
    if (bytes > Axidma::kMaxBytes) throw std::runtime_error("frame exceeds the AXI DMA transfer limit");

    auto t0 = std::chrono::steady_clock::now();
    xdma_.write(in_, bgra.data, bytes);
    t_.upload_ms = since_ms(t0);

    // start the kernel first, then the DMA; both must finish for a frame
    conv_.configure(bgra.rows, bgra.cols, kShift);
    conv_.start();

    cv::Mat out(bgra.size(), bgra.type());
    dma_.setup(in_, out_, static_cast<uint32_t>(bytes));
    t0 = std::chrono::steady_clock::now();
    dma_.start();
    if (!dma_.wait_done(3000)) throw std::runtime_error("AXI DMA transfer failed");
    if (!conv_.wait_done(3000)) throw std::runtime_error("conv2d kernel did not finish");
    t_.process_ms = since_ms(t0);

    t0 = std::chrono::steady_clock::now();
    xdma_.read(out_, out.data, bytes);
    t_.download_ms = since_ms(t0);

    if (out.channels() == 4 && bgr.channels() == 3) {
        cv::Mat bgr_out;
        cv::cvtColor(out, bgr_out, cv::COLOR_BGRA2BGR);
        return bgr_out;
    }
    return out;
}

}  // namespace accel
