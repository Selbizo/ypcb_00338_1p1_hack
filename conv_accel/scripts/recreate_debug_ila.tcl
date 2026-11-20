# Recreate the deblur system_ila with 6 AXIS taps:
#   din, fwd_in_0, fwd_fifo_0/M_AXIS, inv_in_0, inv_fifo_0/M_AXIS, dout
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
open_project "$root/hw/accel.xpr"
open_bd_design [get_files -quiet top.bd]

if {[llength [get_bd_cells -quiet dbg_ila]]} {
    delete_bd_objs [get_bd_cells dbg_ila]
    puts "removed old dbg_ila"
}

create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 dbg_ila
set cfg [list CONFIG.C_NUM_MONITOR_SLOTS {6} CONFIG.C_DATA_DEPTH {8192}]
for {set i 0} {$i < 6} {incr i} {
    lappend cfg CONFIG.C_SLOT_${i}_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0}
}
set_property -dict $cfg [get_bd_cells dbg_ila]
connect_bd_net [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins dbg_ila/clk]
connect_bd_net [get_bd_pins rst_215/peripheral_aresetn] [get_bd_pins dbg_ila/resetn]

set pairs [list \
    [list dbg_ila/SLOT_0_AXIS wiener_0/din] \
    [list dbg_ila/SLOT_1_AXIS wiener_0/fwd_in_0] \
    [list dbg_ila/SLOT_2_AXIS fwd_fifo_0/M_AXIS] \
    [list dbg_ila/SLOT_3_AXIS wiener_0/inv_in_0] \
    [list dbg_ila/SLOT_4_AXIS inv_fifo_0/M_AXIS] \
    [list dbg_ila/SLOT_5_AXIS wiener_0/dout] \
]
foreach p $pairs {
    lassign $p a b
    connect_bd_intf_net [get_bd_intf_pins $a] [get_bd_intf_pins $b]
    puts "tap $a <- $b"
}

validate_bd_design
save_bd_design
puts "6-slot ILA saved"
exit
