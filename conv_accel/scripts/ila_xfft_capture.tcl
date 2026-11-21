# Capture the minimal xfft test ILA and summarise the output stream.
#   vivado -mode batch -source scripts/ila_xfft_capture.tcl
open_hw_manager
connect_hw_server -url localhost:3121
open_hw_target
set dev [lindex [get_hw_devices] 0]
current_hw_device $dev
set ltx "/mnt/data/FPGA projects/ypcb_00338_1p1_hack/conv_accel/hw/accel.runs/impl_1/debug_nets.ltx"
if {[file exists $ltx]} { set_property PROBES.FILE $ltx $dev }
refresh_hw_device $dev

set ilas [get_hw_ilas -of_objects $dev]
puts "ILAS: $ilas"
if {[llength $ilas] == 0} { error "no ILA" }
set ila [lindex $ilas 0]
reset_hw_ila $ila
run_hw_ila -trigger_now $ila
wait_on_hw_ila $ila
set d [upload_hw_ila_data $ila]
write_hw_ila_data -force -csv_file /tmp/opencode/xfft_test.csv $d
puts "CSV: /tmp/opencode/xfft_test.csv"
close_hw_target
exit
