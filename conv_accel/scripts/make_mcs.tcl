# Generate the BPI x16 MCS image for the flash.
#   vivado -mode batch -source scripts/make_mcs.tcl
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
set impl "$root/hw/accel.runs/impl_1"

if {![file exists "$impl/top_wrapper.bit"]} { error "no bitstream, run scripts/build_hw.tcl first" }

# relative names: paths with spaces must not go through -loadbit
cd $impl
write_cfgmem -force -format MCS -interface BPIX16 -size 64 \
    -loadbit {up 0x0 top_wrapper.bit} top_wrapper.mcs

puts "MCS: $impl/top_wrapper.mcs ([expr {[file size "$impl/top_wrapper.mcs"]/1048576}] MB)"
