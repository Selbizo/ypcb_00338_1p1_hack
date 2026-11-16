# C simulation of the 512-point fixed-point FFT (Q1.15) against a DFT reference.
# Switches the FFT IP throttle scheme to "realtime" in a private copy of hls_fft.h.
set here [file normalize [file dirname [info script]]]
set work "/tmp/conv_accel_hls/fft512_fixed_csim"
set hdr  "/mnt/tools/Xilinx/Vitis/2024.2/common/technology/autopilot/hls_fft.h"

file delete -force $work
file mkdir $work
file copy -force "$here/fft512_fixed.cpp"    "$work/fft512_fixed.cpp"
file copy -force "$here/fft512_fixed_tb.cpp" "$work/fft512_fixed_tb.cpp"
file copy -force $hdr "$work/hls_fft_rt.h"
exec sed -i {s/"nonrealtime"/"realtime"/g} "$work/hls_fft_rt.h"
cd $work

open_project -reset "$work/fft512_fixed_prj"
set_top fft512_fixed
add_files fft512_fixed.cpp -cflags "-I$work -std=c++14"
add_files -tb fft512_fixed_tb.cpp -cflags "-I$work -std=c++14"
open_solution -reset solution1 -flow_target vivado
set_part xc7k480tffg1156-2
create_clock -period 4.000 -name default
csim_design
exit
