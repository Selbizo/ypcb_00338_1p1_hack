set here [file normalize [file dirname [info script]]]
set work "/tmp/conv_accel_hls/wiener_block_csim"
set hdr  "/mnt/tools/Xilinx/Vitis/2024.2/common/technology/autopilot/hls_fft.h"
file delete -force $work
file mkdir $work
file copy -force "$here/wiener_block.cpp"    "$work/wiener_block.cpp"
file copy -force "$here/wiener_block_tb.cpp" "$work/wiener_block_tb.cpp"
file copy -force $hdr "$work/hls_fft_rt.h"
exec sed -i {s/"nonrealtime"/"realtime"/g} "$work/hls_fft_rt.h"
cd $work
open_project -reset "$work/wiener_block_prj"
set_top wiener_block
add_files wiener_block.cpp -cflags "-I$work -DN=128 -DLOGN=7 -std=c++14"
add_files -tb wiener_block_tb.cpp -cflags "-I$work -std=c++14"
open_solution -reset solution1 -flow_target vivado
set_part xc7k480tffg1156-2
create_clock -period 4.000 -name default
csim_design
exit
