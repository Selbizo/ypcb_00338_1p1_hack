# Insert the FSM ILA into the existing synth_1 netlist and implement.
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
set impl "$root/hw/accel.runs/impl_1"
open_project "$root/hw/accel.xpr"
set_property strategy {Performance_Explore} [get_runs impl_1]
open_run synth_1

create_debug_core u_ila_0 ila
set_property C_DATA_DEPTH 8192 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
connect_debug_port u_ila_0/clk [get_nets top_i/wiener_0/inst/ap_clk]

set states [lsort -dictionary [get_nets -hier -quiet -filter {NAME =~ "*wiener_0/inst/ap_CS_fsm_state*"}]]
puts "STATES: [llength $states]"
set i 0
foreach n $states {
    if {$i > 0} { create_debug_port u_ila_0 probe }
    set_property port_width 1 [get_debug_ports u_ila_0/probe$i]
    connect_debug_port u_ila_0/probe$i [get_nets $n]
    incr i
}
puts "PROBES: $i"

opt_design
place_design
route_design
write_bitstream -force "$impl/top_wrapper.bit"
write_debug_probes -force "$impl/debug_nets.ltx"
puts "FSM PROBE BITSTREAM WRITTEN"
exit
