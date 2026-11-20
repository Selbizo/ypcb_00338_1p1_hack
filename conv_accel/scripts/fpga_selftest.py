#!/usr/bin/env python3
"""Register-level Y-Wiener self-test with long timeouts (debug aid).

    sudo -n python3 scripts/fpga_selftest.py [W H] [timeout_s]

Drives AXI DMA #1 at user-BAR 0x2000 and the wiener kernel at 0x4000
(8 KB window, params[3][256] at +0x1000) exactly like deblur_fpga.cpp,
but polls slowly and prints the kernel/DMA state so a slow or stuck
kernel can be told apart.
"""
import mmap
import os
import struct
import sys
import time

USER = "/dev/xdma0_user"
H2C = "/dev/xdma0_h2c_0"
C2H = "/dev/xdma0_c2h_0"
BAR = 0x10000

DMA = 0x2000
KRN = 0x4000
PAR = 0x1000
IN_ADDR = 0x10000000
OUT_ADDR = 0x20000000

# AXI DMA simple-mode registers
TX_CR, TX_SR, TX_SRC, TX_LEN = 0x00, 0x04, 0x18, 0x28
RX_CR, RX_SR, RX_DST, RX_LEN = 0x30, 0x34, 0x48, 0x58


def main() -> int:
    W = int(sys.argv[1]) if len(sys.argv) > 1 else 256
    H = int(sys.argv[2]) if len(sys.argv) > 2 else 256
    timeout = float(sys.argv[3]) if len(sys.argv) > 3 else 120.0
    rx_rows = int(sys.argv[4]) if len(sys.argv) > 4 else H
    extra = int(sys.argv[5]) if len(sys.argv) > 5 else 0
    W = (W // 256) * 256
    H = (H // 256) * 256
    bytes_ = W * H * 4
    tx_bytes = (W * H + (int(sys.argv[5]) if len(sys.argv) > 5 else 0)) * 4

    fd = os.open(USER, os.O_RDWR | os.O_SYNC)
    bar = mmap.mmap(fd, BAR, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE)

    def rd(off):
        return struct.unpack_from("<I", bar, off)[0]

    def wr(off, val):
        struct.pack_into("<I", bar, off, val & 0xFFFFFFFF)

    nsamp = W * H + extra
    words = bytearray(nsamp * 4)
    for i in range(0, W * H):
        words[4 * i] = 128
    with open(H2C, "wb", buffering=0) as f:
        f.seek(IN_ADDR)
        f.write(words)
    print(f"frame {W}x{H}  {bytes_/1048576:.2f} MB in, tx {tx_bytes} B, rx {rx_rows} rows")
    with open(H2C, "wb", buffering=0) as f:  # zero the output buffer
        f.seek(OUT_ADDR)
        f.write(bytes(bytes_))

    # reset both channels, clear status
    for cr, sr in ((TX_CR, TX_SR), (RX_CR, RX_SR)):
        wr(DMA + cr, 0x4)
        t0 = time.time()
        while rd(DMA + cr) & 0x4:
            if time.time() - t0 > 1:
                print("reset timeout")
                return 1
            time.sleep(0.001)
        wr(DMA + sr, 0x7FFFFFFF)

    # params: Q1.15 integers, L/N = 0, cos = 1.0 (32767), sin = 0
    for i in range(3 * 256):
        wr(KRN + PAR + 4 * i, 0)
    for i in range(256):
        wr(KRN + PAR + 4 * (256 + i), 32767)
    wr(KRN + 0x10, W)
    wr(KRN + 0x18, H)

    # arm DMA: src/dst, then start
    wr(DMA + TX_SRC, IN_ADDR)
    wr(DMA + RX_DST, OUT_ADDR)
    wr(KRN, 1)  # ap_start
    wr(DMA + RX_CR, 1)
    rx_bytes = 4 if rx_rows == 0 else W * rx_rows * 4
    wr(DMA + RX_LEN, rx_bytes)
    wr(DMA + TX_CR, 1)
    wr(DMA + TX_LEN, tx_bytes)

    t0 = time.time()
    last = None
    while True:
        tx = rd(DMA + TX_SR)
        rx = rd(DMA + RX_SR)
        ctrl = rd(KRN)
        state = (tx, rx, ctrl)
        if state != last:
            print(f"t={time.time()-t0:7.2f}s  tx_sr=0x{tx:08X}  rx_sr=0x{rx:08X}  ctrl=0x{ctrl:08X}")
            last = state
        if (tx & 0x1000) and (rx & 0x1000):
            print("DMA done")
            break
        if (tx | rx) & 0x770:
            print("DMA error")
            return 2
        if ctrl & 2:
            print("kernel ap_done")
            break
        if time.time() - t0 > timeout:
            print(f"TIMEOUT after {timeout}s")
            break
        time.sleep(0.05)

    print(f"kernel regs: width={rd(KRN+0x10)} height={rd(KRN+0x18)} ctrl=0x{rd(KRN):08X}")
    print("dbg[]:", [rd(KRN + 0x40 + 4 * i) for i in range(10)])
    with open(C2H, "rb", buffering=0) as f:
        f.seek(OUT_ADDR)
        out = f.read(rx_bytes)
    nz = sum(1 for i in range(len(out)//4) if out[4 * i] != 0)
    rows = 0
    if rx_rows > 0:
        for y in range(rx_rows):
            if any(out[4 * (y * W + x)] != 0 for x in range(0, min(W, len(out)//4), 64)):
                rows += 1
    print(f"output: {nz}/{len(out)//4} non-zero, {rows}/{max(1,rx_rows)} rows touched")
    vals = [out[4 * i] for i in range(0, min(len(out)//4, 64))]
    print("first luma out:", vals[:16])
    return 0


if __name__ == "__main__":
    sys.exit(main())
