#include "vdma.hpp"

#include <cerrno>
#include <chrono>
#include <cstdio>
#include <cstring>
#include <fcntl.h>
#include <stdexcept>
#include <sys/mman.h>
#include <thread>
#include <unistd.h>

namespace accel {

namespace {
constexpr uint32_t kMm2sCr = 0x00;
constexpr uint32_t kMm2sSr = 0x04;
constexpr uint32_t kMm2sVsize = 0x50;
constexpr uint32_t kMm2sHsize = 0x54;
constexpr uint32_t kMm2sStride = 0x58;
constexpr uint32_t kMm2sStart = 0x5C;

constexpr uint32_t kS2mmCr = 0x30;
constexpr uint32_t kS2mmSr = 0x34;
constexpr uint32_t kS2mmVsize = 0xA0;
constexpr uint32_t kS2mmHsize = 0xA4;
constexpr uint32_t kS2mmStride = 0xA8;
constexpr uint32_t kS2mmStart = 0xAC;

constexpr uint32_t kCrRunStop = 0x00000001;
constexpr uint32_t kCrReset = 0x00000004;
constexpr uint32_t kCrFrameCntEn = 0x00000010;
constexpr uint32_t kSrHalted = 0x00000001;
constexpr uint32_t kSrIdle = 0x00000002;
}  // namespace

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

Vdma::Vdma(UserBar& bar, uint32_t base) : bar_(bar), base_(base) {}

void Vdma::setup(int width, int height, int bpp, uint64_t src, uint64_t dst) {
    const uint32_t line = static_cast<uint32_t>(width * bpp);
    // one frame per run: frame count in VSIZE[31:16], FrameCntEn in CR
    const uint32_t vsize = static_cast<uint32_t>(height) | (1u << 16);

    bar_.wr(base_ + kMm2sVsize, vsize);
    bar_.wr(base_ + kMm2sHsize, line);
    bar_.wr(base_ + kMm2sStride, line);  // stride | (frmdly << 24)
    bar_.wr(base_ + kMm2sStart, static_cast<uint32_t>(src));
    bar_.wr(base_ + kMm2sStart + 4, static_cast<uint32_t>(src >> 32));

    bar_.wr(base_ + kS2mmVsize, vsize);
    bar_.wr(base_ + kS2mmHsize, line);
    bar_.wr(base_ + kS2mmStride, line);
    bar_.wr(base_ + kS2mmStart, static_cast<uint32_t>(dst));
    bar_.wr(base_ + kS2mmStart + 4, static_cast<uint32_t>(dst >> 32));
}

void Vdma::start() {
    // clear stale status, then run one frame on both channels
    bar_.wr(base_ + kMm2sSr, 0xFFFFFFFF);
    bar_.wr(base_ + kS2mmSr, 0xFFFFFFFF);
    bar_.wr(base_ + kMm2sCr, kCrRunStop | kCrFrameCntEn);
    bar_.wr(base_ + kS2mmCr, kCrRunStop | kCrFrameCntEn);
}

uint32_t Vdma::mm2s_sr() const { return bar_.rd(base_ + kMm2sSr); }
uint32_t Vdma::s2mm_sr() const { return bar_.rd(base_ + kS2mmSr); }

bool Vdma::wait_done(int timeout_ms) {
    const auto t0 = std::chrono::steady_clock::now();
    for (;;) {
        const uint32_t m = mm2s_sr();
        const uint32_t s = s2mm_sr();
        const bool m_done = (m & kSrIdle) || (m & kSrHalted);
        const bool s_done = (s & kSrIdle) || (s & kSrHalted);
        if (m_done && s_done && !(m & 0x3F0) && !(s & 0x3F0)) return true;

        const auto dt = std::chrono::duration_cast<std::chrono::milliseconds>(
                            std::chrono::steady_clock::now() - t0).count();
        if (dt > timeout_ms) {
            std::fprintf(stderr, "vdma timeout: mm2s_sr=0x%08x s2mm_sr=0x%08x\n", m, s);
            return false;
        }
        std::this_thread::sleep_for(std::chrono::microseconds(200));
    }
}

}  // namespace accel
