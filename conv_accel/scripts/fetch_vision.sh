#!/usr/bin/env bash
# Fetch only the headers of Vitis Vision (successor of xfOpenCV).
# The library is header-only: no build, no install, no root.
#
# Pinned to Vitis Vision 2024.2 (tag v2024.2_update3) to match Vitis HLS 2024.2.
set -euo pipefail

COMMIT="e42643491a5851557fb392990d7be2e8139ae67b"   # refs/tags/v2024.2_update3
REPO="https://github.com/Xilinx/Vitis_Libraries.git"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${HERE}/../hls/third_party/vision"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

if [ -d "${DEST}/L1/include" ]; then
    echo "[fetch_vision] already present: ${DEST}/L1/include"
    exit 0
fi

echo "[fetch_vision] cloning ${REPO} (sparse, only vision/L1/include)"
git clone --filter=blob:none --sparse "${REPO}" "${TMP}/Vitis_Libraries"
git -C "${TMP}/Vitis_Libraries" checkout -q "${COMMIT}"
git -C "${TMP}/Vitis_Libraries" sparse-checkout set vision/L1/include

mkdir -p "${DEST}"
cp -r "${TMP}/Vitis_Libraries/vision/L1" "${DEST}/"
echo "[fetch_vision] done: $(du -sh "${DEST}" | cut -f1) in ${DEST}"
