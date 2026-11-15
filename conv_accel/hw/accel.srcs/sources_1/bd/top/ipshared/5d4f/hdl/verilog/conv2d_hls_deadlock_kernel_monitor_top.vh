
wire kernel_monitor_reset;
wire kernel_monitor_clock;
wire kernel_monitor_report;
assign kernel_monitor_reset = ~ap_rst_n;
assign kernel_monitor_clock = ap_clk;
assign kernel_monitor_report = 1'b0;
wire [1:0] axis_block_sigs;
wire [7:0] inst_idle_sigs;
wire [2:0] inst_block_sigs;
wire kernel_block;

assign axis_block_sigs[0] = ~load_frame_10_2160_3840_1_U0.grp_load_frame_10_2160_3840_1_Pipeline_load_rows_load_cols_fu_90.video_in_TDATA_blk_n;
assign axis_block_sigs[1] = ~store_frame_10_2160_3840_1_U0.grp_store_frame_10_2160_3840_1_Pipeline_store_rows_store_cols_fu_68.video_out_TDATA_blk_n;

assign inst_idle_sigs[0] = load_frame_10_2160_3840_1_U0.ap_idle;
assign inst_block_sigs[0] = (load_frame_10_2160_3840_1_U0.ap_done & ~load_frame_10_2160_3840_1_U0.ap_continue) | ~load_frame_10_2160_3840_1_U0.grp_load_frame_10_2160_3840_1_Pipeline_load_rows_load_cols_fu_90.src_data_blk_n | ~load_frame_10_2160_3840_1_U0.rows_c3_blk_n | ~load_frame_10_2160_3840_1_U0.cols_c4_blk_n;
assign inst_idle_sigs[1] = filter2D_1_5_5_10_10_2160_3840_1_2_2_U0.ap_idle;
assign inst_block_sigs[1] = (filter2D_1_5_5_10_10_2160_3840_1_2_2_U0.ap_done & ~filter2D_1_5_5_10_10_2160_3840_1_2_2_U0.ap_continue) | ~filter2D_1_5_5_10_10_2160_3840_1_2_2_U0.p_src_mat_rows_val_blk_n | ~filter2D_1_5_5_10_10_2160_3840_1_2_2_U0.p_src_mat_cols_val_blk_n | ~filter2D_1_5_5_10_10_2160_3840_1_2_2_U0.grp_xFFilter2Dkernel_10_10_2160_3840_5_5_1_2_2_14_14_3840_5_5_4_s_fu_66.grp_xFFilter2Dkernel_Pipeline_COL_LOOP_fu_76.src_data_blk_n | ~filter2D_1_5_5_10_10_2160_3840_1_2_2_U0.grp_xFFilter2Dkernel_10_10_2160_3840_5_5_1_2_2_14_14_3840_5_5_4_s_fu_66.grp_xFFilter2Dkernel_Pipeline_COL_LOOP_fu_76.dst_data_blk_n | ~filter2D_1_5_5_10_10_2160_3840_1_2_2_U0.rows_c_blk_n | ~filter2D_1_5_5_10_10_2160_3840_1_2_2_U0.cols_c_blk_n;
assign inst_idle_sigs[2] = store_frame_10_2160_3840_1_U0.ap_idle;
assign inst_block_sigs[2] = (store_frame_10_2160_3840_1_U0.ap_done & ~store_frame_10_2160_3840_1_U0.ap_continue) | ~store_frame_10_2160_3840_1_U0.img_rows_val_blk_n | ~store_frame_10_2160_3840_1_U0.img_cols_val_blk_n | ~store_frame_10_2160_3840_1_U0.grp_store_frame_10_2160_3840_1_Pipeline_store_rows_store_cols_fu_68.dst_data_blk_n;

assign inst_idle_sigs[3] = 1'b0;
assign inst_idle_sigs[4] = load_frame_10_2160_3840_1_U0.ap_idle;
assign inst_idle_sigs[5] = load_frame_10_2160_3840_1_U0.grp_load_frame_10_2160_3840_1_Pipeline_load_rows_load_cols_fu_90.ap_idle;
assign inst_idle_sigs[6] = store_frame_10_2160_3840_1_U0.ap_idle;
assign inst_idle_sigs[7] = store_frame_10_2160_3840_1_U0.grp_store_frame_10_2160_3840_1_Pipeline_store_rows_store_cols_fu_68.ap_idle;

conv2d_hls_deadlock_idx0_monitor conv2d_hls_deadlock_idx0_monitor_U (
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
