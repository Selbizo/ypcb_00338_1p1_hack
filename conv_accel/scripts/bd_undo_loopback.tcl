# Undo scripts/bd_loopback.tcl: restore kernel -> xfft -> fifo -> kernel.
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
open_project "$root/hw/accel.xpr"
open_bd_design [get_files -quiet top.bd]

foreach kind {fwd inv} {
    for {set i 0} {$i < 8} {incr i} {
        set fft  "fft_${kind}_$i"
        set fifo "${kind}_fifo_$i"
        set kout "wiener_0/${kind}_in_$i"
        set kin  "wiener_0/${kind}_out_$i"

        set n [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins $fifo/S_AXIS]]
        if {[llength $n]} {
            disconnect_bd_intf_net $n [get_bd_intf_pins $fifo/S_AXIS] [get_bd_intf_pins $kout]
        }
        connect_bd_intf_net [get_bd_intf_pins $kout] [get_bd_intf_pins $fft/S_AXIS_DATA]
        connect_bd_intf_net [get_bd_intf_pins $fft/M_AXIS_DATA] [get_bd_intf_pins $fifo/S_AXIS]
    }
}
validate_bd_design
save_bd_design
puts "FFT path restored"
exit
