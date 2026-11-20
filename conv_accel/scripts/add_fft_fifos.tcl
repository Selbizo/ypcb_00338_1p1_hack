# Insert an AXI4-Stream Data FIFO between every xfft output and the kernel.
#
# Why: the xfft "pipelined streaming I/O" wrapper used by the BD does not
# expose m_axis_data_tready (top_fft_*_0_0.vhd ties it to '1'), so the FFT
# streams results out regardless of the consumer.  wiener_stream reads its
# 8 fwd_out/inv_out streams in lockstep and only asserts TREADY for all of
# them when all 8 samples are present, so a single late sample destroys the
# other seven -> the pass ends short and the kernel waits forever.
# With a FIFO the kernel's TREADY is honoured and the skew is absorbed.
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
open_project "$root/hw/accel.xpr"
open_bd_design [get_files -quiet top.bd]

set depth 512

foreach kind {fwd inv} {
    for {set i 0} {$i < 8} {incr i} {
        set fft  "fft_${kind}_$i"
        set fifo "${kind}_fifo_$i"
        set kpin "${kind}_out_$i"

        if {[llength [get_bd_cells -quiet $fifo]] == 0} {
            create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 $fifo
            set_property -dict [list \
                CONFIG.FIFO_DEPTH $depth \
                CONFIG.TDATA_NUM_BYTES {10} \
                CONFIG.HAS_TKEEP {0} \
                CONFIG.HAS_TSTRB {0} \
                CONFIG.HAS_TLAST {1} \
                CONFIG.HAS_TREADY {1} \
            ] [get_bd_cells $fifo]
            connect_bd_net [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins $fifo/s_axis_aclk]
            connect_bd_net [get_bd_pins rst_215/peripheral_aresetn] [get_bd_pins $fifo/s_axis_aresetn]
            puts "created $fifo (depth $depth)"
        }

        # route fft m_axis -> fifo -> kernel
        set netname "/${fft}_M_AXIS_DATA"
        if {[llength [get_bd_intf_nets -quiet $netname]]} {
            disconnect_bd_intf_net $netname \
                [get_bd_intf_pins $fft/M_AXIS_DATA] \
                [get_bd_intf_pins wiener_0/$kpin]
        }
        connect_bd_intf_net [get_bd_intf_pins $fft/M_AXIS_DATA]  [get_bd_intf_pins $fifo/S_AXIS]
        connect_bd_intf_net [get_bd_intf_pins $fifo/M_AXIS]      [get_bd_intf_pins wiener_0/$kpin]
    }
}

validate_bd_design
save_bd_design
puts "FFT output FIFOs inserted"
exit
