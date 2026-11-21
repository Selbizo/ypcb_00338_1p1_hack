
wire kernel_monitor_reset;
wire kernel_monitor_clock;
wire kernel_monitor_report;
assign kernel_monitor_reset = ~ap_rst_n;
assign kernel_monitor_clock = ap_clk;
assign kernel_monitor_report = 1'b0;
wire [3:0] axis_block_sigs;
wire [45:0] inst_idle_sigs;
wire [40:0] inst_block_sigs;
wire kernel_block;

assign axis_block_sigs[0] = ~grp_wiener_stream_Pipeline_VITIS_LOOP_288_2_VITIS_LOOP_289_3_fu_967.din_TDATA_blk_n;
assign axis_block_sigs[1] = ~grp_wiener_stream_Pipeline_VITIS_LOOP_328_8_VITIS_LOOP_329_9_fu_2598.dout_TDATA_blk_n;
assign axis_block_sigs[2] = ~grp_wiener_stream_Pipeline_VITIS_LOOP_347_10_VITIS_LOOP_348_11_fu_2630.din_TDATA_blk_n;
assign axis_block_sigs[3] = ~grp_wiener_stream_Pipeline_VITIS_LOOP_378_16_VITIS_LOOP_379_17_fu_2661.dout_TDATA_blk_n;

