#!/usr/bin/env bash
# Build all HLS kernels and put them into hw/ip_repo.
# Vitis HLS rejects paths with spaces, each build.tcl takes care of that.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for k in passthrough conv2d; do
    echo "=== HLS: $k ==="
    ( cd "$HERE/kernels/$k" && vitis_hls -f build.tcl )
done

echo "=== done: $(ls "$HERE/../hw/ip_repo" 2>/dev/null | tr '\n' ' ')"
