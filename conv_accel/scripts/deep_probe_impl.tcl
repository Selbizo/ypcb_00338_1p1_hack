# Insert the ILA on block_wiener + fft_core FSM states and implement.
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

set bw [lsort -dictionary [get_nets -hier -quiet -filter {NAME =~ "*grp_block_wiener_fu_*/ap_CS_fsm_state*"}]]
set fc [lsort -dictionary [get_nets -hier -quiet -filter {NAME =~ "*grp_fft_core_fu_*/ap_CS_fsm_state*"}]]
puts "BW: [llength $bw]"
foreach n $bw { puts "  $n" }
puts "FC: [llength $fc]"
foreach n $fc { puts "  $n" }

set nets [concat $bw $fc]
set i 0
foreach n $nets {
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
puts "DEEP PROBE BITSTREAM WRITTEN"
exit
