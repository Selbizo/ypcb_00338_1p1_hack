set here  [file normalize [file dirname [info script]]]
set work  "/tmp/conv_accel_hls/row_par"
set hdr   "/mnt/tools/Xilinx/Vitis/2024.2/common/technology/autopilot/hls_fft.h"
file delete -force $work
file mkdir $work
file copy -force "$here/row_par_test.cpp" "$work/row_par_test.cpp"
file copy -force $hdr "$work/hls_fft_rt.h"
exec sed -i {s/"nonrealtime"/"realtime"/g} "$work/hls_fft_rt.h"
cd $work
open_project -reset "$work/row_par_prj"
set_top row_pass
add_files row_par_test.cpp -cflags "-I$work -DN=256 -DLOGN=8 -DIN_W=24 -std=c++14"
open_solution -reset solution1 -flow_target vivado
set_part xc7k480tffg1156-2
create_clock -period 4.000 -name default
csynth_design
exit
