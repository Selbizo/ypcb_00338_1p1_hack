# Build with an ILA inserted on the kernel FSM state nets (netlist debug).
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
set proj "$root/hw/accel.xpr"
set impl "$root/hw/accel.runs/impl_1"

open_project $proj
set_property strategy {Performance_Explore} [get_runs impl_1]

# 1) BD out-of-context synthesis
reset_run top_synth_1
launch_runs top_synth_1 -jobs 8
wait_on_run top_synth_1
if {[get_property PROGRESS [get_runs top_synth_1]] ne "100%"} {
    error "top_synth_1 failed: [get_property STATUS [get_runs top_synth_1]]"
}
cd "$root/hw"
set wrap accel.gen/sources_1/bd/top/hdl/top_wrapper.v
if {[file exists $wrap] && [llength [get_files -quiet -of_objects [get_filesets sources_1] $wrap]] == 0} {
    add_files -norecurse -fileset sources_1 $wrap
}
set_property top top_wrapper [get_filesets sources_1]
update_compile_order -fileset sources_1

# 2) top synthesis
reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    error "synth_1 failed: [get_property STATUS [get_runs synth_1]]"
}

# 3) netlist ILA on all ap_CS_fsm_state* nets
open_run synth_1
create_debug_core u_ila_0 ila
set_property C_DATA_DEPTH 8192 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set states [lsort -dictionary [get_nets -hier -quiet -filter {NAME =~ "*wiener_0/inst/ap_CS_fsm_state*"}]]
puts "STATES: [llength $states]"
set_property C_NUM_OF_PROBES [llength $states] [get_debug_cores u_ila_0]
connect_debug_port u_ila_0/clk [get_nets top_i/wiener_0/inst/ap_clk]
set i 0
foreach n $states {
    set_property port_width 1 [get_debug_ports u_ila_0/probe$i]
    connect_debug_port u_ila_0/probe$i [get_nets $n]
    incr i
}
puts "PROBES CONNECTED: $i"

implement_debug_core
puts "DEBUG CORE IMPLEMENTED"

# 4) implementation
opt_design
place_design
route_design
write_bitstream -force "$impl/top_wrapper.bit"
write_debug_probes -force "$impl/debug_nets.ltx"
puts "BITSTREAM + LTX written"
exit