assign inst_idle_sigs[0] = grp_row_pass_fu_1276.load_rows_U0.ap_idle;
assign inst_block_sigs[0] = (grp_row_pass_fu_1276.load_rows_U0.ap_done & ~grp_row_pass_fu_1276.load_rows_U0.ap_continue);
assign inst_idle_sigs[1] = grp_row_pass_fu_1276.fft_core_25_U0.ap_idle;
assign inst_block_sigs[1] = (grp_row_pass_fu_1276.fft_core_25_U0.ap_done & ~grp_row_pass_fu_1276.fft_core_25_U0.ap_continue);
assign inst_idle_sigs[2] = grp_row_pass_fu_1276.fft_core_26_U0.ap_idle;
assign inst_block_sigs[2] = (grp_row_pass_fu_1276.fft_core_26_U0.ap_done & ~grp_row_pass_fu_1276.fft_core_26_U0.ap_continue);
assign inst_idle_sigs[3] = grp_row_pass_fu_1276.fft_core_27_U0.ap_idle;
assign inst_block_sigs[3] = (grp_row_pass_fu_1276.fft_core_27_U0.ap_done & ~grp_row_pass_fu_1276.fft_core_27_U0.ap_continue);
assign inst_idle_sigs[4] = grp_row_pass_fu_1276.fft_core_28_U0.ap_idle;
assign inst_block_sigs[4] = (grp_row_pass_fu_1276.fft_core_28_U0.ap_done & ~grp_row_pass_fu_1276.fft_core_28_U0.ap_continue);
assign inst_idle_sigs[5] = grp_row_pass_fu_1276.fft_core_29_U0.ap_idle;
assign inst_block_sigs[5] = (grp_row_pass_fu_1276.fft_core_29_U0.ap_done & ~grp_row_pass_fu_1276.fft_core_29_U0.ap_continue);
assign inst_idle_sigs[6] = grp_row_pass_fu_1276.fft_core_30_U0.ap_idle;
assign inst_block_sigs[6] = (grp_row_pass_fu_1276.fft_core_30_U0.ap_done & ~grp_row_pass_fu_1276.fft_core_30_U0.ap_continue);
assign inst_idle_sigs[7] = grp_row_pass_fu_1276.fft_core_31_U0.ap_idle;
assign inst_block_sigs[7] = (grp_row_pass_fu_1276.fft_core_31_U0.ap_done & ~grp_row_pass_fu_1276.fft_core_31_U0.ap_continue);
assign inst_idle_sigs[8] = grp_row_pass_fu_1276.fft_core_U0.ap_idle;
assign inst_block_sigs[8] = (grp_row_pass_fu_1276.fft_core_U0.ap_done & ~grp_row_pass_fu_1276.fft_core_U0.ap_continue);
assign inst_idle_sigs[9] = grp_row_pass_fu_1276.store_rows_U0.ap_idle;
assign inst_block_sigs[9] = (grp_row_pass_fu_1276.store_rows_U0.ap_done & ~grp_row_pass_fu_1276.store_rows_U0.ap_continue);
assign inst_idle_sigs[10] = grp_col_pass_fu_1792.entry_proc154_U0.ap_idle;
assign inst_block_sigs[10] = (grp_col_pass_fu_1792.entry_proc154_U0.ap_done & ~grp_col_pass_fu_1792.entry_proc154_U0.ap_continue);
assign inst_idle_sigs[11] = grp_col_pass_fu_1792.load_cols_U0.ap_idle;
assign inst_block_sigs[11] = (grp_col_pass_fu_1792.load_cols_U0.ap_done & ~grp_col_pass_fu_1792.load_cols_U0.ap_continue);
assign inst_idle_sigs[12] = grp_col_pass_fu_1792.fft_core_9_U0.ap_idle;
assign inst_block_sigs[12] = (grp_col_pass_fu_1792.fft_core_9_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_9_U0.ap_continue);
assign inst_idle_sigs[13] = grp_col_pass_fu_1792.fft_core_10_U0.ap_idle;
assign inst_block_sigs[13] = (grp_col_pass_fu_1792.fft_core_10_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_10_U0.ap_continue);
assign inst_idle_sigs[14] = grp_col_pass_fu_1792.fft_core_11_U0.ap_idle;
assign inst_block_sigs[14] = (grp_col_pass_fu_1792.fft_core_11_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_11_U0.ap_continue);
assign inst_idle_sigs[15] = grp_col_pass_fu_1792.fft_core_12_U0.ap_idle;
assign inst_block_sigs[15] = (grp_col_pass_fu_1792.fft_core_12_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_12_U0.ap_continue);
assign inst_idle_sigs[16] = grp_col_pass_fu_1792.fft_core_13_U0.ap_idle;
assign inst_block_sigs[16] = (grp_col_pass_fu_1792.fft_core_13_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_13_U0.ap_continue);
assign inst_idle_sigs[17] = grp_col_pass_fu_1792.fft_core_14_U0.ap_idle;
assign inst_block_sigs[17] = (grp_col_pass_fu_1792.fft_core_14_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_14_U0.ap_continue);
assign inst_idle_sigs[18] = grp_col_pass_fu_1792.fft_core_15_U0.ap_idle;
assign inst_block_sigs[18] = (grp_col_pass_fu_1792.fft_core_15_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_15_U0.ap_continue);
assign inst_idle_sigs[19] = grp_col_pass_fu_1792.fft_core_16_U0.ap_idle;
assign inst_block_sigs[19] = (grp_col_pass_fu_1792.fft_core_16_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_16_U0.ap_continue);
assign inst_idle_sigs[20] = grp_col_pass_fu_1792.apply_g_U0.ap_idle;
assign inst_block_sigs[20] = (grp_col_pass_fu_1792.apply_g_U0.ap_done & ~grp_col_pass_fu_1792.apply_g_U0.ap_continue);
assign inst_idle_sigs[21] = grp_col_pass_fu_1792.fft_core_17_U0.ap_idle;
assign inst_block_sigs[21] = (grp_col_pass_fu_1792.fft_core_17_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_17_U0.ap_continue);
assign inst_idle_sigs[22] = grp_col_pass_fu_1792.fft_core_18_U0.ap_idle;
assign inst_block_sigs[22] = (grp_col_pass_fu_1792.fft_core_18_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_18_U0.ap_continue);
assign inst_idle_sigs[23] = grp_col_pass_fu_1792.fft_core_19_U0.ap_idle;
assign inst_block_sigs[23] = (grp_col_pass_fu_1792.fft_core_19_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_19_U0.ap_continue);
assign inst_idle_sigs[24] = grp_col_pass_fu_1792.fft_core_20_U0.ap_idle;
assign inst_block_sigs[24] = (grp_col_pass_fu_1792.fft_core_20_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_20_U0.ap_continue);
assign inst_idle_sigs[25] = grp_col_pass_fu_1792.fft_core_21_U0.ap_idle;
assign inst_block_sigs[25] = (grp_col_pass_fu_1792.fft_core_21_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_21_U0.ap_continue);
assign inst_idle_sigs[26] = grp_col_pass_fu_1792.fft_core_22_U0.ap_idle;
assign inst_block_sigs[26] = (grp_col_pass_fu_1792.fft_core_22_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_22_U0.ap_continue);
assign inst_idle_sigs[27] = grp_col_pass_fu_1792.fft_core_23_U0.ap_idle;
assign inst_block_sigs[27] = (grp_col_pass_fu_1792.fft_core_23_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_23_U0.ap_continue);
assign inst_idle_sigs[28] = grp_col_pass_fu_1792.fft_core_24_U0.ap_idle;
assign inst_block_sigs[28] = (grp_col_pass_fu_1792.fft_core_24_U0.ap_done & ~grp_col_pass_fu_1792.fft_core_24_U0.ap_continue);
assign inst_idle_sigs[29] = grp_col_pass_fu_1792.store_cols_U0.ap_idle;
assign inst_block_sigs[29] = (grp_col_pass_fu_1792.store_cols_U0.ap_done & ~grp_col_pass_fu_1792.store_cols_U0.ap_continue);
assign inst_idle_sigs[30] = grp_inv_pass_fu_2319.entry_proc_U0.ap_idle;
assign inst_block_sigs[30] = (grp_inv_pass_fu_2319.entry_proc_U0.ap_done & ~grp_inv_pass_fu_2319.entry_proc_U0.ap_continue);
assign inst_idle_sigs[31] = grp_inv_pass_fu_2319.load_rows2_U0.ap_idle;
assign inst_block_sigs[31] = (grp_inv_pass_fu_2319.load_rows2_U0.ap_done & ~grp_inv_pass_fu_2319.load_rows2_U0.ap_continue);
assign inst_idle_sigs[32] = grp_inv_pass_fu_2319.fft_core_1_U0.ap_idle;
assign inst_block_sigs[32] = (grp_inv_pass_fu_2319.fft_core_1_U0.ap_done & ~grp_inv_pass_fu_2319.fft_core_1_U0.ap_continue);
assign inst_idle_sigs[33] = grp_inv_pass_fu_2319.fft_core_2_U0.ap_idle;
assign inst_block_sigs[33] = (grp_inv_pass_fu_2319.fft_core_2_U0.ap_done & ~grp_inv_pass_fu_2319.fft_core_2_U0.ap_continue);
assign inst_idle_sigs[34] = grp_inv_pass_fu_2319.fft_core_3_U0.ap_idle;
assign inst_block_sigs[34] = (grp_inv_pass_fu_2319.fft_core_3_U0.ap_done & ~grp_inv_pass_fu_2319.fft_core_3_U0.ap_continue);
assign inst_idle_sigs[35] = grp_inv_pass_fu_2319.fft_core_4_U0.ap_idle;
assign inst_block_sigs[35] = (grp_inv_pass_fu_2319.fft_core_4_U0.ap_done & ~grp_inv_pass_fu_2319.fft_core_4_U0.ap_continue);
assign inst_idle_sigs[36] = grp_inv_pass_fu_2319.fft_core_5_U0.ap_idle;
assign inst_block_sigs[36] = (grp_inv_pass_fu_2319.fft_core_5_U0.ap_done & ~grp_inv_pass_fu_2319.fft_core_5_U0.ap_continue);
assign inst_idle_sigs[37] = grp_inv_pass_fu_2319.fft_core_6_U0.ap_idle;
assign inst_block_sigs[37] = (grp_inv_pass_fu_2319.fft_core_6_U0.ap_done & ~grp_inv_pass_fu_2319.fft_core_6_U0.ap_continue);
assign inst_idle_sigs[38] = grp_inv_pass_fu_2319.fft_core_7_U0.ap_idle;
assign inst_block_sigs[38] = (grp_inv_pass_fu_2319.fft_core_7_U0.ap_done & ~grp_inv_pass_fu_2319.fft_core_7_U0.ap_continue);
assign inst_idle_sigs[39] = grp_inv_pass_fu_2319.fft_core_8_U0.ap_idle;
assign inst_block_sigs[39] = (grp_inv_pass_fu_2319.fft_core_8_U0.ap_done & ~grp_inv_pass_fu_2319.fft_core_8_U0.ap_continue);
assign inst_idle_sigs[40] = grp_inv_pass_fu_2319.store_tile_U0.ap_idle;
assign inst_block_sigs[40] = (grp_inv_pass_fu_2319.store_tile_U0.ap_done & ~grp_inv_pass_fu_2319.store_tile_U0.ap_continue);

assign inst_idle_sigs[41] = 1'b0;
assign inst_idle_sigs[42] = grp_wiener_stream_Pipeline_VITIS_LOOP_288_2_VITIS_LOOP_289_3_fu_967.ap_idle;
assign inst_idle_sigs[43] = grp_wiener_stream_Pipeline_VITIS_LOOP_328_8_VITIS_LOOP_329_9_fu_2598.ap_idle;
assign inst_idle_sigs[44] = grp_wiener_stream_Pipeline_VITIS_LOOP_347_10_VITIS_LOOP_348_11_fu_2630.ap_idle;
assign inst_idle_sigs[45] = grp_wiener_stream_Pipeline_VITIS_LOOP_378_16_VITIS_LOOP_379_17_fu_2661.ap_idle;

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
