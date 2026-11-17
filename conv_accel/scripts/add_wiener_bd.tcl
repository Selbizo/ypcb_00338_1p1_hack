# Add the Y-plane Wiener path.  Kernel + FFTs run at 215 MHz (215 MHz was the
# safe point after the 250 MHz run showed WNS -0.547 ns); the DMA and AXI-Lite
# stay at the 250 MHz PCIe user clock and cross through clock converters.
# AXI-Lite MI3 gets 13 address bits: params[] sits at 0x1000..0x1fff inside
# the kernel's 8 KB s_axilite window.
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
open_project "$root/hw/accel.xpr"

set_property ip_repo_paths [concat [get_property ip_repo_paths [current_project]] [list "$root/hw/ip_repo"]] [current_project]
update_ip_catalog -rebuild

open_bd_design [get_files top.bd]

# --- clocks ---
set_property -dict [list \
  CONFIG.CLKOUT3_USED {true} \
  CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {215.000}] [get_bd_cells clk_wiz_1]
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_215
connect_bd_net [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins rst_215/slowest_sync_clk]
connect_bd_net [get_bd_pins resetn_inv_0/Res]   [get_bd_pins rst_215/ext_reset_in]
connect_bd_net [get_bd_pins clk_wiz_1/locked]    [get_bd_pins rst_215/dcm_locked]

# --- AXI-Lite: 4 MIs, MI3 is 8 KB (kernel params) ---
set_property -dict [list \
  CONFIG.NUM_MI {4} \
  CONFIG.C_M_AXI_BASE_ADDR {0x00000000 0x00001000 0x00002000 0x00003000} \
  CONFIG.C_M_AXI_ADDR_WIDTH {12 12 12 13}] [get_bd_cells axi_lite]

# --- SmartConnect: 6 SIs ---
set_property -dict [list CONFIG.NUM_SI {6}] [get_bd_cells axi_smc]

# --- constants ---
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_one
set_property -dict [list CONFIG.CONST_WIDTH {1} CONFIG.CONST_VAL {1}] [get_bd_cells const_one]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_c0
set_property -dict [list CONFIG.CONST_WIDTH {8} CONFIG.CONST_VAL {0}] [get_bd_cells const_c0]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_c1
set_property -dict [list CONFIG.CONST_WIDTH {8} CONFIG.CONST_VAL {1}] [get_bd_cells const_c1]

# --- second DMA ---
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_1
set_property -dict [list \
  CONFIG.c_include_sg {0} CONFIG.c_sg_length_width {26} \
  CONFIG.c_include_mm2s {1} CONFIG.c_include_s2mm {1} \
  CONFIG.c_m_axi_mm2s_data_width {64} CONFIG.c_m_axi_s2mm_data_width {64} \
  CONFIG.c_m_axis_mm2s_tdata_width {32} CONFIG.c_s_axis_s2mm_tdata_width {32} \
  CONFIG.c_addr_width {32}] [get_bd_cells axi_dma_1]

# --- wiener kernel ---
create_bd_cell -type ip -vlnv user:hls:wiener_stream:1.0 wiener_0

# --- 16 FFT cores ---
set fftcfg [list \
  CONFIG.transform_length {256} CONFIG.implementation_options {pipelined_streaming_io} \
  CONFIG.data_format {fixed_point} CONFIG.input_width {24} CONFIG.phase_factor_width {16} \
  CONFIG.scaling_options {unscaled} CONFIG.rounding_modes {convergent_rounding} \
  CONFIG.output_ordering {natural_order} CONFIG.throttle_scheme {realtime} \
  CONFIG.aclken {true} CONFIG.aresetn {true} CONFIG.ovflo {true}]
for {set i 0} {$i < 8} {incr i} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:xfft:9.1 fft_fwd_$i
    set_property -dict $fftcfg [get_bd_cells fft_fwd_$i]
    create_bd_cell -type ip -vlnv xilinx.com:ip:xfft:9.1 fft_inv_$i
    set_property -dict $fftcfg [get_bd_cells fft_inv_$i]
}

# --- clock converters ---
create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 din_cc
set_property -dict [list CONFIG.TDATA_NUM_BYTES {4} CONFIG.HAS_TKEEP {1} \
  CONFIG.HAS_TSTRB {1} CONFIG.HAS_TLAST {1}] [get_bd_cells din_cc]
create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 dout_cc
set_property -dict [list CONFIG.TDATA_NUM_BYTES {4} CONFIG.HAS_TKEEP {1} \
  CONFIG.HAS_TSTRB {1} CONFIG.HAS_TLAST {1}] [get_bd_cells dout_cc]
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_clock_converter:2.1 lite_cc
set_property -dict [list CONFIG.PROTOCOL {AXI4LITE} CONFIG.ADDR_WIDTH {13} \
  CONFIG.DATA_WIDTH {32}] [get_bd_cells lite_cc]

