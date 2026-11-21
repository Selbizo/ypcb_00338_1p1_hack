`timescale 1 ns / 1 ps

module wiener_stream_hls_deadlock_idx6_monitor ( // for module wiener_stream_wiener_stream_inst.grp_col_pass_fu_2143
    input wire clock,
    input wire reset,
    input wire [67:0] axis_block_sigs,
    input wire [20:0] inst_idle_sigs,
    input wire [4:0] inst_block_sigs,
    output wire block
);

// signal declare
reg monitor_find_block;
wire idx7_block;
wire idx8_block;
wire idx9_block;
wire [2:0] process_idle_vec;
wire [2:0] process_chan_block_vec;
wire [2:0] process_axis_block_vec;
wire df_has_axis_block;
wire all_process_stop;

assign block = monitor_find_block;
assign process_axis_block_vec[0] = idx7_block & (1'b0 | axis_block_sigs[18] | axis_block_sigs[19] | axis_block_sigs[20] | axis_block_sigs[21] | axis_block_sigs[22] | axis_block_sigs[23] | axis_block_sigs[24] | axis_block_sigs[25]);
assign process_idle_vec[0] = inst_idle_sigs[2];
assign process_chan_block_vec[0] = inst_block_sigs[2];
assign process_axis_block_vec[1] = idx8_block & (1'b0 | axis_block_sigs[26] | axis_block_sigs[27] | axis_block_sigs[28] | axis_block_sigs[29] | axis_block_sigs[30] | axis_block_sigs[31] | axis_block_sigs[32] | axis_block_sigs[33] | axis_block_sigs[34] | axis_block_sigs[35] | axis_block_sigs[36] | axis_block_sigs[37] | axis_block_sigs[38] | axis_block_sigs[39] | axis_block_sigs[40] | axis_block_sigs[41]);
assign process_idle_vec[1] = inst_idle_sigs[3];
assign process_chan_block_vec[1] = inst_block_sigs[3];
assign process_axis_block_vec[2] = idx9_block & (1'b0 | axis_block_sigs[42] | axis_block_sigs[43] | axis_block_sigs[44] | axis_block_sigs[45] | axis_block_sigs[46] | axis_block_sigs[47] | axis_block_sigs[48] | axis_block_sigs[49]);
assign process_idle_vec[2] = inst_idle_sigs[4];
assign process_chan_block_vec[2] = inst_block_sigs[4];
assign df_has_axis_block = |{process_axis_block_vec};
assign all_process_stop = (process_idle_vec[0] | process_chan_block_vec[0] | process_axis_block_vec[0]) & (process_idle_vec[1] | process_chan_block_vec[1] | process_axis_block_vec[1]) & (process_idle_vec[2] | process_chan_block_vec[2] | process_axis_block_vec[2]);

always @(posedge clock) begin
    if (reset == 1'b1)
        monitor_find_block <= 1'b0;
    else if (df_has_axis_block == 1'b1 && all_process_stop == 1'b1)
        monitor_find_block <= 1'b1;
    else
        monitor_find_block <= 1'b0;
end


// instant sub module
 wiener_stream_hls_deadlock_idx7_monitor wiener_stream_hls_deadlock_idx7_monitor_U (
    .clock(clock),
    .reset(reset),
    .axis_block_sigs(axis_block_sigs),
    .inst_idle_sigs(inst_idle_sigs),
    .inst_block_sigs(inst_block_sigs),
    .block(idx7_block)
);

 wiener_stream_hls_deadlock_idx8_monitor wiener_stream_hls_deadlock_idx8_monitor_U (
    .clock(clock),
    .reset(reset),
    .axis_block_sigs(axis_block_sigs),
    .inst_idle_sigs(inst_idle_sigs),
    .inst_block_sigs(inst_block_sigs),
    .block(idx8_block)
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
