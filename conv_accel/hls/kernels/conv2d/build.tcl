# Vitis HLS build: conv2d (5x5 RGB, Vitis Vision filter2D) -> Vivado IP
#   vitis_hls -f build.tcl
#
# Vitis HLS rejects paths with spaces: synthesis runs in /tmp/conv_accel_hls,
# the Vitis Vision headers are copied there too, and the exported IP is copied
# back into hw/ip_repo.
set here  [file normalize [file dirname [info script]]]
set root  [file normalize "$here/../../.."]
set ipout "$root/hw/ip_repo"

set work "/tmp/conv_accel_hls/conv2d"
set vis  "/tmp/conv_accel_hls/vision/L1/include"

file delete -force $work
file mkdir $work
file copy -force "$here/conv2d.cpp" "$work/conv2d.cpp"

if {![file exists "$vis/common/xf_common.hpp"]} {
    file delete -force "/tmp/conv_accel_hls/vision"
    file mkdir "/tmp/conv_accel_hls/vision/L1"
    file copy -force "$root/hls/third_party/vision/L1/include" "/tmp/conv_accel_hls/vision/L1/include"
}

open_project -reset "$work/conv2d_prj"
set_top conv2d
add_files "$work/conv2d.cpp" -cflags "-I$vis -std=c++14"

open_solution -reset solution1 -flow_target vivado
set_part xc7k480tffg1156-2
create_clock -period 4.000 -name default

csynth_design
export_design -format ip_catalog -vendor "user" -library "hls" -version "3.0" -output "$work/conv2d"

file delete -force "$ipout/conv2d"
file mkdir "$ipout/conv2d"
file copy -force "$work/conv2d.zip" "$ipout/conv2d.zip"
exec unzip -q -o "$ipout/conv2d.zip" -d "$ipout/conv2d"
puts "IP exported to $ipout/conv2d (component.xml: [file exists $ipout/conv2d/component.xml])"
exit
