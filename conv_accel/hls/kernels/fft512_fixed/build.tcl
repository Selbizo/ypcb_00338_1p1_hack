# Vitis HLS build: 512-point fixed-point realtime FFT -> Vivado IP
#   vitis_hls -f build.tcl
set here  [file normalize [file dirname [info script]]]
set root  [file normalize "$here/../../.."]
set ipout "$root/hw/ip_repo"
set hdr   "/mnt/tools/Xilinx/Vitis/2024.2/common/technology/autopilot/hls_fft.h"

set work "/tmp/conv_accel_hls/fft512_fixed"
file delete -force $work
file mkdir $work
file copy -force "$here/fft512_fixed.cpp" "$work/fft512_fixed.cpp"
file copy -force $hdr "$work/hls_fft_rt.h"
exec sed -i {s/"nonrealtime"/"realtime"/g} "$work/hls_fft_rt.h"

open_project -reset "$work/fft512_fixed_prj"
set_top fft512_fixed
add_files "$work/fft512_fixed.cpp" -cflags "-I$work -std=c++14"

open_solution -reset solution1 -flow_target vivado
set_part xc7k480tffg1156-2
create_clock -period 4.000 -name default

csynth_design
export_design -format ip_catalog -vendor "user" -library "hls" -version "1.0" -output "$work/fft512_fixed"

file delete -force "$ipout/fft512_fixed"
file mkdir "$ipout/fft512_fixed"
file copy -force "$work/fft512_fixed.zip" "$ipout/fft512_fixed.zip"
exec unzip -q -o "$ipout/fft512_fixed.zip" -d "$ipout/fft512_fixed"
puts "IP exported to $ipout/fft512_fixed"
exit
