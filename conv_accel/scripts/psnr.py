#!/usr/bin/env python3
"""PSNR between two images (deblur validation helper)."""
import sys

import cv2
import numpy as np


def main() -> int:
    if len(sys.argv) < 3:
        print("usage: psnr.py a.png b.png", file=sys.stderr)
        return 1
    a = cv2.imread(sys.argv[1], cv2.IMREAD_COLOR)
    b = cv2.imread(sys.argv[2], cv2.IMREAD_COLOR)
    if a is None or b is None:
        print("cannot read inputs", file=sys.stderr)
        return 1
    if a.shape != b.shape:
        print(f"shape mismatch: {a.shape} vs {b.shape}", file=sys.stderr)
        return 1
    d = a.astype(np.float64) - b.astype(np.float64)
    mse = float(np.mean(d * d))
    if mse == 0.0:
        print("PSNR: inf (identical)")
        return 0
    print(f"PSNR: {10.0 * np.log10(255.0 * 255.0 / mse):.2f} dB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
