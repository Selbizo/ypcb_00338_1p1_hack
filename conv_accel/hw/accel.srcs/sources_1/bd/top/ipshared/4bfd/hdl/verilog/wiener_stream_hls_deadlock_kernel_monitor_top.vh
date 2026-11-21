
wire kernel_monitor_reset;
wire kernel_monitor_clock;
wire kernel_monitor_report;
assign kernel_monitor_reset = ~ap_rst_n;
assign kernel_monitor_clock = ap_clk;
assign kernel_monitor_report = 1'b0;
wire [67:0] axis_block_sigs;
wire [20:0] inst_idle_sigs;
wire [4:0] inst_block_sigs;
wire kernel_block;

assign axis_block_sigs[0] = ~grp_wiener_stream_Pipeline_VITIS_LOOP_234_2_VITIS_LOOP_235_3_fu_1158.din_TDATA_blk_n;
assign axis_block_sigs[1] = ~grp_wiener_stream_Pipeline_VITIS_LOOP_281_8_VITIS_LOOP_282_9_fu_1189.dout_TDATA_blk_n;
assign axis_block_sigs[2] = ~grp_row_pass_fu_1499.send_rows_1_U0.fwd_in_0_TDATA_blk_n;
assign axis_block_sigs[3] = ~grp_row_pass_fu_1499.send_rows_1_U0.fwd_in_1_TDATA_blk_n;
assign axis_block_sigs[4] = ~grp_row_pass_fu_1499.send_rows_1_U0.fwd_in_2_TDATA_blk_n;
assign axis_block_sigs[5] = ~grp_row_pass_fu_1499.send_rows_1_U0.fwd_in_3_TDATA_blk_n;
assign axis_block_sigs[6] = ~grp_row_pass_fu_1499.send_rows_1_U0.fwd_in_4_TDATA_blk_n;
assign axis_block_sigs[7] = ~grp_row_pass_fu_1499.send_rows_1_U0.fwd_in_5_TDATA_blk_n;
assign axis_block_sigs[8] = ~grp_row_pass_fu_1499.send_rows_1_U0.fwd_in_6_TDATA_blk_n;
assign axis_block_sigs[9] = ~grp_row_pass_fu_1499.send_rows_1_U0.fwd_in_7_TDATA_blk_n;
assign axis_block_sigs[10] = ~grp_row_pass_fu_1499.recv_rows_U0.fwd_out_0_TDATA_blk_n;
assign axis_block_sigs[11] = ~grp_row_pass_fu_1499.recv_rows_U0.fwd_out_1_TDATA_blk_n;
assign axis_block_sigs[12] = ~grp_row_pass_fu_1499.recv_rows_U0.fwd_out_2_TDATA_blk_n;
assign axis_block_sigs[13] = ~grp_row_pass_fu_1499.recv_rows_U0.fwd_out_3_TDATA_blk_n;
assign axis_block_sigs[14] = ~grp_row_pass_fu_1499.recv_rows_U0.fwd_out_4_TDATA_blk_n;
assign axis_block_sigs[15] = ~grp_row_pass_fu_1499.recv_rows_U0.fwd_out_5_TDATA_blk_n;
assign axis_block_sigs[16] = ~grp_row_pass_fu_1499.recv_rows_U0.fwd_out_6_TDATA_blk_n;
assign axis_block_sigs[17] = ~grp_row_pass_fu_1499.recv_rows_U0.fwd_out_7_TDATA_blk_n;
assign axis_block_sigs[18] = ~grp_col_pass_fu_2143.send_cols_U0.fwd_in_0_TDATA_blk_n;
assign axis_block_sigs[19] = ~grp_col_pass_fu_2143.send_cols_U0.fwd_in_1_TDATA_blk_n;
assign axis_block_sigs[20] = ~grp_col_pass_fu_2143.send_cols_U0.fwd_in_2_TDATA_blk_n;
assign axis_block_sigs[21] = ~grp_col_pass_fu_2143.send_cols_U0.fwd_in_3_TDATA_blk_n;
assign axis_block_sigs[22] = ~grp_col_pass_fu_2143.send_cols_U0.fwd_in_4_TDATA_blk_n;
assign axis_block_sigs[23] = ~grp_col_pass_fu_2143.send_cols_U0.fwd_in_5_TDATA_blk_n;
assign axis_block_sigs[24] = ~grp_col_pass_fu_2143.send_cols_U0.fwd_in_6_TDATA_blk_n;
assign axis_block_sigs[25] = ~grp_col_pass_fu_2143.send_cols_U0.fwd_in_7_TDATA_blk_n;
assign axis_block_sigs[26] = ~grp_col_pass_fu_2143.recv_cols_g_U0.fwd_out_0_TDATA_blk_n;
assign axis_block_sigs[27] = ~grp_col_pass_fu_2143.recv_cols_g_U0.fwd_out_1_TDATA_blk_n;
assign axis_block_sigs[28] = ~grp_col_pass_fu_2143.recv_cols_g_U0.fwd_out_2_TDATA_blk_n;
assign axis_block_sigs[29] = ~grp_col_pass_fu_2143.recv_cols_g_U0.fwd_out_3_TDATA_blk_n;
assign axis_block_sigs[30] = ~grp_col_pass_fu_2143.recv_cols_g_U0.fwd_out_4_TDATA_blk_n;
assign axis_block_sigs[31] = ~grp_col_pass_fu_2143.recv_cols_g_U0.fwd_out_5_TDATA_blk_n;
assign axis_block_sigs[32] = ~grp_col_pass_fu_2143.recv_cols_g_U0.fwd_out_6_TDATA_blk_n;
assign axis_block_sigs[33] = ~grp_col_pass_fu_2143.recv_cols_g_U0.fwd_out_7_TDATA_blk_n;
assign axis_block_sigs[34] = ~grp_col_pass_fu_2143.recv_cols_g_U0.inv_in_0_TDATA_blk_n;
assign axis_block_sigs[35] = ~grp_col_pass_fu_2143.recv_cols_g_U0.inv_in_1_TDATA_blk_n;
assign axis_block_sigs[36] = ~grp_col_pass_fu_2143.recv_cols_g_U0.inv_in_2_TDATA_blk_n;
assign axis_block_sigs[37] = ~grp_col_pass_fu_2143.recv_cols_g_U0.inv_in_3_TDATA_blk_n;
assign axis_block_sigs[38] = ~grp_col_pass_fu_2143.recv_cols_g_U0.inv_in_4_TDATA_blk_n;
assign axis_block_sigs[39] = ~grp_col_pass_fu_2143.recv_cols_g_U0.inv_in_5_TDATA_blk_n;
assign axis_block_sigs[40] = ~grp_col_pass_fu_2143.recv_cols_g_U0.inv_in_6_TDATA_blk_n;
assign axis_block_sigs[41] = ~grp_col_pass_fu_2143.recv_cols_g_U0.inv_in_7_TDATA_blk_n;
assign axis_block_sigs[42] = ~grp_col_pass_fu_2143.recv_cols_U0.inv_out_0_TDATA_blk_n;
assign axis_block_sigs[43] = ~grp_col_pass_fu_2143.recv_cols_U0.inv_out_1_TDATA_blk_n;
assign axis_block_sigs[44] = ~grp_col_pass_fu_2143.recv_cols_U0.inv_out_2_TDATA_blk_n;
assign axis_block_sigs[45] = ~grp_col_pass_fu_2143.recv_cols_U0.inv_out_3_TDATA_blk_n;
assign axis_block_sigs[46] = ~grp_col_pass_fu_2143.recv_cols_U0.inv_out_4_TDATA_blk_n;
assign axis_block_sigs[47] = ~grp_col_pass_fu_2143.recv_cols_U0.inv_out_5_TDATA_blk_n;
assign axis_block_sigs[48] = ~grp_col_pass_fu_2143.recv_cols_U0.inv_out_6_TDATA_blk_n;
assign axis_block_sigs[49] = ~grp_col_pass_fu_2143.recv_cols_U0.inv_out_7_TDATA_blk_n;
assign axis_block_sigs[50] = ~grp_inv_rows_fu_2926.grp_send_rows_fu_482.inv_in_0_TDATA_blk_n;
assign axis_block_sigs[51] = ~grp_inv_rows_fu_2926.grp_send_rows_fu_482.inv_in_1_TDATA_blk_n;
assign axis_block_sigs[52] = ~grp_inv_rows_fu_2926.grp_send_rows_fu_482.inv_in_2_TDATA_blk_n;
assign axis_block_sigs[53] = ~grp_inv_rows_fu_2926.grp_send_rows_fu_482.inv_in_3_TDATA_blk_n;
assign axis_block_sigs[54] = ~grp_inv_rows_fu_2926.grp_send_rows_fu_482.inv_in_4_TDATA_blk_n;
assign axis_block_sigs[55] = ~grp_inv_rows_fu_2926.grp_send_rows_fu_482.inv_in_5_TDATA_blk_n;
assign axis_block_sigs[56] = ~grp_inv_rows_fu_2926.grp_send_rows_fu_482.inv_in_6_TDATA_blk_n;
assign axis_block_sigs[57] = ~grp_inv_rows_fu_2926.grp_send_rows_fu_482.inv_in_7_TDATA_blk_n;
assign axis_block_sigs[58] = ~grp_inv_rows_fu_2926.grp_inv_rows_Outline_VITIS_LOOP_163_1_fu_806.grp_inv_rows_Pipeline_VITIS_LOOP_166_2_fu_288.inv_out_0_TDATA_blk_n;
assign axis_block_sigs[59] = ~grp_inv_rows_fu_2926.grp_inv_rows_Outline_VITIS_LOOP_163_1_fu_806.grp_inv_rows_Pipeline_VITIS_LOOP_166_2_fu_288.inv_out_1_TDATA_blk_n;
assign axis_block_sigs[60] = ~grp_inv_rows_fu_2926.grp_inv_rows_Outline_VITIS_LOOP_163_1_fu_806.grp_inv_rows_Pipeline_VITIS_LOOP_166_2_fu_288.inv_out_2_TDATA_blk_n;
assign axis_block_sigs[61] = ~grp_inv_rows_fu_2926.grp_inv_rows_Outline_VITIS_LOOP_163_1_fu_806.grp_inv_rows_Pipeline_VITIS_LOOP_166_2_fu_288.inv_out_3_TDATA_blk_n;
assign axis_block_sigs[62] = ~grp_inv_rows_fu_2926.grp_inv_rows_Outline_VITIS_LOOP_163_1_fu_806.grp_inv_rows_Pipeline_VITIS_LOOP_166_2_fu_288.inv_out_4_TDATA_blk_n;
assign axis_block_sigs[63] = ~grp_inv_rows_fu_2926.grp_inv_rows_Outline_VITIS_LOOP_163_1_fu_806.grp_inv_rows_Pipeline_VITIS_LOOP_166_2_fu_288.inv_out_5_TDATA_blk_n;
assign axis_block_sigs[64] = ~grp_inv_rows_fu_2926.grp_inv_rows_Outline_VITIS_LOOP_163_1_fu_806.grp_inv_rows_Pipeline_VITIS_LOOP_166_2_fu_288.inv_out_6_TDATA_blk_n;
assign axis_block_sigs[65] = ~grp_inv_rows_fu_2926.grp_inv_rows_Outline_VITIS_LOOP_163_1_fu_806.grp_inv_rows_Pipeline_VITIS_LOOP_166_2_fu_288.inv_out_7_TDATA_blk_n;
assign axis_block_sigs[66] = ~grp_wiener_stream_Pipeline_VITIS_LOOP_298_10_VITIS_LOOP_299_11_fu_3333.din_TDATA_blk_n;
assign axis_block_sigs[67] = ~grp_wiener_stream_Pipeline_VITIS_LOOP_331_16_VITIS_LOOP_332_17_fu_3364.dout_TDATA_blk_n;

