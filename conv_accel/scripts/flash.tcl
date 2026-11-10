# Program the BPI flash over JTAG, then boot from it.
#   vivado -mode batch -source scripts/flash.tcl
#
# Note: the flash is x16 BPI. Program the *.mcs*, never the .bin/.bit.
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
set mcs  "$root/hw/accel.runs/impl_1/top_wrapper.mcs"

if {![file exists $mcs]} { error "no $mcs, run scripts/make_mcs.tcl first" }

if {[info exists ::env(XILINX_VIVADO)]} { set xv $::env(XILINX_VIVADO) } else { set xv /mnt/tools/Xilinx/Vivado/2024.2 }
set bpi "$xv/data/xicom/cfgmem/bitfile/bpi_xc7k480t_pullnone.bit"
if {![file exists $bpi]} {
    error "missing $bpi\nUnpack it from $xv/data/xicom/cfgmem/bitfile.zip (bpi_xc7k480t_*.bit)."
}

open_hw_manager
connect_hw_server -url localhost:3121
open_hw_target
set dev [lindex [get_hw_devices] 0]
current_hw_device $dev
refresh_hw_device -update_hw_probes false $dev

# The flash is accessed through a small "BPI core" design loaded over JTAG.
puts "== loading BPI access design =="
create_hw_bitstream -hw_device $dev $bpi
set_property PROGRAM.FILE $bpi $dev
program_hw_devices $dev
refresh_hw_device -update_hw_probes false $dev

create_hw_cfgmem -hw_device $dev -mem_dev [lindex [get_cfgmem_parts {mt28gu512aax1e-bpi-x16}] 0]
set mem [lindex [get_hw_cfgmems] 0]
set_property PROGRAM.FILES           [list $mcs] $mem
set_property PROGRAM.ADDRESS_RANGE   {use_file} $mem
set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} $mem
set_property PROGRAM.BLANK_CHECK     0 $mem
set_property PROGRAM.ERASE           1 $mem
set_property PROGRAM.CFG_PROGRAM     1 $mem
set_property PROGRAM.VERIFY          1 $mem

puts "== erase / program / verify =="
program_hw_cfgmem -hw_cfgmem $mem

puts "== boot from flash =="
if {[catch {boot_hw_device $dev} r]} {
    puts "BOOT FAIL: $r"
} else {
    puts "BOOT OK"
}
refresh_hw_device -update_hw_probes false $dev
puts "BOOT_STATUS   = [get_property REGISTER.BOOT_STATUS $dev]"
puts "CONFIG_STATUS = [get_property REGISTER.CONFIG_STATUS $dev]"
puts ""
puts "If this was a runtime reconfiguration, re-enumerate the device on the host:"
puts "    sudo scripts/reprobe.sh"
