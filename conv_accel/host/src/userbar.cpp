#include "userbar.hpp"

#include <cerrno>
#include <cstring>
#include <fcntl.h>
#include <stdexcept>
#include <sys/mman.h>
#include <unistd.h>

namespace accel {

UserBar::UserBar(uint64_t size) : size_(size) {
    fd_ = ::open("/dev/xdma0_user", O_RDWR | O_SYNC);
    if (fd_ < 0) throw std::runtime_error(std::string("open /dev/xdma0_user: ") + std::strerror(errno));
    void* m = ::mmap(nullptr, size_, PROT_READ | PROT_WRITE, MAP_SHARED, fd_, 0);
    if (m == MAP_FAILED) {
        ::close(fd_);
        throw std::runtime_error(std::string("mmap user BAR: ") + std::strerror(errno));
    }
    map_ = m;
}

UserBar::~UserBar() {
    if (map_) ::munmap(map_, size_);
    if (fd_ >= 0) ::close(fd_);
}

uint32_t UserBar::rd(uint32_t off) const {
    return *reinterpret_cast<volatile uint32_t*>(static_cast<char*>(map_) + off);
}

void UserBar::wr(uint32_t off, uint32_t val) {
    *reinterpret_cast<volatile uint32_t*>(static_cast<char*>(map_) + off) = val;
}

}  // namespace accel