assign inst_idle_sigs[0] = grp_row_pass_fu_1499.send_rows_1_U0.ap_idle;
assign inst_block_sigs[0] = (grp_row_pass_fu_1499.send_rows_1_U0.ap_done & ~grp_row_pass_fu_1499.send_rows_1_U0.ap_continue);
assign inst_idle_sigs[1] = grp_row_pass_fu_1499.recv_rows_U0.ap_idle;
assign inst_block_sigs[1] = (grp_row_pass_fu_1499.recv_rows_U0.ap_done & ~grp_row_pass_fu_1499.recv_rows_U0.ap_continue);
assign inst_idle_sigs[2] = grp_col_pass_fu_2143.send_cols_U0.ap_idle;
assign inst_block_sigs[2] = (grp_col_pass_fu_2143.send_cols_U0.ap_done & ~grp_col_pass_fu_2143.send_cols_U0.ap_continue);
assign inst_idle_sigs[3] = grp_col_pass_fu_2143.recv_cols_g_U0.ap_idle;
assign inst_block_sigs[3] = (grp_col_pass_fu_2143.recv_cols_g_U0.ap_done & ~grp_col_pass_fu_2143.recv_cols_g_U0.ap_continue);
assign inst_idle_sigs[4] = grp_col_pass_fu_2143.recv_cols_U0.ap_idle;
assign inst_block_sigs[4] = (grp_col_pass_fu_2143.recv_cols_U0.ap_done & ~grp_col_pass_fu_2143.recv_cols_U0.ap_continue);

