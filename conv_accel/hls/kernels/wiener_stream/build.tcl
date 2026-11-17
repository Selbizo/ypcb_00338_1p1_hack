set here  [file normalize [file dirname [info script]]]
set root  [file normalize "$here/../../.."]
set ipout "$root/hw/ip_repo"
set work  "/tmp/conv_accel_hls/wiener_stream"
file delete -force $work
file mkdir $work
file copy -force "$here/wiener_stream.cpp" "$work/wiener_stream.cpp"
file copy -force "$here/g_lut.h" "$work/g_lut.h"
cd $work
open_project -reset "$work/ws_prj"
set_top wiener_stream
add_files wiener_stream.cpp -cflags "-I$work -DN=256 -std=c++14"
open_solution -reset solution1 -flow_target vivado
set_part xc7k480tffg1156-2
create_clock -period 4.000 -name default
csynth_design
export_design -format ip_catalog -vendor "user" -library "hls" -version "1.0" -output "$work/wiener_stream"
file delete -force "$ipout/wiener_stream"
file mkdir "$ipout/wiener_stream"
file copy -force "$work/wiener_stream.zip" "$ipout/wiener_stream.zip"
exec unzip -q -o "$ipout/wiener_stream.zip" -d "$ipout/wiener_stream"
puts "IP exported to $ipout/wiener_stream"
exit
