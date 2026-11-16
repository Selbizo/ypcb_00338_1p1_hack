set here  [file normalize [file dirname [info script]]]
set work  "/tmp/conv_accel_hls/wiener_block_float"
set hdr   "/mnt/tools/Xilinx/Vitis/2024.2/common/technology/autopilot/hls_fft.h"
file delete -force $work
file mkdir $work
file copy -force "$here/wiener_block_float.cpp" "$work/wiener_block_float.cpp"
file copy -force $hdr "$work/hls_fft_rt.h"
exec sed -i {s/"nonrealtime"/"realtime"/g} "$work/hls_fft_rt.h"
open_project -reset "$work/wiener_block_float_prj"
set_top wiener_block_f
add_files "$work/wiener_block_float.cpp" -cflags "-I$work -DN=128 -DLOGN=7 -std=c++14"
open_solution -reset solution1 -flow_target vivado
set_part xc7k480tffg1156-2
create_clock -period 4.000 -name default
csynth_design
exit
