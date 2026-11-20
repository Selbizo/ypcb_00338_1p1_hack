# Put every AXI-Lite slave inside the 64 KB PCIe user BAR.
#
# assign_bd_address (scripts/add_wiener_bd.tcl) packed the new blocks by
# alignment, not by reachability:
#   axi_dma_1 -> 0x41E00000 (unreachable, BAR is 64 KB)
#   wiener_0  -> 0x00010000 (unreachable, BAR is 64 KB)
#
# Target map (matches host/src/deblur_fpga.cpp):
#   0x0000  4K  axi_dma_0   (platform frame DMA)
#   0x1000  4K  conv2d_0    (platform kernel)
#   0x2000  4K  axi_dma_1   (deblur frame DMA)
#   0x4000  8K  wiener_0    (regs 0x00, params[3][256] at +0x1000)
#
# 0x3000 is left free because an 8 KB segment must be 8 KB aligned.
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
open_project "$root/hw/accel.xpr"
open_bd_design [get_files -quiet top.bd]

set space [get_bd_addr_spaces /xdma_0/M_AXI_LITE]
puts "SEGMENTS:"
foreach s [get_bd_addr_segs -of_objects $space] {
    puts "  $s  offset=[get_property offset $s] range=[get_property range $s]"
}

set dma1   [get_bd_addr_segs -of_objects $space -filter {NAME =~ "*axi_dma_1*"}]
set wiener [get_bd_addr_segs -of_objects $space -filter {NAME =~ "*wiener_0*"}]
if {[llength $dma1] != 1}   { error "axi_dma_1 segment: $dma1" }
if {[llength $wiener] != 1} { error "wiener_0 segment: $wiener" }

# AXI DMA register file is 4 KB.
set_property range  4K     $dma1
set_property offset 0x2000 $dma1

# axi_dma_1 has no memory segments at all (assign_bd_address skipped it), so
# its MM2S/S2MM masters cannot be validated against DDR3. Mirror axi_dma_0.
set migc0 [get_bd_addr_segs -quiet mig_7series_0/c0_memmap/c0_memaddr]
if {[llength $migc0] != 1} { error "MIG c0 segment: $migc0" }
foreach m {Data_MM2S Data_S2MM} {
    set sp [get_bd_addr_spaces -quiet axi_dma_1/$m]
    if {[llength $sp] != 1} { error "axi_dma_1/$m address space: $sp" }
    set have [get_bd_addr_segs -quiet -of_objects $sp -filter {NAME =~ "*c0_memaddr*"}]
    if {[llength $have] == 0} {
        assign_bd_address -target_address_space $sp $migc0 -offset 0x0 -range 2G
        puts "assigned DDR c0 to axi_dma_1/$m"
    }
}

# wiener_0 s_axi_control is declared as 64 KB by HLS; only 8 KB is used
# (0x0000 regs .. 0x1BFF params), and 8 KB fits in the BAR.
set_property range  8K     $wiener
set_property offset 0x4000 $wiener

puts "NEW MAP:"
foreach s [get_bd_addr_segs -of_objects $space] {
    puts "  $s  offset=[get_property offset $s] range=[get_property range $s]"
}

validate_bd_design
save_bd_design

# Make sure the propagated crossbar parameters really changed.
set xci "$root/hw/accel.srcs/sources_1/bd/top/ip/top_axi_lite_imp_xbar_1/top_axi_lite_imp_xbar_1.xci"
if {[file exists $xci]} {
    puts "XBAR PARAMS:"
    foreach p {M02_A00_BASE_ADDR M02_A00_ADDR_WIDTH M03_A00_BASE_ADDR M03_A00_ADDR_WIDTH} {
        set fh [open $xci r]; set txt [read $fh]; close $fh
        if {[regexp "\"$p\": \\\[ \\{ \"value\": \"(\[^\"]*)\"" $txt -> v]} {
            puts "  $p = $v"
        } else {
            puts "  $p = <not found>"
        }
    }
}
puts "BD ADDRESSES FIXED"
exit
