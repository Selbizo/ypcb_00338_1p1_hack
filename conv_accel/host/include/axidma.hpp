#pragma once
#include <cstdint>

#include "userbar.hpp"

namespace accel {

// AXI DMA (simple mode, no scatter-gather) on top of the user BAR.
// Register map per PG021 / xaxidma_hw.h:
//   TX/MM2S: CR 0x00, SR 0x04, SRC_ADDR 0x18 (+MSB 0x1C), LENGTH 0x28
//   RX/S2MM: CR 0x30, SR 0x34, DST_ADDR 0x48 (+MSB 0x4C), LENGTH 0x58
// A write to LENGTH starts the transfer; LENGTH is write-only (reads as 0).
class Axidma {
public:
    explicit Axidma(UserBar& bar, uint32_t base = 0x0);

    // One transfer of `bytes` from src to dst through the on-card stream path
    // (MM2S -> S2MM loopback until the kernel is inserted).
    void setup(uint64_t src, uint64_t dst, uint32_t bytes);
    void start();
    bool wait_done(int timeout_ms = 3000);

    uint32_t mm2s_sr() const;
    uint32_t s2mm_sr() const;

    // Maximum bytes per transfer in simple mode (C_SG_LENGTH_WIDTH=26).
    static constexpr uint32_t kMaxBytes = (1u << 26) - 1;

private:
    void reset_channel(uint32_t cr_off);
    UserBar& bar_;
    uint32_t base_;
    uint32_t bytes_ = 0;
};

}  // namespace accel
