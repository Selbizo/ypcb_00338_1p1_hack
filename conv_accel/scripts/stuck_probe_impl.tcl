# Netlist ILA: top FSM state + stream handshakes, to find where wiener_stream
# hangs. Trigger_now is used; capture while the kernel is stuck.
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
set impl "$root/hw/accel.runs/impl_1"
open_project "$root/hw/accel.xpr"
set_property strategy {Performance_Explore} [get_runs impl_1]
open_run synth_1

create_debug_core u_ila_0 ila
set_property C_DATA_DEPTH 4096 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
connect_debug_port u_ila_0/clk [get_nets top_i/wiener_0/inst/ap_clk]

set nets {}
foreach s {2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 80 81 82} {
    set n [get_nets -hier -quiet -filter "NAME =~ \"*wiener_0/inst/ap_CS_fsm_state$s\""]
    if {[llength $n] == 0} { puts "MISSING state$s"; continue }
    lappend nets [lindex $n 0]
}
foreach n {
    top_i/wiener_0/inst/din_TVALID
    top_i/wiener_0/inst/din_TREADY
    top_i/wiener_0/inst/fwd_in_0_TVALID
    top_i/wiener_0/inst/fwd_in_0_TREADY
    top_i/wiener_0/inst/fwd_out_0_TVALID
    top_i/wiener_0/inst/fwd_out_0_TREADY
    top_i/wiener_0/inst/inv_in_0_TVALID
    top_i/wiener_0/inst/inv_in_0_TREADY
    top_i/wiener_0/inst/inv_out_0_TVALID
    top_i/wiener_0/inst/inv_out_0_TREADY
    top_i/wiener_0/inst/dout_TVALID
    top_i/wiener_0/inst/dout_TREADY
} {
    if {[llength [get_nets -quiet $n]] == 0} { puts "MISSING $n"; continue }
    lappend nets $n
}
puts "NETS: [llength $nets]"
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
puts "STUCK PROBE BITSTREAM WRITTEN"
exit
