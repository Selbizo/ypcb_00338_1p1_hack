# Loopback test: bypass all 16 xfft cores.
#   kernel fwd_in_i/inv_in_i (output) -> *_fifo_i -> kernel fwd_out_i/inv_out_i
# The xfft cells stay in the BD but their data interfaces are left open.
# Also removes the debug ILA (it taps the fft m_axis).
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
open_project "$root/hw/accel.xpr"
open_bd_design [get_files -quiet top.bd]

if {[llength [get_bd_cells -quiet dbg_ila]]} {
    delete_bd_objs [get_bd_cells dbg_ila]
    puts "ILA removed"
}

foreach kind {fwd inv} {
    for {set i 0} {$i < 8} {incr i} {
        set fft  "fft_${kind}_$i"
        set fifo "${kind}_fifo_$i"
        set kout "wiener_0/${kind}_in_$i"
        set kin  "wiener_0/${kind}_out_$i"

        # detach xfft input from the kernel output
        set n1 [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins $fft/S_AXIS_DATA]]
        if {[llength $n1]} {
            disconnect_bd_intf_net $n1 [get_bd_intf_pins $fft/S_AXIS_DATA] [get_bd_intf_pins $kout]
        }
        # detach xfft output from the fifo input
        set n2 [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins $fft/M_AXIS_DATA]]
        if {[llength $n2]} {
            disconnect_bd_intf_net $n2 [get_bd_intf_pins $fft/M_AXIS_DATA] [get_bd_intf_pins $fifo/S_AXIS]
        }
        # kernel output -> fifo -> kernel input (fifo m_axis already goes to kin)
        connect_bd_intf_net [get_bd_intf_pins $kout] [get_bd_intf_pins $fifo/S_AXIS]
    }
}
puts "loopback wired"

validate_bd_design
save_bd_design
puts "BD saved (loopback)"
exit
