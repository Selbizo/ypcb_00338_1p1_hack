`timescale 1 ns / 1 ps

module wiener_stream_hls_deadlock_idx8_monitor ( // for module wiener_stream_wiener_stream_inst.grp_col_pass_fu_2235.recv_cols_U0
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
assign cur_axis_has_block = 1'b0 | axis_block_sigs[41] | axis_block_sigs[42] | axis_block_sigs[43] | axis_block_sigs[44] | axis_block_sigs[45] | axis_block_sigs[46] | axis_block_sigs[47] | axis_block_sigs[48];
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
