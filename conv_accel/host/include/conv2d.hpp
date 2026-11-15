#pragma once
#include <cstdint>

#include "userbar.hpp"

namespace accel {

// Control registers of the HLS conv2d kernel (Vitis HLS s_axi_control).
//   0x00 CTRL (bit0 ap_start, bit1 ap_done, bit2 ap_idle, bit3 ap_ready)
//   0x04 GIE, 0x08 IER, 0x0C ISR
//   0x10 rows, 0x18 cols, 0x20 shift
class Conv2d {
public:
    explicit Conv2d(UserBar& bar, uint32_t base);

    // rows/cols describe the frame, shift is the fixed-point normalisation
    // (out = clamp((sum k*p) >> shift)).
    void configure(int rows, int cols, int shift);
    void start();
    bool wait_done(int timeout_ms = 1000);

    uint32_t ctrl() const { return bar_.rd(base_ + 0x00); }

private:
    UserBar& bar_;
    uint32_t base_;
};

}  // namespace accel
