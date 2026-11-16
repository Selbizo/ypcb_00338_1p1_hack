# Vitis HLS build: 512-point streaming FFT -> Vivado IP
#   vitis_hls -f build.tcl
set here  [file normalize [file dirname [info script]]]
set root  [file normalize "$here/../../.."]
set ipout "$root/hw/ip_repo"

set work "/tmp/conv_accel_hls/fft512"
file delete -force $work
file mkdir $work
file copy -force "$here/fft512.cpp" "$work/fft512.cpp"

open_project -reset "$work/fft512_prj"
set_top fft512
add_files "$work/fft512.cpp" -cflags "-std=c++14"

open_solution -reset solution1 -flow_target vivado
set_part xc7k480tffg1156-2
create_clock -period 4.000 -name default

csynth_design
export_design -format ip_catalog -vendor "user" -library "hls" -version "1.0" -output "$work/fft512"

file delete -force "$ipout/fft512"
file mkdir "$ipout/fft512"
file copy -force "$work/fft512.zip" "$ipout/fft512.zip"
exec unzip -q -o "$ipout/fft512.zip" -d "$ipout/fft512"
puts "IP exported to $ipout/fft512"
exit
