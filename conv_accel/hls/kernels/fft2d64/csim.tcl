set here [file normalize [file dirname [info script]]]
set work "/tmp/conv_accel_hls/fft2d64_csim"
set hdr  "/mnt/tools/Xilinx/Vitis/2024.2/common/technology/autopilot/hls_fft.h"
file delete -force $work
file mkdir $work
file copy -force "$here/fft2d64.cpp"    "$work/fft2d64.cpp"
file copy -force "$here/fft2d64_tb.cpp" "$work/fft2d64_tb.cpp"
file copy -force $hdr "$work/hls_fft_rt.h"
exec sed -i {s/"nonrealtime"/"realtime"/g} "$work/hls_fft_rt.h"
cd $work
open_project -reset "$work/fft2d64_prj"
set_top fft2d64
add_files fft2d64.cpp -cflags "-I$work -std=c++14"
add_files -tb fft2d64_tb.cpp -cflags "-I$work -std=c++14"
open_solution -reset solution1 -flow_target vivado
set_part xc7k480tffg1156-2
create_clock -period 4.000 -name default
csim_design
exit
