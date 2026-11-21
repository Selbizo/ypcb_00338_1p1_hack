# Add a 4-slot system_ila for the loopback build: din, dout, fwd_in_0,
# fwd_fifo_0/M_AXIS. Depth 2048.
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
open_project "$root/hw/accel.xpr"
open_bd_design [get_files -quiet top.bd]

if {[llength [get_bd_cells -quiet dbg_ila]] == 0} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 dbg_ila
    set cfg [list CONFIG.C_NUM_MONITOR_SLOTS {4} CONFIG.C_DATA_DEPTH {2048}]
    for {set i 0} {$i < 4} {incr i} {
        lappend cfg CONFIG.C_SLOT_${i}_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0}
    }
    set_property -dict $cfg [get_bd_cells dbg_ila]
    connect_bd_net [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins dbg_ila/clk]
    connect_bd_net [get_bd_pins rst_215/peripheral_aresetn] [get_bd_pins dbg_ila/resetn]
}
set pairs [list \
    [list dbg_ila/SLOT_0_AXIS wiener_0/din] \
    [list dbg_ila/SLOT_1_AXIS wiener_0/dout] \
    [list dbg_ila/SLOT_2_AXIS wiener_0/fwd_in_0] \
    [list dbg_ila/SLOT_3_AXIS fwd_fifo_0/M_AXIS] \
]
foreach p $pairs {
    lassign $p a b
    connect_bd_intf_net [get_bd_intf_pins $a] [get_bd_intf_pins $b]
    puts "tap $b"
}
validate_bd_design
save_bd_design
puts "ILA (loopback) saved"
exit
