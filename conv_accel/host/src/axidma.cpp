#include "axidma.hpp"

#include <chrono>
#include <cstdio>
#include <thread>

namespace accel {

namespace {
constexpr uint32_t kTxCr = 0x00;
constexpr uint32_t kTxSr = 0x04;
constexpr uint32_t kTxSrcLo = 0x18;
constexpr uint32_t kTxSrcHi = 0x1C;
constexpr uint32_t kTxLen = 0x28;

constexpr uint32_t kRxCr = 0x30;
constexpr uint32_t kRxSr = 0x34;
constexpr uint32_t kRxDstLo = 0x48;
constexpr uint32_t kRxDstHi = 0x4C;
constexpr uint32_t kRxLen = 0x58;

constexpr uint32_t kCrRun = 0x00000001;
constexpr uint32_t kCrReset = 0x00000004;

constexpr uint32_t kSrHalted = 0x00000001;
constexpr uint32_t kSrIdle = 0x00000002;
constexpr uint32_t kSrErrAll = 0x00000770;
constexpr uint32_t kSrIoc = 0x00001000;
}  // namespace

Axidma::Axidma(UserBar& bar, uint32_t base) : bar_(bar), base_(base) {}

void Axidma::reset_channel(uint32_t cr_off) {
    bar_.wr(base_ + cr_off, kCrReset);
    for (int i = 0; i < 2000; ++i) {
        if (!(bar_.rd(base_ + cr_off) & kCrReset)) return;
        std::this_thread::sleep_for(std::chrono::microseconds(200));
    }
    std::fprintf(stderr, "axidma: channel reset did not complete (%#x)\n", cr_off);
}

void Axidma::setup(uint64_t src, uint64_t dst, uint32_t bytes) {
    reset_channel(kTxCr);
    reset_channel(kRxCr);
    // clear latched status (W1C)
    bar_.wr(base_ + kTxSr, 0x7FFFFFFF);
    bar_.wr(base_ + kRxSr, 0x7FFFFFFF);

    bar_.wr(base_ + kTxSrcLo, static_cast<uint32_t>(src));
    bar_.wr(base_ + kTxSrcHi, static_cast<uint32_t>(src >> 32));
    bar_.wr(base_ + kRxDstLo, static_cast<uint32_t>(dst));
    bar_.wr(base_ + kRxDstHi, static_cast<uint32_t>(dst >> 32));
    bytes_ = bytes;
}

void Axidma::start() {
    // arm the sink first, then the source; the LENGTH write starts each channel
    bar_.wr(base_ + kRxCr, kCrRun);
    bar_.wr(base_ + kRxLen, bytes_);
    bar_.wr(base_ + kTxCr, kCrRun);
    bar_.wr(base_ + kTxLen, bytes_);
}

uint32_t Axidma::mm2s_sr() const { return bar_.rd(base_ + kTxSr); }
uint32_t Axidma::s2mm_sr() const { return bar_.rd(base_ + kRxSr); }

bool Axidma::wait_done(int timeout_ms) {
    const auto t0 = std::chrono::steady_clock::now();
    for (;;) {
        const uint32_t tx = mm2s_sr();
        const uint32_t rx = s2mm_sr();
        if ((tx & kSrErrAll) || (rx & kSrErrAll)) {
            std::fprintf(stderr, "axidma error: mm2s_sr=%#010x s2mm_sr=%#010x\n", tx, rx);
            return false;
        }
        const bool tx_done = (tx & kSrIoc) && (tx & kSrIdle);
        const bool rx_done = (rx & kSrIoc) && (rx & kSrIdle);
        if (tx_done && rx_done) return true;

        const auto dt = std::chrono::duration_cast<std::chrono::milliseconds>(
                            std::chrono::steady_clock::now() - t0).count();
        if (dt > timeout_ms) {
            std::fprintf(stderr, "axidma timeout: mm2s_sr=%#010x s2mm_sr=%#010x\n", tx, rx);
            return false;
        }
        std::this_thread::sleep_for(std::chrono::microseconds(200));
    }
}

}  // namespace accel
