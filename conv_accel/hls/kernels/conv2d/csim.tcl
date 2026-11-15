# C simulation of conv2d against the software reference.
#   vitis_hls -f csim.tcl
set here  [file normalize [file dirname [info script]]]
set root  [file normalize "$here/../../.."]
set work  "/tmp/conv_accel_hls/conv2d_csim"
set vis   "/tmp/conv_accel_hls/vision/L1/include"

file delete -force $work
file mkdir $work
file copy -force "$here/conv2d.cpp" "$work/conv2d.cpp"
file copy -force "$here/conv2d_tb.cpp" "$work/conv2d_tb.cpp"
if {![file exists "$vis/common/xf_common.hpp"]} {
    file delete -force "/tmp/conv_accel_hls/vision"
    file mkdir "/tmp/conv_accel_hls/vision/L1"
    file copy -force "$root/hls/third_party/vision/L1/include" "/tmp/conv_accel_hls/vision/L1/include"
}

cd $work
open_project -reset "$work/conv2d_prj"
set_top conv2d
add_files conv2d.cpp -cflags "-I$vis -std=c++14"
add_files -tb conv2d_tb.cpp -cflags "-I$vis -std=c++14"
open_solution -reset solution1 -flow_target vivado
set_part xc7k480tffg1156-2
create_clock -period 4.000 -name default
csim_design
exit
