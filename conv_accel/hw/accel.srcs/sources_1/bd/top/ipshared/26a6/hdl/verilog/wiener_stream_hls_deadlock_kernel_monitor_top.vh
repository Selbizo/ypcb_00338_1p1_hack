
wire kernel_monitor_reset;
wire kernel_monitor_clock;
wire kernel_monitor_report;
assign kernel_monitor_reset = ~ap_rst_n;
assign kernel_monitor_clock = ap_clk;
assign kernel_monitor_report = 1'b0;
wire [3:0] axis_block_sigs;
wire [4:0] inst_idle_sigs;
wire [0:0] inst_block_sigs;
wire kernel_block;

assign axis_block_sigs[0] = ~grp_wiener_stream_Pipeline_VITIS_LOOP_277_2_VITIS_LOOP_278_3_fu_963.din_TDATA_blk_n;
assign axis_block_sigs[1] = ~grp_wiener_stream_Pipeline_VITIS_LOOP_317_8_VITIS_LOOP_318_9_fu_1818.dout_TDATA_blk_n;
assign axis_block_sigs[2] = ~grp_wiener_stream_Pipeline_VITIS_LOOP_336_10_VITIS_LOOP_337_11_fu_1850.din_TDATA_blk_n;
assign axis_block_sigs[3] = ~grp_wiener_stream_Pipeline_VITIS_LOOP_367_16_VITIS_LOOP_368_17_fu_1881.dout_TDATA_blk_n;

assign inst_block_sigs[0] = 1'b0;

assign inst_idle_sigs[0] = 1'b0;
assign inst_idle_sigs[1] = grp_wiener_stream_Pipeline_VITIS_LOOP_277_2_VITIS_LOOP_278_3_fu_963.ap_idle;
assign inst_idle_sigs[2] = grp_wiener_stream_Pipeline_VITIS_LOOP_317_8_VITIS_LOOP_318_9_fu_1818.ap_idle;
assign inst_idle_sigs[3] = grp_wiener_stream_Pipeline_VITIS_LOOP_336_10_VITIS_LOOP_337_11_fu_1850.ap_idle;
assign inst_idle_sigs[4] = grp_wiener_stream_Pipeline_VITIS_LOOP_367_16_VITIS_LOOP_368_17_fu_1881.ap_idle;

wiener_stream_hls_deadlock_idx0_monitor wiener_stream_hls_deadlock_idx0_monitor_U (
    .clock(kernel_monitor_clock),
    .reset(kernel_monitor_reset),
    .axis_block_sigs(axis_block_sigs),
    .inst_idle_sigs(inst_idle_sigs),
    .inst_block_sigs(inst_block_sigs),
    .block(kernel_block)
);


always @ (kernel_block or kernel_monitor_reset) begin
    if (kernel_block == 1'b1 && kernel_monitor_reset == 1'b0) begin
        find_kernel_block = 1'b1;
    end
    else begin
        find_kernel_block = 1'b0;
    end
end
