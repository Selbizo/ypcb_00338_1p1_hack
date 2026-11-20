# Add a system_ila (AXI-Stream monitor) on the deblur datapath.
# Slots: fft_fwd_0 S_AXIS (kernel -> FFT), fwd_fifo_0 M_AXIS (FIFO -> kernel),
#        wiener_0 dout (kernel -> clock converter).
# Clock: kernel domain (clk_out3). No trigger is configured here; arm in hw_server
# and upload the circular buffer after a hang.
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
open_project "$root/hw/accel.xpr"
open_bd_design [get_files -quiet top.bd]

if {[llength [get_bd_cells -quiet dbg_ila]] == 0} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 dbg_ila
    set_property -dict [list \
        CONFIG.C_NUM_MONITOR_SLOTS {3} \
        CONFIG.C_DATA_DEPTH {8192} \
        CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
        CONFIG.C_SLOT_1_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
        CONFIG.C_SLOT_2_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
    ] [get_bd_cells dbg_ila]
    connect_bd_net [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins dbg_ila/clk]
    connect_bd_net [get_bd_pins rst_215/peripheral_aresetn] [get_bd_pins dbg_ila/resetn]
}

# taps on existing interface nets
set taps [list \
    [list /wiener_0_fwd_in_0  SLOT_0_AXIS] \
    [list /fwd_fifo_0_M_AXIS  SLOT_1_AXIS] \
    [list /wiener_0_dout      SLOT_2_AXIS] \
]
foreach t $taps {
    lassign $t net slot
    set already [get_bd_intf_pins -quiet -of_objects [get_bd_intf_nets -quiet $net] */$slot]
    if {[llength $already] == 0} {
        connect_bd_intf_net [get_bd_intf_nets $net] [get_bd_intf_pins dbg_ila/$slot]
        puts "tapped $net -> $slot"
    }
}

validate_bd_design
save_bd_design
puts "ILA added"
exit
