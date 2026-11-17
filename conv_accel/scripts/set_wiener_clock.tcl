# Change the kernel/FFT clock (CLKOUT3) and rebuild only the BD.
#   vivado -mode batch -source scripts/set_wiener_clock.tcl -tclargs 190
# Default: 190 MHz (safe point for the 5.16 ns worst route; 208 MHz missed by 0.6 ns).
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]

set freq 190
if {[llength $argv] > 0} { set freq [lindex $argv 0] }

open_project "$root/hw/accel.xpr"
open_bd_design [get_files top.bd]

set_property -dict [list CONFIG.CLKOUT3_REQUESTED_OUT_FREQ $freq] [get_bd_cells clk_wiz_1]
validate_bd_design
save_bd_design

puts "CLKOUT3 requested = $freq MHz"
puts "Now rebuild with: vivado -mode batch -source scripts/build_hw.tcl"
exit
