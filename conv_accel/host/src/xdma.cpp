#include "xdma.hpp"

#include <cerrno>
#include <cstring>
#include <fcntl.h>
#include <stdexcept>
#include <unistd.h>

namespace accel {

namespace {

int open_dev(const std::string& path) {
    int fd = ::open(path.c_str(), O_RDWR);
    if (fd < 0)
        throw std::runtime_error("open " + path + ": " + std::strerror(errno));
    return fd;
}

uint64_t chunk_limit() {
    // The driver splits transfers internally; keep chunks below 4 GiB so the
    // offset arithmetic stays sane on 32-bit off_t builds.
    return 1ull << 30;
}

}  // namespace

Xdma::Xdma(const std::string& dev) {
    h2c_ = open_dev(dev + "_h2c_0");
    try {
        c2h_ = open_dev(dev + "_c2h_0");
    } catch (...) {
        ::close(h2c_);
        throw;
    }
}

Xdma::~Xdma() {
    if (h2c_ >= 0) ::close(h2c_);
    if (c2h_ >= 0) ::close(c2h_);
}

void Xdma::write(uint64_t axi_addr, const void* data, size_t bytes) {
    const char* p = static_cast<const char*>(data);
    size_t left = bytes;
    off_t off = static_cast<off_t>(axi_addr);

    while (left) {
        size_t chunk = left;
        if (chunk > chunk_limit()) chunk = chunk_limit();

        ssize_t n = ::pwrite(h2c_, p, chunk, off);
        if (n < 0)
            throw std::runtime_error(std::string("h2c pwrite: ") + std::strerror(errno));
        if (n == 0)
            throw std::runtime_error("h2c pwrite: short write");

        p += n;
        left -= static_cast<size_t>(n);
        off += n;
    }
}

void Xdma::read(uint64_t axi_addr, void* data, size_t bytes) {
    char* p = static_cast<char*>(data);
    size_t left = bytes;
    off_t off = static_cast<off_t>(axi_addr);

    while (left) {
        size_t chunk = left;
        if (chunk > chunk_limit()) chunk = chunk_limit();

        ssize_t n = ::pread(c2h_, p, chunk, off);
        if (n < 0)
            throw std::runtime_error(std::string("c2h pread: ") + std::strerror(errno));
        if (n == 0)
            throw std::runtime_error("c2h pread: short read");

        p += n;
        left -= static_cast<size_t>(n);
        off += n;
    }
}

}  // namespace accel
