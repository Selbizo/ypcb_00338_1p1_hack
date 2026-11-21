# xfft config strobe: replace constant 1 with a single ~32-cycle pulse
# after reset (counter runs to THRESH=32, then CE=0 stops it).
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
open_project "$root/hw/accel.xpr"
open_bd_design [get_files -quiet top.bd]

if {[llength [get_bd_cells -quiet cfg_pulse_cnt]] == 0} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:c_counter_binary:12.0 cfg_pulse_cnt
    set_property -dict [list \
        CONFIG.Output_Width {6} \
        CONFIG.CE {true} \
        CONFIG.SCLR {true} \
    ] [get_bd_cells cfg_pulse_cnt]
    create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 cfg_pulse_bit
    set_property -dict [list CONFIG.DIN_WIDTH {6} CONFIG.DIN_FROM {5} CONFIG.DIN_TO {5} CONFIG.DOUT_WIDTH {1}] [get_bd_cells cfg_pulse_bit]
    create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 cfg_pulse_inv
    set_property -dict [list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}] [get_bd_cells cfg_pulse_inv]
    connect_bd_net [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins cfg_pulse_cnt/CLK]
    connect_bd_net [get_bd_pins rst_215/peripheral_reset] [get_bd_pins cfg_pulse_cnt/SCLR]
    connect_bd_net [get_bd_pins cfg_pulse_cnt/Q] [get_bd_pins cfg_pulse_bit/Din]
    connect_bd_net [get_bd_pins cfg_pulse_bit/Dout] [get_bd_pins cfg_pulse_inv/Op1]
    connect_bd_net [get_bd_pins cfg_pulse_inv/Res] [get_bd_pins cfg_pulse_cnt/CE]
    puts "pulse generator created"
}


foreach kind {fwd inv} {
    for {set i 0} {$i < 8} {incr i} {
        set pin "fft_${kind}_$i/s_axis_config_tvalid"
        set n [get_bd_nets -quiet -of_objects [get_bd_pins $pin]]
        if {![string match "*cfg_pulse_inv*" $n]} {
            if {[llength $n]} { disconnect_bd_net $n [get_bd_pins $pin] }
            connect_bd_net [get_bd_pins cfg_pulse_inv/Res] [get_bd_pins $pin]
        }
    }
}
puts "config tvalid on pulse"
validate_bd_design
save_bd_design
puts "BD saved (config pulse)"
exit
