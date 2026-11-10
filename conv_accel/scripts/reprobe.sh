#!/usr/bin/env bash
# Re-enumerate the FPGA PCIe device after a RUNTIME reconfiguration.
#
# Any JTAG programming / boot_hw_device resets the PCIe config space: the BARs
# go back to 0 while the kernel still holds the old assignment. Symptom:
#   lspci shows the region as [virtual]; xdma probe fails with
#   "Failed to detect XDMA config BAR".
#
# A cold boot does not need this.
set -euo pipefail

DEV="${1:-0000:04:00.0}"

if [ ! -d "/sys/bus/pci/devices/$DEV" ]; then
    echo "device $DEV not present; scanning bus"
    echo 1 > /sys/bus/pci/rescan
else
    echo 1 > "/sys/bus/pci/devices/$DEV/remove"
    sleep 1
    echo 1 > /sys/bus/pci/rescan
fi

sleep 2

# reload the driver so it re-probes the BAR / engine ids
modprobe -r xdma 2>/dev/null || true
modprobe xdma

sleep 1
lsmod | grep -w xdma || { echo "xdma module not loaded"; exit 1; }
ls /dev/xdma0_h2c_0 /dev/xdma0_c2h_0 >/dev/null 2>&1 || { echo "xdma char devices missing"; exit 1; }
echo "OK: $(lspci -s "${DEV#0000:}" | cut -d' ' -f2-)"
