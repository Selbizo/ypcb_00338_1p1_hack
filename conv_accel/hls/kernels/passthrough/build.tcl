# Vitis HLS build: passthrough kernel -> Vivado IP
#   vitis_hls -f build.tcl
#
# Vitis HLS rejects paths containing spaces, so the synthesis runs in a
# scratch directory and the exported IP is copied back into hw/ip_repo.
set here  [file normalize [file dirname [info script]]]
set root  [file normalize "$here/../../.."]
set ipout "$root/hw/ip_repo"

set work "/tmp/conv_accel_hls/passthrough"
file delete -force $work
file mkdir $work
file copy -force "$here/passthrough.cpp" "$work/passthrough.cpp"

open_project -reset "$work/passthrough_prj"
set_top passthrough
add_files "$work/passthrough.cpp"

open_solution -reset solution1 -flow_target vivado
set_part xc7k480tffg1156-2
create_clock -period 4.000 -name default

csynth_design
export_design -format ip_catalog -vendor "user" -library "hls" -version "1.0" -output "$work/passthrough"

file delete -force "$ipout/passthrough"
file mkdir "$ipout/passthrough"
file copy -force "$work/passthrough.zip" "$ipout/passthrough.zip"
exec unzip -q -o "$ipout/passthrough.zip" -d "$ipout/passthrough"
puts "IP exported to $ipout/passthrough (component.xml: [file exists $ipout/passthrough/component.xml])"
exit