assign inst_idle_sigs[5] = 1'b0;
assign inst_idle_sigs[6] = grp_wiener_stream_Pipeline_VITIS_LOOP_234_2_VITIS_LOOP_235_3_fu_1158.ap_idle;
assign inst_idle_sigs[7] = grp_wiener_stream_Pipeline_VITIS_LOOP_281_8_VITIS_LOOP_282_9_fu_1189.ap_idle;
assign inst_idle_sigs[8] = grp_row_pass_fu_1499.ap_idle;
assign inst_idle_sigs[9] = grp_row_pass_fu_1499.send_rows_1_U0.ap_idle;
assign inst_idle_sigs[10] = grp_row_pass_fu_1499.recv_rows_U0.ap_idle;
assign inst_idle_sigs[11] = grp_col_pass_fu_2143.ap_idle;
assign inst_idle_sigs[12] = grp_col_pass_fu_2143.send_cols_U0.ap_idle;
assign inst_idle_sigs[13] = grp_col_pass_fu_2143.recv_cols_g_U0.ap_idle;
assign inst_idle_sigs[14] = grp_col_pass_fu_2143.recv_cols_U0.ap_idle;
assign inst_idle_sigs[15] = grp_inv_rows_fu_2926.ap_idle;
assign inst_idle_sigs[16] = grp_inv_rows_fu_2926.grp_send_rows_fu_482.ap_idle;
assign inst_idle_sigs[17] = grp_inv_rows_fu_2926.grp_inv_rows_Outline_VITIS_LOOP_163_1_fu_806.ap_idle;
assign inst_idle_sigs[18] = grp_inv_rows_fu_2926.grp_inv_rows_Outline_VITIS_LOOP_163_1_fu_806.grp_inv_rows_Pipeline_VITIS_LOOP_166_2_fu_288.ap_idle;
assign inst_idle_sigs[19] = grp_wiener_stream_Pipeline_VITIS_LOOP_298_10_VITIS_LOOP_299_11_fu_3333.ap_idle;
assign inst_idle_sigs[20] = grp_wiener_stream_Pipeline_VITIS_LOOP_331_16_VITIS_LOOP_332_17_fu_3364.ap_idle;

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
