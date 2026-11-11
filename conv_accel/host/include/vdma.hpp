#pragma once
#include <cstdint>
#include <string>

namespace accel {

// mmap of the XDMA user BAR (/dev/xdma0_user): 32-bit register access.
class UserBar {
public:
    explicit UserBar(uint64_t size = 0x1000);
    ~UserBar();

    UserBar(const UserBar&) = delete;
    UserBar& operator=(const UserBar&) = delete;

    uint32_t rd(uint32_t off) const;
    void wr(uint32_t off, uint32_t val);

private:
    int fd_ = -1;
    void* map_ = nullptr;
    uint64_t size_ = 0;
};

// AXI VDMA (direct register mode, no SG) on top of the user BAR.
// Register map per PG020 / xaxivdma_hw.h:
//   MM2S: CR 0x00, SR 0x04, VSIZE 0x50, HSIZE 0x54, STRIDE_FRMDLY 0x58, START 0x5C
//   S2MM: CR 0x30, SR 0x34, VSIZE 0xA0, HSIZE 0xA4, STRIDE_FRMDLY 0xA8, START 0xAC
class Vdma {
public:
    explicit Vdma(UserBar& bar, uint32_t base = 0x0);

    // bytes_per_pixel * width = line size in bytes; stride == line size.
    void setup(int width, int height, int bytes_per_pixel, uint64_t src, uint64_t dst);
    void start();
    bool wait_done(int timeout_ms = 3000);

    uint32_t mm2s_sr() const;
    uint32_t s2mm_sr() const;

private:
    UserBar& bar_;
    uint32_t base_;
};

}  // namespace accel
