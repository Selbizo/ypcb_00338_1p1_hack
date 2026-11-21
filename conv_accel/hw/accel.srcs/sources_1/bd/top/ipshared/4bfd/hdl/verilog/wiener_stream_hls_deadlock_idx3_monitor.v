`timescale 1 ns / 1 ps

module wiener_stream_hls_deadlock_idx3_monitor ( // for module wiener_stream_wiener_stream_inst.grp_row_pass_fu_1499
    input wire clock,
    input wire reset,
    input wire [67:0] axis_block_sigs,
    input wire [20:0] inst_idle_sigs,
    input wire [4:0] inst_block_sigs,
    output wire block
);

// signal declare
reg monitor_find_block;
wire idx4_block;
wire idx5_block;
wire [1:0] process_idle_vec;
wire [1:0] process_chan_block_vec;
wire [1:0] process_axis_block_vec;
wire df_has_axis_block;
wire all_process_stop;

assign block = monitor_find_block;
assign process_axis_block_vec[0] = idx4_block & (1'b0 | axis_block_sigs[2] | axis_block_sigs[3] | axis_block_sigs[4] | axis_block_sigs[5] | axis_block_sigs[6] | axis_block_sigs[7] | axis_block_sigs[8] | axis_block_sigs[9]);
assign process_idle_vec[0] = inst_idle_sigs[0];
assign process_chan_block_vec[0] = inst_block_sigs[0];
assign process_axis_block_vec[1] = idx5_block & (1'b0 | axis_block_sigs[10] | axis_block_sigs[11] | axis_block_sigs[12] | axis_block_sigs[13] | axis_block_sigs[14] | axis_block_sigs[15] | axis_block_sigs[16] | axis_block_sigs[17]);
assign process_idle_vec[1] = inst_idle_sigs[1];
assign process_chan_block_vec[1] = inst_block_sigs[1];
assign df_has_axis_block = |{process_axis_block_vec};
assign all_process_stop = (process_idle_vec[0] | process_chan_block_vec[0] | process_axis_block_vec[0]) & (process_idle_vec[1] | process_chan_block_vec[1] | process_axis_block_vec[1]);

always @(posedge clock) begin
    if (reset == 1'b1)
        monitor_find_block <= 1'b0;
    else if (df_has_axis_block == 1'b1 && all_process_stop == 1'b1)
        monitor_find_block <= 1'b1;
    else
        monitor_find_block <= 1'b0;
end


// instant sub module
 wiener_stream_hls_deadlock_idx4_monitor wiener_stream_hls_deadlock_idx4_monitor_U (
    .clock(clock),
    .reset(reset),
    .axis_block_sigs(axis_block_sigs),
    .inst_idle_sigs(inst_idle_sigs),
    .inst_block_sigs(inst_block_sigs),
    .block(idx4_block)
);

 wiener_stream_hls_deadlock_idx5_monitor wiener_stream_hls_deadlock_idx5_monitor_U (
    .clock(clock),
    .reset(reset),
    .axis_block_sigs(axis_block_sigs),
    .inst_idle_sigs(inst_idle_sigs),
    .inst_block_sigs(inst_block_sigs),
    .block(idx5_block)
);

endmodule
