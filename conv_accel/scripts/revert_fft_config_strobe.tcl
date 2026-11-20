# Remove the (buggy) config-pulse generator and reconnect all xfft
# s_axis_config_tvalid pins to the constant 1, as validated in simulation.
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
open_project "$root/hw/accel.xpr"
open_bd_design [get_files -quiet top.bd]

foreach kind {fwd inv} {
    for {set i 0} {$i < 8} {incr i} {
        set pin "fft_${kind}_$i/s_axis_config_tvalid"
        set n [get_bd_nets -quiet -of_objects [get_bd_pins $pin]]
        if {[string match "*cfg_pulse*" $n]} {
            disconnect_bd_net $n [get_bd_pins $pin]
            connect_bd_net [get_bd_pins const_one/dout] [get_bd_pins $pin]
        }
    }
}
puts "config tvalid back on const_one"

if {[llength [get_bd_cells -quiet cfg_pulse_inv]]} { delete_bd_objs [get_bd_cells cfg_pulse_inv] }
if {[llength [get_bd_cells -quiet cfg_pulse_cnt]]} { delete_bd_objs [get_bd_cells cfg_pulse_cnt] }
puts "pulse cells removed"

validate_bd_design
save_bd_design
puts "BD saved"
exit
