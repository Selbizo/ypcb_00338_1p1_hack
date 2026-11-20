#!/usr/bin/env python3
"""Read the YPCB-00338-1P1 user BAR and print the AXI-Lite device state.

    sudo -n python3 scripts/bar_probe.py

The user BAR is 64 KB. Expected map (see scripts/fix_bd_addresses.tcl):

    0x0000  4K  axi_dma_0   (platform frame DMA)
    0x1000  4K  conv2d_0    (platform kernel)
    0x2000  4K  axi_dma_1   (deblur frame DMA)
    0x4000  8K  wiener_0    (deblur kernel, params at +0x1000)

Unmapped offsets read 0xFFFFFFFF. A missing device or a wrong bitstream is
visible immediately: e.g. dma1 = 0xFFFFFFFF means the loaded image does not
decode 0x2000 (old platform image or broken address map).
"""
import mmap
import os
import struct
import sys

USER = "/dev/xdma0_user"
BAR_SIZE = 0x10000


def main() -> int:
    try:
        fd = os.open(USER, os.O_RDWR | os.O_SYNC)
    except OSError as exc:
        print(f"open {USER}: {exc}", file=sys.stderr)
        print("(needs root and a configured FPGA)", file=sys.stderr)
        return 1

    with mmap.mmap(fd, BAR_SIZE, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE) as bar:
        def rd(off: int) -> int:
            return struct.unpack_from("<I", bar, off)[0]

        rows = [
            ("dma0   MM2S_DMACR", 0x0000),
            ("dma0   MM2S_DMASR", 0x0004),
            ("dma0   S2MM_DMACR", 0x0030),
            ("dma0   S2MM_DMASR", 0x0034),
            ("conv2d CTRL      ", 0x1000),
            ("dma1   MM2S_DMACR", 0x2000),
            ("dma1   MM2S_DMASR", 0x2004),
            ("dma1   S2MM_DMACR", 0x2030),
            ("dma1   S2MM_DMASR", 0x2034),
            ("wiener CTRL      ", 0x4000),
            ("wiener width     ", 0x4010),
            ("wiener height    ", 0x4018),
            ("wiener params[0] ", 0x5000),
        ]
        for name, off in rows:
            print(f"0x{off:04X}  {name} = 0x{rd(off):08X}")

        print()
        ok = rd(0x2004) != 0xFFFFFFFF and rd(0x4000) != 0xFFFFFFFF
        print("deblur blocks present:", "YES" if ok else "NO")
        if not ok:
            print("  -> flash/JTAG image does not decode 0x2000/0x4000")
        return 0 if ok else 2


if __name__ == "__main__":
    sys.exit(main())
