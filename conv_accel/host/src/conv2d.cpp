#include "conv2d.hpp"

#include <chrono>
#include <cstdio>
#include <thread>

namespace accel {

namespace {
constexpr uint32_t kCtrl = 0x00;
constexpr uint32_t kRows = 0x10;
constexpr uint32_t kCols = 0x18;
constexpr uint32_t kShift = 0x20;

constexpr uint32_t kApStart = 1u << 0;
constexpr uint32_t kApDone = 1u << 1;
}  // namespace

Conv2d::Conv2d(UserBar& bar, uint32_t base) : bar_(bar), base_(base) {}

void Conv2d::configure(int rows, int cols, int shift) {
    bar_.wr(base_ + kRows, static_cast<uint32_t>(rows));
    bar_.wr(base_ + kCols, static_cast<uint32_t>(cols));
    bar_.wr(base_ + kShift, static_cast<uint32_t>(shift));
}

void Conv2d::start() { bar_.wr(base_ + kCtrl, kApStart); }

bool Conv2d::wait_done(int timeout_ms) {
    const auto t0 = std::chrono::steady_clock::now();
    for (;;) {
        const uint32_t c = ctrl();
        if (c & kApDone) return true;
        const auto dt = std::chrono::duration_cast<std::chrono::milliseconds>(
                            std::chrono::steady_clock::now() - t0).count();
        if (dt > timeout_ms) {
            std::fprintf(stderr, "conv2d timeout: ctrl=%#010x\n", c);
            return false;
        }
        std::this_thread::sleep_for(std::chrono::microseconds(100));
    }
}

}  // namespace accel
