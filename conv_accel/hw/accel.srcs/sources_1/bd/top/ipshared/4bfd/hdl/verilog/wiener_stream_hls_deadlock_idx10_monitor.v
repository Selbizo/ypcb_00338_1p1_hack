`timescale 1 ns / 1 ps

module wiener_stream_hls_deadlock_idx10_monitor ( // for module wiener_stream_wiener_stream_inst.grp_inv_rows_fu_2926
    input wire clock,
    input wire reset,
    input wire [67:0] axis_block_sigs,
    input wire [20:0] inst_idle_sigs,
    input wire [4:0] inst_block_sigs,
    output wire block
);

// signal declare
reg monitor_find_block;
wire idx11_block;
wire idx12_block;
wire sub_parallel_block;
wire all_sub_parallel_has_block;
wire all_sub_single_has_block;
wire cur_axis_has_block;
wire seq_is_axis_block;

assign block = monitor_find_block;
assign sub_parallel_block = 1'b0 | ((idx11_block & (axis_block_sigs[50] | axis_block_sigs[51] | axis_block_sigs[52] | axis_block_sigs[53] | axis_block_sigs[54] | axis_block_sigs[55] | axis_block_sigs[56] | axis_block_sigs[57])) & ((idx12_block | inst_idle_sigs[17]))) | ((idx12_block & (axis_block_sigs[58] | axis_block_sigs[59] | axis_block_sigs[60] | axis_block_sigs[61] | axis_block_sigs[62] | axis_block_sigs[63] | axis_block_sigs[64] | axis_block_sigs[65])) & ((idx11_block | inst_idle_sigs[16])));
assign all_sub_parallel_has_block = sub_parallel_block;
assign all_sub_single_has_block = 1'b0;
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
 wiener_stream_hls_deadlock_idx11_monitor wiener_stream_hls_deadlock_idx11_monitor_U (
    .clock(clock),
    .reset(reset),
    .axis_block_sigs(axis_block_sigs),
    .inst_idle_sigs(inst_idle_sigs),
    .inst_block_sigs(inst_block_sigs),
    .block(idx11_block)
);

 wiener_stream_hls_deadlock_idx12_monitor wiener_stream_hls_deadlock_idx12_monitor_U (
    .clock(clock),
    .reset(reset),
    .axis_block_sigs(axis_block_sigs),
    .inst_idle_sigs(inst_idle_sigs),
    .inst_block_sigs(inst_block_sigs),
    .block(idx12_block)
);

endmodule
