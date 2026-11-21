`timescale 1 ns / 1 ps

module wiener_stream_hls_deadlock_idx0_monitor ( // for module wiener_stream_wiener_stream_inst
    input wire clock,
    input wire reset,
    input wire [67:0] axis_block_sigs,
    input wire [20:0] inst_idle_sigs,
    input wire [4:0] inst_block_sigs,
    output wire block
);

// signal declare
reg monitor_find_block;
wire idx2_block;
wire idx5_block;
wire idx9_block;
wire idx1_block;
wire idx14_block;
wire idx13_block;
wire idx15_block;
wire sub_parallel_block;
wire all_sub_parallel_has_block;
wire all_sub_single_has_block;
wire cur_axis_has_block;
wire seq_is_axis_block;

assign block = monitor_find_block;
assign idx1_block = axis_block_sigs[0];
assign idx14_block = axis_block_sigs[66];
assign idx13_block = axis_block_sigs[65];
assign idx15_block = axis_block_sigs[67];
assign all_sub_parallel_has_block = 1'b0;
assign all_sub_single_has_block = 1'b0 | (idx2_block & (axis_block_sigs[1] | axis_block_sigs[2] | axis_block_sigs[3] | axis_block_sigs[4] | axis_block_sigs[5] | axis_block_sigs[6] | axis_block_sigs[7] | axis_block_sigs[8] | axis_block_sigs[9] | axis_block_sigs[10] | axis_block_sigs[11] | axis_block_sigs[12] | axis_block_sigs[13] | axis_block_sigs[14] | axis_block_sigs[15] | axis_block_sigs[16])) | (idx5_block & (axis_block_sigs[17] | axis_block_sigs[18] | axis_block_sigs[19] | axis_block_sigs[20] | axis_block_sigs[21] | axis_block_sigs[22] | axis_block_sigs[23] | axis_block_sigs[24] | axis_block_sigs[25] | axis_block_sigs[26] | axis_block_sigs[27] | axis_block_sigs[28] | axis_block_sigs[29] | axis_block_sigs[30] | axis_block_sigs[31] | axis_block_sigs[32] | axis_block_sigs[33] | axis_block_sigs[34] | axis_block_sigs[35] | axis_block_sigs[36] | axis_block_sigs[37] | axis_block_sigs[38] | axis_block_sigs[39] | axis_block_sigs[40] | axis_block_sigs[41] | axis_block_sigs[42] | axis_block_sigs[43] | axis_block_sigs[44] | axis_block_sigs[45] | axis_block_sigs[46] | axis_block_sigs[47] | axis_block_sigs[48])) | (idx9_block & (axis_block_sigs[49] | axis_block_sigs[50] | axis_block_sigs[51] | axis_block_sigs[52] | axis_block_sigs[53] | axis_block_sigs[54] | axis_block_sigs[55] | axis_block_sigs[56] | axis_block_sigs[57] | axis_block_sigs[58] | axis_block_sigs[59] | axis_block_sigs[60] | axis_block_sigs[61] | axis_block_sigs[62] | axis_block_sigs[63] | axis_block_sigs[64])) | (idx1_block & (axis_block_sigs[0])) | (idx14_block & (axis_block_sigs[66])) | (idx13_block & (axis_block_sigs[65])) | (idx15_block & (axis_block_sigs[67]));
assign cur_axis_has_block = 1'b0;
assign seq_is_axis_block = all_sub_parallel_has_block | all_sub_single_has_block | cur_axis_has_block;

always @(posedge clock) begin
    if (reset == 1'b1)
        monitor_find_block <= 1'b0;
    else if (seq_is_axis_block == 1'b1)
        monitor_find_block <= 1'b1;
    else
        monitor_find_block <= 1'b0;
end


// instant sub module
 wiener_stream_hls_deadlock_idx2_monitor wiener_stream_hls_deadlock_idx2_monitor_U (
    .clock(clock),
    .reset(reset),
    .axis_block_sigs(axis_block_sigs),
    .inst_idle_sigs(inst_idle_sigs),
    .inst_block_sigs(inst_block_sigs),
    .block(idx2_block)
);

 wiener_stream_hls_deadlock_idx5_monitor wiener_stream_hls_deadlock_idx5_monitor_U (
    .clock(clock),
    .reset(reset),
    .axis_block_sigs(axis_block_sigs),
    .inst_idle_sigs(inst_idle_sigs),
    .inst_block_sigs(inst_block_sigs),
    .block(idx5_block)
);

 wiener_stream_hls_deadlock_idx9_monitor wiener_stream_hls_deadlock_idx9_monitor_U (
    .clock(clock),
    .reset(reset),
    .axis_block_sigs(axis_block_sigs),
    .inst_idle_sigs(inst_idle_sigs),
    .inst_block_sigs(inst_block_sigs),
    .block(idx9_block)
);

endmodule
