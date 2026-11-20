# Two changes:
# 1. xfft s_axis_config_tvalid: one-cycle pulse after reset instead of a
#    constant 1 (the synthesised core reloads config while tvalid is high).
# 2. ILA SLOT_2 now monitors the raw fft_fwd_0 M_AXIS instead of the FIFO.
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
open_project "$root/hw/accel.xpr"
open_bd_design [get_files -quiet top.bd]

# --- config pulse generator ---
if {[llength [get_bd_cells -quiet cfg_pulse_cnt]] == 0} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:c_counter_binary:12.0 cfg_pulse_cnt
    set_property -dict [list CONFIG.Output_Width {1} CONFIG.CE {true} CONFIG.SCLR {true}] [get_bd_cells cfg_pulse_cnt]
    create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 cfg_pulse_inv
    set_property -dict [list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}] [get_bd_cells cfg_pulse_inv]
    connect_bd_net [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins cfg_pulse_cnt/CLK]
    connect_bd_net [get_bd_pins rst_215/peripheral_reset] [get_bd_pins cfg_pulse_cnt/SCLR]
    connect_bd_net [get_bd_pins const_one/dout] [get_bd_pins cfg_pulse_cnt/CE]
    connect_bd_net [get_bd_pins cfg_pulse_cnt/Q] [get_bd_pins cfg_pulse_inv/Op1]
    puts "pulse generator created"
}

foreach kind {fwd inv} {
    for {set i 0} {$i < 8} {incr i} {
        set pin "fft_${kind}_$i/s_axis_config_tvalid"
        set n [get_bd_nets -quiet -of_objects [get_bd_pins $pin]]
        if {[string match "*const_one_dout*" $n]} {
            disconnect_bd_net $n [get_bd_pins $pin]
            connect_bd_net [get_bd_pins cfg_pulse_inv/Res] [get_bd_pins $pin]
        }
    }
}
puts "config tvalid rewired to pulse"

# --- ILA slot2 -> raw FFT output ---
set slot [get_bd_intf_pins dbg_ila/SLOT_2_AXIS]
set old [get_bd_intf_nets -quiet -of_objects $slot]
foreach n $old {
    disconnect_bd_intf_net $n [get_bd_intf_pins dbg_ila/SLOT_2_AXIS]
}
connect_bd_intf_net [get_bd_intf_pins dbg_ila/SLOT_2_AXIS] [get_bd_intf_pins fft_fwd_0/M_AXIS_DATA]
puts "ILA SLOT_2 -> fft_fwd_0 M_AXIS"

validate_bd_design
save_bd_design
puts "BD updated"
exit
