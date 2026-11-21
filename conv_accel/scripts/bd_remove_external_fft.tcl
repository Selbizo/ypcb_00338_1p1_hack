# Strip the external xfft path now that the kernel uses hls::fft internally.
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
open_project "$root/hw/accel.xpr"
open_bd_design [get_files -quiet top.bd]

set cells {}
for {set i 0} {$i < 8} {incr i} {
    lappend cells fft_fwd_$i fft_inv_$i fwd_fifo_$i inv_fifo_$i
}
lappend cells const_one const_c0 const_c1 \
    cfg_pulse_cnt cfg_pulse_bit cfg_pulse_inv dbg_ila

foreach c $cells {
    if {[llength [get_bd_cells -quiet $c]]} {
        delete_bd_objs [get_bd_cells $c]
        puts "deleted $c"
    }
}
validate_bd_design
save_bd_design
puts "external FFT path removed"
exit
