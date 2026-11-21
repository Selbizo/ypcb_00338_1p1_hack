`timescale 1 ns / 1 ps

module wiener_stream_hls_deadlock_idx12_monitor ( // for module wiener_stream_wiener_stream_inst.grp_inv_rows_fu_2954.grp_inv_rows_Outline_VITIS_LOOP_163_1_fu_806
    input wire clock,
    input wire reset,
    input wire [67:0] axis_block_sigs,
    input wire [20:0] inst_idle_sigs,
    input wire [4:0] inst_block_sigs,
    output wire block
);

// signal declare
reg monitor_find_block;
wire idx13_block;
wire sub_parallel_block;
wire all_sub_parallel_has_block;
wire all_sub_single_has_block;
wire cur_axis_has_block;
wire seq_is_axis_block;

assign block = monitor_find_block;
assign all_sub_parallel_has_block = 1'b0;
assign all_sub_single_has_block = 1'b0 | (idx13_block & (axis_block_sigs[58] | axis_block_sigs[59] | axis_block_sigs[60] | axis_block_sigs[61] | axis_block_sigs[62] | axis_block_sigs[63] | axis_block_sigs[64] | axis_block_sigs[65]));
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
 wiener_stream_hls_deadlock_idx13_monitor wiener_stream_hls_deadlock_idx13_monitor_U (
    .clock(clock),
    .reset(reset),
    .axis_block_sigs(axis_block_sigs),
    .inst_idle_sigs(inst_idle_sigs),
    .inst_block_sigs(inst_block_sigs),
    .block(idx13_block)
);

endmodule
