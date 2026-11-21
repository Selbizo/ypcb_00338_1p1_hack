# Minimal xfft hardware test.
#   24-bit counter -> s_axis_data (continuous, tlast every 256)
#   config tvalid = 1, tdata = 0, aclken = 1
#   m_axis_data -> system_ila (1 AXIS slot, 8192 deep)
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
open_project "$root/hw/accel.xpr"
open_bd_design [get_files -quiet top.bd]

proc mk {name vlnv} {
    if {[llength [get_bd_cells -quiet $name]] == 0} {
        create_bd_cell -type ip -vlnv $vlnv $name
    }
    return [get_bd_cells $name]
}

mk test_fft xilinx.com:ip:xfft:9.1
set_property -dict [list \
    CONFIG.transform_length {256} \
    CONFIG.implementation_options {pipelined_streaming_io} \
    CONFIG.data_format {fixed_point} \
    CONFIG.input_width {24} \
    CONFIG.scaling_options {unscaled} \
    CONFIG.rounding_modes {convergent_rounding} \
    CONFIG.output_ordering {natural_order} \
    CONFIG.throttle_scheme {realtime} \
    CONFIG.ovflo {false} \
    CONFIG.phase_factor_width {16} \
    CONFIG.aresetn {true} \
    CONFIG.aclken {true} \
] [get_bd_cells test_fft]

mk test_cnt xilinx.com:ip:c_counter_binary:12.0
set_property -dict [list CONFIG.Output_Width {24} CONFIG.CE {true} CONFIG.SCLR {true}] [get_bd_cells test_cnt]

mk test_one xilinx.com:ip:xlconstant:1.1
set_property -dict [list CONFIG.CONST_WIDTH {1} CONFIG.CONST_VAL {1}] [get_bd_cells test_one]

mk test_zero24 xilinx.com:ip:xlconstant:1.1
set_property -dict [list CONFIG.CONST_WIDTH {24} CONFIG.CONST_VAL {0}] [get_bd_cells test_zero24]

mk test_cfg0 xilinx.com:ip:xlconstant:1.1
set_property -dict [list CONFIG.CONST_WIDTH {8} CONFIG.CONST_VAL {0}] [get_bd_cells test_cfg0]

mk test_slice xilinx.com:ip:xlslice:1.0
set_property -dict [list CONFIG.DIN_WIDTH {24} CONFIG.DIN_FROM {7} CONFIG.DIN_TO {0} CONFIG.DOUT_WIDTH {8}] [get_bd_cells test_slice]

mk test_tlast xilinx.com:ip:util_reduced_logic:2.0
set_property -dict [list CONFIG.C_OPERATION {and} CONFIG.C_SIZE {8}] [get_bd_cells test_tlast]

mk test_concat xilinx.com:ip:xlconcat:2.1
set_property -dict [list CONFIG.NUM_PORTS {2} CONFIG.IN0_WIDTH {24} CONFIG.IN1_WIDTH {24}] [get_bd_cells test_concat]

mk test_ila xilinx.com:ip:system_ila:1.1
set_property -dict [list CONFIG.C_NUM_MONITOR_SLOTS {1} CONFIG.C_DATA_DEPTH {8192} \
    CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0}] [get_bd_cells test_ila]

# clock / reset
connect_bd_net [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins test_cnt/CLK] [get_bd_pins test_fft/aclk] [get_bd_pins test_ila/clk]
connect_bd_net [get_bd_pins rst_215/peripheral_reset] [get_bd_pins test_cnt/SCLR]
connect_bd_net [get_bd_pins rst_215/peripheral_aresetn] [get_bd_pins test_fft/aresetn] [get_bd_pins test_ila/resetn]

# stimulus
connect_bd_net [get_bd_pins test_one/dout] [get_bd_pins test_cnt/CE] \
    [get_bd_pins test_fft/aclken] [get_bd_pins test_fft/s_axis_data_tvalid] \
    [get_bd_pins test_fft/s_axis_config_tvalid]
connect_bd_net [get_bd_pins test_cfg0/dout] [get_bd_pins test_fft/s_axis_config_tdata]
connect_bd_net [get_bd_pins test_cnt/Q] [get_bd_pins test_concat/In0] [get_bd_pins test_slice/Din]
connect_bd_net [get_bd_pins test_zero24/dout] [get_bd_pins test_concat/In1]
connect_bd_net [get_bd_pins test_concat/dout] [get_bd_pins test_fft/s_axis_data_tdata]
connect_bd_net [get_bd_pins test_slice/Dout] [get_bd_pins test_tlast/Op1]
connect_bd_net [get_bd_pins test_tlast/Res] [get_bd_pins test_fft/s_axis_data_tlast]

# monitor the FFT output
connect_bd_intf_net [get_bd_intf_pins test_ila/SLOT_0_AXIS] [get_bd_intf_pins test_fft/M_AXIS_DATA]

validate_bd_design
save_bd_design
puts "minimal xfft test added"
exit
