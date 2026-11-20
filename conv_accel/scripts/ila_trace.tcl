# Arm the ILA on the first FFT send, run the register-level self-test,
# then upload the capture.
#   vivado -mode batch -source scripts/ila_trace.tcl -tclargs /tmp/opencode/ila_trace.csv
set root [file normalize [file dirname [info script]]/..]
set csv "/tmp/opencode/ila_trace.csv"
if {[llength $argv] > 0} { set csv [lindex $argv 0] }

open_hw_manager
connect_hw_server -url localhost:3121
open_hw_target
set dev [lindex [get_hw_devices] 0]
current_hw_device $dev
set_property PROBES.FILE "$root/hw/accel.runs/impl_1/debug_nets.ltx" $dev
refresh_hw_device $dev
set ila [lindex [get_hw_ilas -of_objects $dev] 0]

set trig [get_hw_probes -of_objects $ila -filter {NAME =~ "*slot_0_axis_tvalid*"}]
set_property COMPARE_VALUE.0 eq1'b1 $trig
set_property CONTROL.TRIGGER_POSITION 4096 $ila
reset_hw_ila $ila
run_hw_ila $ila
puts "ILA armed on first fwd_in TVALID"

set rc [catch {exec sudo -n python3 "$root/scripts/fpga_selftest.py" 256 256 6 0 > /tmp/opencode/selftest_ila.log 2>&1} e]
puts "selftest rc=$rc"
if {[catch {wait_on_hw_ila -timeout 60 $ila} e2]} { puts "trigger timeout: $e2" } else { puts "triggered" }
set data [upload_hw_ila_data $ila]
write_hw_ila_data -csv_file $csv $data
puts "CSV: $csv"
close_hw_target
exit
