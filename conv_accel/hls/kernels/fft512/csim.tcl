# C simulation of the 512-point FFT against a DFT reference.
#   vitis_hls -f csim.tcl
set here [file normalize [file dirname [info script]]]
set work "/tmp/conv_accel_hls/fft512_csim"

file delete -force $work
file mkdir $work
file copy -force "$here/fft512.cpp"    "$work/fft512.cpp"
file copy -force "$here/fft512_tb.cpp" "$work/fft512_tb.cpp"
cd $work

open_project -reset "$work/fft512_prj"
set_top fft512
add_files fft512.cpp -cflags "-std=c++14"
add_files -tb fft512_tb.cpp -cflags "-std=c++14"
open_solution -reset solution1 -flow_target vivado
set_part xc7k480tffg1156-2
create_clock -period 4.000 -name default
csim_design
exit