# --- 250 MHz domain ---
set clk [get_bd_pins xdma_0/axi_aclk]
set rst [get_bd_pins xdma_0/axi_aresetn]
connect_bd_net $clk \
    [get_bd_pins axi_dma_1/s_axi_lite_aclk] \
    [get_bd_pins axi_dma_1/m_axi_mm2s_aclk] \
    [get_bd_pins axi_dma_1/m_axi_s2mm_aclk] \
    [get_bd_pins axi_lite/M02_ACLK] [get_bd_pins axi_lite/M03_ACLK] \
    [get_bd_pins axi_smc/aclk5] [get_bd_pins axi_smc/aclk6] \
    [get_bd_pins din_cc/s_axis_aclk] [get_bd_pins dout_cc/m_axis_aclk] \
    [get_bd_pins lite_cc/s_axi_aclk]
connect_bd_net $rst \
    [get_bd_pins axi_dma_1/axi_resetn] \
    [get_bd_pins axi_lite/M02_ARESETN] [get_bd_pins axi_lite/M03_ARESETN] \
    [get_bd_pins din_cc/s_axis_aresetn] [get_bd_pins dout_cc/m_axis_aresetn] \
    [get_bd_pins lite_cc/s_axi_aresetn]

# --- 215 MHz domain ---
set clk215 [get_bd_pins clk_wiz_1/clk_out3]
set rst215 [get_bd_pins rst_215/peripheral_aresetn]
connect_bd_net $clk215 \
    [get_bd_pins wiener_0/ap_clk] \
    [get_bd_pins din_cc/m_axis_aclk] [get_bd_pins dout_cc/s_axis_aclk] \
    [get_bd_pins lite_cc/m_axi_aclk]
connect_bd_net $rst215 \
    [get_bd_pins wiener_0/ap_rst_n] \
    [get_bd_pins din_cc/m_axis_aresetn] [get_bd_pins dout_cc/s_axis_aresetn] \
    [get_bd_pins lite_cc/m_axi_aresetn]

for {set i 0} {$i < 8} {incr i} {
    connect_bd_net $clk215 [get_bd_pins fft_fwd_$i/aclk] [get_bd_pins fft_inv_$i/aclk]
    connect_bd_net $rst215 [get_bd_pins fft_fwd_$i/aresetn] [get_bd_pins fft_inv_$i/aresetn]
    connect_bd_net [get_bd_pins const_one/dout] \
        [get_bd_pins fft_fwd_$i/aclken] [get_bd_pins fft_inv_$i/aclken] \
        [get_bd_pins fft_fwd_$i/s_axis_config_tvalid] \
        [get_bd_pins fft_inv_$i/s_axis_config_tvalid]
    connect_bd_net [get_bd_pins const_c0/dout] [get_bd_pins fft_fwd_$i/s_axis_config_tdata]
    connect_bd_net [get_bd_pins const_c1/dout] [get_bd_pins fft_inv_$i/s_axis_config_tdata]

    connect_bd_intf_net [get_bd_intf_pins wiener_0/fwd_in_$i]  [get_bd_intf_pins fft_fwd_$i/s_axis_data]
    connect_bd_intf_net [get_bd_intf_pins fft_fwd_$i/m_axis_data] [get_bd_intf_pins wiener_0/fwd_out_$i]
    connect_bd_intf_net [get_bd_intf_pins wiener_0/inv_in_$i]  [get_bd_intf_pins fft_inv_$i/s_axis_data]
    connect_bd_intf_net [get_bd_intf_pins fft_inv_$i/m_axis_data] [get_bd_intf_pins wiener_0/inv_out_$i]
}

# --- frame streams through clock converters ---
connect_bd_intf_net [get_bd_intf_pins axi_dma_1/M_AXIS_MM2S] [get_bd_intf_pins din_cc/s_axis]
connect_bd_intf_net [get_bd_intf_pins din_cc/m_axis]         [get_bd_intf_pins wiener_0/din]
connect_bd_intf_net [get_bd_intf_pins wiener_0/dout]         [get_bd_intf_pins dout_cc/s_axis]
connect_bd_intf_net [get_bd_intf_pins dout_cc/m_axis]        [get_bd_intf_pins axi_dma_1/S_AXIS_S2MM]

# --- AXI-Lite through clock converter ---
connect_bd_intf_net [get_bd_intf_pins axi_lite/M03_AXI]      [get_bd_intf_pins lite_cc/s_axi]
connect_bd_intf_net [get_bd_intf_pins lite_cc/m_axi]         [get_bd_intf_pins wiener_0/s_axi_control]
connect_bd_intf_net [get_bd_intf_pins axi_dma_1/S_AXI_LITE]  [get_bd_intf_pins axi_lite/M02_AXI]

# --- memory ---
connect_bd_intf_net [get_bd_intf_pins axi_dma_1/M_AXI_MM2S]  [get_bd_intf_pins axi_smc/S04_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_dma_1/M_AXI_S2MM]  [get_bd_intf_pins axi_smc/S05_AXI]

assign_bd_address
validate_bd_design
save_bd_design
puts "BD updated (215 MHz kernel domain) OK"
exit
