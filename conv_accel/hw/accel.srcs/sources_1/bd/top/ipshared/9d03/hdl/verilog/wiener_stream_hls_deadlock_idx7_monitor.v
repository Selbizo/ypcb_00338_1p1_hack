`timescale 1 ns / 1 ps

module wiener_stream_hls_deadlock_idx7_monitor ( // for module wiener_stream_wiener_stream_inst.grp_col_pass_fu_2235.recv_cols_g_U0
    input wire clock,
    input wire reset,
    input wire [67:0] axis_block_sigs,
    input wire [20:0] inst_idle_sigs,
    input wire [4:0] inst_block_sigs,
    output wire block
);

// signal declare
reg monitor_find_block;
wire sub_parallel_block;
wire all_sub_parallel_has_block;
wire all_sub_single_has_block;
wire cur_axis_has_block;
wire seq_is_axis_block;

assign block = monitor_find_block;
assign all_sub_parallel_has_block = 1'b0;
assign all_sub_single_has_block = 1'b0;
assign cur_axis_has_block = 1'b0 | axis_block_sigs[25] | axis_block_sigs[26] | axis_block_sigs[27] | axis_block_sigs[28] | axis_block_sigs[29] | axis_block_sigs[30] | axis_block_sigs[31] | axis_block_sigs[32] | axis_block_sigs[33] | axis_block_sigs[34] | axis_block_sigs[35] | axis_block_sigs[36] | axis_block_sigs[37] | axis_block_sigs[38] | axis_block_sigs[39] | axis_block_sigs[40];
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
endmodule
