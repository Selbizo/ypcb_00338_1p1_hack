#pragma once
#include <cstdint>

namespace accel {

// mmap of the XDMA user BAR (/dev/xdma0_user): 32-bit register access.
class UserBar {
public:
    explicit UserBar(uint64_t size = 0x10000);  // whole 64K user BAR
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

}  // namespace accel
