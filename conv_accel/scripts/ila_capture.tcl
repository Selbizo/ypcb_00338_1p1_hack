# Arm the deblur system_ila, wait for the trigger, dump the capture to CSV.
#   vivado -mode batch -source scripts/ila_capture.tcl -tclargs /tmp/opencode/ila.csv
#
# The ILA monitors: kernel -> fft_fwd_0 S_AXIS, fwd_fifo_0 -> kernel,
# kernel dout. Default basic trigger is slot0 TVALID rising, i.e. the first
# row_pass send.
set root [file normalize [file dirname [info script]]/..]
set csv "/tmp/opencode/ila_capture.csv"
if {[llength $argv] > 0} { set csv [lindex $argv 0] }

open_hw_manager
connect_hw_server -url localhost:3121
open_hw_target
set dev [lindex [get_hw_devices] 0]
current_hw_device $dev
set ltx [file normalize "$root/hw/accel.runs/impl_1/debug_nets.ltx"]
if {![file exists $ltx]} { error "missing $ltx" }
set_property PROBES.FILE $ltx $dev
refresh_hw_device $dev

set ilas [get_hw_ilas -of_objects $dev]
puts "ILAS: $ilas"
if {[llength $ilas] == 0} { error "no ILA found (debug hub missing?)" }
set ila [lindex $ilas 0]

puts "PROBES:"
foreach p [get_hw_probes -of_objects $ila] { puts "  $p" }

# Called after the kernel is already hung: sample the current (static) state.
reset_hw_ila $ila
run_hw_ila -trigger_now $ila
wait_on_hw_ila $ila
puts "captured current state"
set data [upload_hw_ila_data $ila]
write_hw_ila_data -csv_file $csv $data
puts "CSV: $csv"
close_hw_target
exit
