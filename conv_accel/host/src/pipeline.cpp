#include "pipeline.hpp"

#include <chrono>

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

VdmaPassthrough::VdmaPassthrough(Xdma& xdma, UserBar& bar, uint64_t in_addr, uint64_t out_addr)
    : xdma_(xdma), bar_(bar), vdma_(bar, 0x0), in_(in_addr), out_(out_addr) {}

cv::Mat VdmaPassthrough::process(const cv::Mat& frame) {
    cv::Mat src = frame.isContinuous() ? frame : frame.clone();
    cv::Mat dst(src.size(), src.type());
    const size_t bytes = src.total() * src.elemSize();

    auto t0 = std::chrono::steady_clock::now();
    xdma_.write(in_, src.data, bytes);
    t_.upload_ms = since_ms(t0);

    vdma_.setup(src.cols, src.rows, static_cast<int>(src.elemSize()), in_, out_);
    t0 = std::chrono::steady_clock::now();
    vdma_.start();
    if (!vdma_.wait_done(50)) throw std::runtime_error("VDMA transfer failed");
    t_.process_ms = since_ms(t0);

    t0 = std::chrono::steady_clock::now();
    xdma_.read(out_, dst.data, bytes);
    t_.download_ms = since_ms(t0);

    return dst;
}

}  // namespace accel
