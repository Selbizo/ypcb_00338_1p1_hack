#pragma once
#include <cstddef>
#include <cstdint>
#include <string>

namespace accel {

// Thin RAII wrapper over the Xilinx XDMA character devices.
//
// The file offset of a transfer is the AXI address on the card (see
// docs/platform.md). Buffers must stay alive for the duration of the call;
// the driver pins them internally.
class Xdma {
public:
    explicit Xdma(const std::string& dev = "/dev/xdma0");
    ~Xdma();

    Xdma(const Xdma&) = delete;
    Xdma& operator=(const Xdma&) = delete;

    // Host -> card (H2C engine)
    void write(uint64_t axi_addr, const void* data, size_t bytes);
    // Card -> host (C2H engine)
    void read(uint64_t axi_addr, void* data, size_t bytes);

private:
    int h2c_ = -1;
    int c2h_ = -1;
};

}  // namespace accel
