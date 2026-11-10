# Build the platform bitstream (Vivado 2024.2)
#   vivado -mode batch -source scripts/build_hw.tcl
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
set proj "$root/hw/accel.xpr"

open_project $proj

# The PCIe user-clock (userclk1, 250 MHz) paths inside the Xilinx PCIe IP are
# marginal with the default strategy: use the post-route phys_opt strategy.
set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]

# BD is an out-of-context BlockSrcs source: build it first, then the wrapper.
foreach r {top_synth_1 synth_1} {
    reset_run $r
    launch_runs $r -jobs 8
    wait_on_run $r
    set st [get_property STATUS [get_runs $r]]
    puts "RUN $r: $st ([get_property PROGRESS [get_runs $r]])"
    if {[get_property PROGRESS [get_runs $r]] ne "100%"} { error "run $r failed: $st" }
}

reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
set st [get_property STATUS [get_runs impl_1]]
puts "RUN impl_1: $st ([get_property PROGRESS [get_runs impl_1]])"
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} { error "impl_1 failed: $st" }

set wns [get_property STATS.WNS [get_runs impl_1]]
set tns [get_property STATS.TNS [get_runs impl_1]]
puts "TIMING: WNS=$wns ns  TNS=$tns ns"
if {$wns < 0} {
    error "timing not met: WNS=$wns ns (see top_wrapper_timing_summary_routed.rpt)"
}

set bit "$root/hw/accel.runs/impl_1/top_wrapper.bit"
puts "BITSTREAM: $bit  ([expr {[file size $bit]/1048576}] MB)"
