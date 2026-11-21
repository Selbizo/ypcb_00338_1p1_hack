
    wire dl_reset;
    wire dl_clock;
    assign dl_reset = ap_rst_n;
    assign dl_clock = ap_clk;
    wire [7:0] proc_0_data_FIFO_blk;
    wire [7:0] proc_0_data_PIPO_blk;
    wire [7:0] proc_0_start_FIFO_blk;
    wire [7:0] proc_0_TLF_FIFO_blk;
    wire [7:0] proc_0_input_sync_blk;
    wire [7:0] proc_0_output_sync_blk;
    wire [7:0] proc_dep_vld_vec_0;
    reg [7:0] proc_dep_vld_vec_0_reg;
    wire [7:0] in_chan_dep_vld_vec_0;
    wire [327:0] in_chan_dep_data_vec_0;
    wire [7:0] token_in_vec_0;
    wire [7:0] out_chan_dep_vld_vec_0;
    wire [40:0] out_chan_dep_data_0;
    wire [7:0] token_out_vec_0;
    wire dl_detect_out_0;
    wire dep_chan_vld_1_0;
    wire [40:0] dep_chan_data_1_0;
    wire token_1_0;
    wire dep_chan_vld_2_0;
    wire [40:0] dep_chan_data_2_0;
    wire token_2_0;
    wire dep_chan_vld_3_0;
    wire [40:0] dep_chan_data_3_0;
    wire token_3_0;
    wire dep_chan_vld_4_0;
    wire [40:0] dep_chan_data_4_0;
    wire token_4_0;
    wire dep_chan_vld_5_0;
    wire [40:0] dep_chan_data_5_0;
    wire token_5_0;
    wire dep_chan_vld_6_0;
    wire [40:0] dep_chan_data_6_0;
    wire token_6_0;
    wire dep_chan_vld_7_0;
    wire [40:0] dep_chan_data_7_0;
    wire token_7_0;
    wire dep_chan_vld_8_0;
    wire [40:0] dep_chan_data_8_0;
    wire token_8_0;
    wire [1:0] proc_1_data_FIFO_blk;
    wire [1:0] proc_1_data_PIPO_blk;
    wire [1:0] proc_1_start_FIFO_blk;
    wire [1:0] proc_1_TLF_FIFO_blk;
    wire [1:0] proc_1_input_sync_blk;
    wire [1:0] proc_1_output_sync_blk;
    wire [1:0] proc_dep_vld_vec_1;
    reg [1:0] proc_dep_vld_vec_1_reg;
    wire [1:0] in_chan_dep_vld_vec_1;
    wire [81:0] in_chan_dep_data_vec_1;
    wire [1:0] token_in_vec_1;
    wire [1:0] out_chan_dep_vld_vec_1;
    wire [40:0] out_chan_dep_data_1;
    wire [1:0] token_out_vec_1;
    wire dl_detect_out_1;
    wire dep_chan_vld_0_1;
    wire [40:0] dep_chan_data_0_1;
    wire token_0_1;
    wire dep_chan_vld_9_1;
    wire [40:0] dep_chan_data_9_1;
    wire token_9_1;
    wire [0:0] proc_2_data_FIFO_blk;
    wire [0:0] proc_2_data_PIPO_blk;
    wire [0:0] proc_2_start_FIFO_blk;
    wire [0:0] proc_2_TLF_FIFO_blk;
    wire [0:0] proc_2_input_sync_blk;
    wire [0:0] proc_2_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_2;
    reg [0:0] proc_dep_vld_vec_2_reg;
    wire [1:0] in_chan_dep_vld_vec_2;
    wire [81:0] in_chan_dep_data_vec_2;
    wire [1:0] token_in_vec_2;
    wire [0:0] out_chan_dep_vld_vec_2;
    wire [40:0] out_chan_dep_data_2;
    wire [0:0] token_out_vec_2;
    wire dl_detect_out_2;
    wire dep_chan_vld_0_2;
    wire [40:0] dep_chan_data_0_2;
    wire token_0_2;
    wire dep_chan_vld_9_2;
    wire [40:0] dep_chan_data_9_2;
    wire token_9_2;
    wire [0:0] proc_3_data_FIFO_blk;
    wire [0:0] proc_3_data_PIPO_blk;
    wire [0:0] proc_3_start_FIFO_blk;
    wire [0:0] proc_3_TLF_FIFO_blk;
    wire [0:0] proc_3_input_sync_blk;
    wire [0:0] proc_3_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_3;
    reg [0:0] proc_dep_vld_vec_3_reg;
    wire [1:0] in_chan_dep_vld_vec_3;
    wire [81:0] in_chan_dep_data_vec_3;
    wire [1:0] token_in_vec_3;
    wire [0:0] out_chan_dep_vld_vec_3;
    wire [40:0] out_chan_dep_data_3;
    wire [0:0] token_out_vec_3;
    wire dl_detect_out_3;
    wire dep_chan_vld_0_3;
    wire [40:0] dep_chan_data_0_3;
    wire token_0_3;
    wire dep_chan_vld_9_3;
    wire [40:0] dep_chan_data_9_3;
    wire token_9_3;
    wire [0:0] proc_4_data_FIFO_blk;
    wire [0:0] proc_4_data_PIPO_blk;
    wire [0:0] proc_4_start_FIFO_blk;
    wire [0:0] proc_4_TLF_FIFO_blk;
    wire [0:0] proc_4_input_sync_blk;
    wire [0:0] proc_4_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_4;
    reg [0:0] proc_dep_vld_vec_4_reg;
    wire [1:0] in_chan_dep_vld_vec_4;
    wire [81:0] in_chan_dep_data_vec_4;
    wire [1:0] token_in_vec_4;
    wire [0:0] out_chan_dep_vld_vec_4;
    wire [40:0] out_chan_dep_data_4;
    wire [0:0] token_out_vec_4;
    wire dl_detect_out_4;
    wire dep_chan_vld_0_4;
    wire [40:0] dep_chan_data_0_4;
    wire token_0_4;
    wire dep_chan_vld_9_4;
    wire [40:0] dep_chan_data_9_4;
    wire token_9_4;
    wire [0:0] proc_5_data_FIFO_blk;
    wire [0:0] proc_5_data_PIPO_blk;
    wire [0:0] proc_5_start_FIFO_blk;
    wire [0:0] proc_5_TLF_FIFO_blk;
    wire [0:0] proc_5_input_sync_blk;
    wire [0:0] proc_5_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_5;
    reg [0:0] proc_dep_vld_vec_5_reg;
    wire [1:0] in_chan_dep_vld_vec_5;
    wire [81:0] in_chan_dep_data_vec_5;
    wire [1:0] token_in_vec_5;
    wire [0:0] out_chan_dep_vld_vec_5;
    wire [40:0] out_chan_dep_data_5;
    wire [0:0] token_out_vec_5;
    wire dl_detect_out_5;
    wire dep_chan_vld_0_5;
    wire [40:0] dep_chan_data_0_5;
    wire token_0_5;
    wire dep_chan_vld_9_5;
    wire [40:0] dep_chan_data_9_5;
    wire token_9_5;
    wire [0:0] proc_6_data_FIFO_blk;
    wire [0:0] proc_6_data_PIPO_blk;
    wire [0:0] proc_6_start_FIFO_blk;
    wire [0:0] proc_6_TLF_FIFO_blk;
    wire [0:0] proc_6_input_sync_blk;
    wire [0:0] proc_6_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_6;
    reg [0:0] proc_dep_vld_vec_6_reg;
    wire [1:0] in_chan_dep_vld_vec_6;
    wire [81:0] in_chan_dep_data_vec_6;
    wire [1:0] token_in_vec_6;
    wire [0:0] out_chan_dep_vld_vec_6;
    wire [40:0] out_chan_dep_data_6;
    wire [0:0] token_out_vec_6;
    wire dl_detect_out_6;
    wire dep_chan_vld_0_6;
    wire [40:0] dep_chan_data_0_6;
    wire token_0_6;
    wire dep_chan_vld_9_6;
    wire [40:0] dep_chan_data_9_6;
    wire token_9_6;
    wire [0:0] proc_7_data_FIFO_blk;
    wire [0:0] proc_7_data_PIPO_blk;
    wire [0:0] proc_7_start_FIFO_blk;
    wire [0:0] proc_7_TLF_FIFO_blk;
    wire [0:0] proc_7_input_sync_blk;
    wire [0:0] proc_7_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_7;
    reg [0:0] proc_dep_vld_vec_7_reg;
    wire [1:0] in_chan_dep_vld_vec_7;
    wire [81:0] in_chan_dep_data_vec_7;
    wire [1:0] token_in_vec_7;
    wire [0:0] out_chan_dep_vld_vec_7;
    wire [40:0] out_chan_dep_data_7;
    wire [0:0] token_out_vec_7;
    wire dl_detect_out_7;
    wire dep_chan_vld_0_7;
    wire [40:0] dep_chan_data_0_7;
    wire token_0_7;
    wire dep_chan_vld_9_7;
    wire [40:0] dep_chan_data_9_7;
    wire token_9_7;
    wire [0:0] proc_8_data_FIFO_blk;
    wire [0:0] proc_8_data_PIPO_blk;
    wire [0:0] proc_8_start_FIFO_blk;
    wire [0:0] proc_8_TLF_FIFO_blk;
    wire [0:0] proc_8_input_sync_blk;
    wire [0:0] proc_8_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_8;
    reg [0:0] proc_dep_vld_vec_8_reg;
    wire [1:0] in_chan_dep_vld_vec_8;
    wire [81:0] in_chan_dep_data_vec_8;
    wire [1:0] token_in_vec_8;
    wire [0:0] out_chan_dep_vld_vec_8;
    wire [40:0] out_chan_dep_data_8;
    wire [0:0] token_out_vec_8;
    wire dl_detect_out_8;
    wire dep_chan_vld_0_8;
    wire [40:0] dep_chan_data_0_8;
    wire token_0_8;
    wire dep_chan_vld_9_8;
    wire [40:0] dep_chan_data_9_8;
    wire token_9_8;
    wire [7:0] proc_9_data_FIFO_blk;
    wire [7:0] proc_9_data_PIPO_blk;
    wire [7:0] proc_9_start_FIFO_blk;
    wire [7:0] proc_9_TLF_FIFO_blk;
    wire [7:0] proc_9_input_sync_blk;
    wire [7:0] proc_9_output_sync_blk;
    wire [7:0] proc_dep_vld_vec_9;
    reg [7:0] proc_dep_vld_vec_9_reg;
    wire [0:0] in_chan_dep_vld_vec_9;
    wire [40:0] in_chan_dep_data_vec_9;
    wire [0:0] token_in_vec_9;
    wire [7:0] out_chan_dep_vld_vec_9;
    wire [40:0] out_chan_dep_data_9;
    wire [7:0] token_out_vec_9;
    wire dl_detect_out_9;
    wire dep_chan_vld_1_9;
    wire [40:0] dep_chan_data_1_9;
    wire token_1_9;
    wire [1:0] proc_10_data_FIFO_blk;
    wire [1:0] proc_10_data_PIPO_blk;
    wire [1:0] proc_10_start_FIFO_blk;
    wire [1:0] proc_10_TLF_FIFO_blk;
    wire [1:0] proc_10_input_sync_blk;
    wire [1:0] proc_10_output_sync_blk;
    wire [1:0] proc_dep_vld_vec_10;
    reg [1:0] proc_dep_vld_vec_10_reg;
    wire [1:0] in_chan_dep_vld_vec_10;
    wire [81:0] in_chan_dep_data_vec_10;
    wire [1:0] token_in_vec_10;
    wire [1:0] out_chan_dep_vld_vec_10;
    wire [40:0] out_chan_dep_data_10;
    wire [1:0] token_out_vec_10;
    wire dl_detect_out_10;
    wire dep_chan_vld_11_10;
    wire [40:0] dep_chan_data_11_10;
    wire token_11_10;
    wire dep_chan_vld_20_10;
    wire [40:0] dep_chan_data_20_10;
    wire token_20_10;
    wire [8:0] proc_11_data_FIFO_blk;
    wire [8:0] proc_11_data_PIPO_blk;
    wire [8:0] proc_11_start_FIFO_blk;
    wire [8:0] proc_11_TLF_FIFO_blk;
    wire [8:0] proc_11_input_sync_blk;
    wire [8:0] proc_11_output_sync_blk;
    wire [8:0] proc_dep_vld_vec_11;
    reg [8:0] proc_dep_vld_vec_11_reg;
    wire [8:0] in_chan_dep_vld_vec_11;
    wire [368:0] in_chan_dep_data_vec_11;
    wire [8:0] token_in_vec_11;
    wire [8:0] out_chan_dep_vld_vec_11;
    wire [40:0] out_chan_dep_data_11;
    wire [8:0] token_out_vec_11;
    wire dl_detect_out_11;
    wire dep_chan_vld_10_11;
    wire [40:0] dep_chan_data_10_11;
    wire token_10_11;
    wire dep_chan_vld_12_11;
    wire [40:0] dep_chan_data_12_11;
    wire token_12_11;
    wire dep_chan_vld_13_11;
    wire [40:0] dep_chan_data_13_11;
    wire token_13_11;
    wire dep_chan_vld_14_11;
    wire [40:0] dep_chan_data_14_11;
    wire token_14_11;
    wire dep_chan_vld_15_11;
    wire [40:0] dep_chan_data_15_11;
    wire token_15_11;
    wire dep_chan_vld_16_11;
    wire [40:0] dep_chan_data_16_11;
    wire token_16_11;
    wire dep_chan_vld_17_11;
    wire [40:0] dep_chan_data_17_11;
    wire token_17_11;
    wire dep_chan_vld_18_11;
    wire [40:0] dep_chan_data_18_11;
    wire token_18_11;
    wire dep_chan_vld_19_11;
    wire [40:0] dep_chan_data_19_11;
    wire token_19_11;
    wire [0:0] proc_12_data_FIFO_blk;
    wire [0:0] proc_12_data_PIPO_blk;
    wire [0:0] proc_12_start_FIFO_blk;
    wire [0:0] proc_12_TLF_FIFO_blk;
    wire [0:0] proc_12_input_sync_blk;
    wire [0:0] proc_12_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_12;
    reg [0:0] proc_dep_vld_vec_12_reg;
    wire [1:0] in_chan_dep_vld_vec_12;
    wire [81:0] in_chan_dep_data_vec_12;
    wire [1:0] token_in_vec_12;
    wire [0:0] out_chan_dep_vld_vec_12;
    wire [40:0] out_chan_dep_data_12;
    wire [0:0] token_out_vec_12;
    wire dl_detect_out_12;
    wire dep_chan_vld_11_12;
    wire [40:0] dep_chan_data_11_12;
    wire token_11_12;
    wire dep_chan_vld_20_12;
    wire [40:0] dep_chan_data_20_12;
    wire token_20_12;
    wire [0:0] proc_13_data_FIFO_blk;
    wire [0:0] proc_13_data_PIPO_blk;
    wire [0:0] proc_13_start_FIFO_blk;
    wire [0:0] proc_13_TLF_FIFO_blk;
    wire [0:0] proc_13_input_sync_blk;
    wire [0:0] proc_13_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_13;
    reg [0:0] proc_dep_vld_vec_13_reg;
    wire [1:0] in_chan_dep_vld_vec_13;
    wire [81:0] in_chan_dep_data_vec_13;
    wire [1:0] token_in_vec_13;
    wire [0:0] out_chan_dep_vld_vec_13;
    wire [40:0] out_chan_dep_data_13;
    wire [0:0] token_out_vec_13;
    wire dl_detect_out_13;
    wire dep_chan_vld_11_13;
    wire [40:0] dep_chan_data_11_13;
    wire token_11_13;
    wire dep_chan_vld_20_13;
    wire [40:0] dep_chan_data_20_13;
    wire token_20_13;
    wire [0:0] proc_14_data_FIFO_blk;
    wire [0:0] proc_14_data_PIPO_blk;
    wire [0:0] proc_14_start_FIFO_blk;
    wire [0:0] proc_14_TLF_FIFO_blk;
    wire [0:0] proc_14_input_sync_blk;
    wire [0:0] proc_14_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_14;
    reg [0:0] proc_dep_vld_vec_14_reg;
    wire [1:0] in_chan_dep_vld_vec_14;
    wire [81:0] in_chan_dep_data_vec_14;
    wire [1:0] token_in_vec_14;
    wire [0:0] out_chan_dep_vld_vec_14;
    wire [40:0] out_chan_dep_data_14;
    wire [0:0] token_out_vec_14;
    wire dl_detect_out_14;
    wire dep_chan_vld_11_14;
    wire [40:0] dep_chan_data_11_14;
    wire token_11_14;
    wire dep_chan_vld_20_14;
    wire [40:0] dep_chan_data_20_14;
    wire token_20_14;
    wire [0:0] proc_15_data_FIFO_blk;
    wire [0:0] proc_15_data_PIPO_blk;
    wire [0:0] proc_15_start_FIFO_blk;
    wire [0:0] proc_15_TLF_FIFO_blk;
    wire [0:0] proc_15_input_sync_blk;
    wire [0:0] proc_15_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_15;
    reg [0:0] proc_dep_vld_vec_15_reg;
    wire [1:0] in_chan_dep_vld_vec_15;
    wire [81:0] in_chan_dep_data_vec_15;
    wire [1:0] token_in_vec_15;
    wire [0:0] out_chan_dep_vld_vec_15;
    wire [40:0] out_chan_dep_data_15;
    wire [0:0] token_out_vec_15;
    wire dl_detect_out_15;
    wire dep_chan_vld_11_15;
    wire [40:0] dep_chan_data_11_15;
    wire token_11_15;
    wire dep_chan_vld_20_15;
    wire [40:0] dep_chan_data_20_15;
    wire token_20_15;
    wire [0:0] proc_16_data_FIFO_blk;
    wire [0:0] proc_16_data_PIPO_blk;
    wire [0:0] proc_16_start_FIFO_blk;
    wire [0:0] proc_16_TLF_FIFO_blk;
    wire [0:0] proc_16_input_sync_blk;
    wire [0:0] proc_16_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_16;
    reg [0:0] proc_dep_vld_vec_16_reg;
    wire [1:0] in_chan_dep_vld_vec_16;
    wire [81:0] in_chan_dep_data_vec_16;
    wire [1:0] token_in_vec_16;
    wire [0:0] out_chan_dep_vld_vec_16;
    wire [40:0] out_chan_dep_data_16;
    wire [0:0] token_out_vec_16;
    wire dl_detect_out_16;
    wire dep_chan_vld_11_16;
    wire [40:0] dep_chan_data_11_16;
    wire token_11_16;
    wire dep_chan_vld_20_16;
    wire [40:0] dep_chan_data_20_16;
    wire token_20_16;
    wire [0:0] proc_17_data_FIFO_blk;
    wire [0:0] proc_17_data_PIPO_blk;
    wire [0:0] proc_17_start_FIFO_blk;
    wire [0:0] proc_17_TLF_FIFO_blk;
    wire [0:0] proc_17_input_sync_blk;
    wire [0:0] proc_17_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_17;
    reg [0:0] proc_dep_vld_vec_17_reg;
    wire [1:0] in_chan_dep_vld_vec_17;
    wire [81:0] in_chan_dep_data_vec_17;
    wire [1:0] token_in_vec_17;
    wire [0:0] out_chan_dep_vld_vec_17;
    wire [40:0] out_chan_dep_data_17;
    wire [0:0] token_out_vec_17;
    wire dl_detect_out_17;
    wire dep_chan_vld_11_17;
    wire [40:0] dep_chan_data_11_17;
    wire token_11_17;
    wire dep_chan_vld_20_17;
    wire [40:0] dep_chan_data_20_17;
    wire token_20_17;
    wire [0:0] proc_18_data_FIFO_blk;
    wire [0:0] proc_18_data_PIPO_blk;
    wire [0:0] proc_18_start_FIFO_blk;
    wire [0:0] proc_18_TLF_FIFO_blk;
    wire [0:0] proc_18_input_sync_blk;
    wire [0:0] proc_18_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_18;
    reg [0:0] proc_dep_vld_vec_18_reg;
    wire [1:0] in_chan_dep_vld_vec_18;
    wire [81:0] in_chan_dep_data_vec_18;
    wire [1:0] token_in_vec_18;
    wire [0:0] out_chan_dep_vld_vec_18;
    wire [40:0] out_chan_dep_data_18;
    wire [0:0] token_out_vec_18;
    wire dl_detect_out_18;
    wire dep_chan_vld_11_18;
    wire [40:0] dep_chan_data_11_18;
    wire token_11_18;
    wire dep_chan_vld_20_18;
    wire [40:0] dep_chan_data_20_18;
    wire token_20_18;
    wire [0:0] proc_19_data_FIFO_blk;
    wire [0:0] proc_19_data_PIPO_blk;
    wire [0:0] proc_19_start_FIFO_blk;
    wire [0:0] proc_19_TLF_FIFO_blk;
    wire [0:0] proc_19_input_sync_blk;
    wire [0:0] proc_19_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_19;
    reg [0:0] proc_dep_vld_vec_19_reg;
    wire [1:0] in_chan_dep_vld_vec_19;
    wire [81:0] in_chan_dep_data_vec_19;
    wire [1:0] token_in_vec_19;
    wire [0:0] out_chan_dep_vld_vec_19;
    wire [40:0] out_chan_dep_data_19;
    wire [0:0] token_out_vec_19;
    wire dl_detect_out_19;
    wire dep_chan_vld_11_19;
    wire [40:0] dep_chan_data_11_19;
    wire token_11_19;
    wire dep_chan_vld_20_19;
    wire [40:0] dep_chan_data_20_19;
    wire token_20_19;
    wire [16:0] proc_20_data_FIFO_blk;
    wire [16:0] proc_20_data_PIPO_blk;
    wire [16:0] proc_20_start_FIFO_blk;
    wire [16:0] proc_20_TLF_FIFO_blk;
    wire [16:0] proc_20_input_sync_blk;
    wire [16:0] proc_20_output_sync_blk;
    wire [16:0] proc_dep_vld_vec_20;
    reg [16:0] proc_dep_vld_vec_20_reg;
    wire [8:0] in_chan_dep_vld_vec_20;
    wire [368:0] in_chan_dep_data_vec_20;
    wire [8:0] token_in_vec_20;
    wire [16:0] out_chan_dep_vld_vec_20;
    wire [40:0] out_chan_dep_data_20;
    wire [16:0] token_out_vec_20;
    wire dl_detect_out_20;
    wire dep_chan_vld_10_20;
    wire [40:0] dep_chan_data_10_20;
    wire token_10_20;
    wire dep_chan_vld_21_20;
    wire [40:0] dep_chan_data_21_20;
    wire token_21_20;
    wire dep_chan_vld_22_20;
    wire [40:0] dep_chan_data_22_20;
    wire token_22_20;
    wire dep_chan_vld_23_20;
    wire [40:0] dep_chan_data_23_20;
    wire token_23_20;
    wire dep_chan_vld_24_20;
    wire [40:0] dep_chan_data_24_20;
    wire token_24_20;
    wire dep_chan_vld_25_20;
    wire [40:0] dep_chan_data_25_20;
    wire token_25_20;
    wire dep_chan_vld_26_20;
    wire [40:0] dep_chan_data_26_20;
    wire token_26_20;
    wire dep_chan_vld_27_20;
    wire [40:0] dep_chan_data_27_20;
    wire token_27_20;
    wire dep_chan_vld_28_20;
    wire [40:0] dep_chan_data_28_20;
    wire token_28_20;
    wire [1:0] proc_21_data_FIFO_blk;
    wire [1:0] proc_21_data_PIPO_blk;
    wire [1:0] proc_21_start_FIFO_blk;
    wire [1:0] proc_21_TLF_FIFO_blk;
    wire [1:0] proc_21_input_sync_blk;
    wire [1:0] proc_21_output_sync_blk;
    wire [1:0] proc_dep_vld_vec_21;
    reg [1:0] proc_dep_vld_vec_21_reg;
    wire [1:0] in_chan_dep_vld_vec_21;
    wire [81:0] in_chan_dep_data_vec_21;
    wire [1:0] token_in_vec_21;
    wire [1:0] out_chan_dep_vld_vec_21;
    wire [40:0] out_chan_dep_data_21;
    wire [1:0] token_out_vec_21;
    wire dl_detect_out_21;
    wire dep_chan_vld_20_21;
    wire [40:0] dep_chan_data_20_21;
    wire token_20_21;
    wire dep_chan_vld_29_21;
    wire [40:0] dep_chan_data_29_21;
    wire token_29_21;
    wire [0:0] proc_22_data_FIFO_blk;
    wire [0:0] proc_22_data_PIPO_blk;
    wire [0:0] proc_22_start_FIFO_blk;
    wire [0:0] proc_22_TLF_FIFO_blk;
    wire [0:0] proc_22_input_sync_blk;
    wire [0:0] proc_22_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_22;
    reg [0:0] proc_dep_vld_vec_22_reg;
    wire [1:0] in_chan_dep_vld_vec_22;
    wire [81:0] in_chan_dep_data_vec_22;
    wire [1:0] token_in_vec_22;
    wire [0:0] out_chan_dep_vld_vec_22;
    wire [40:0] out_chan_dep_data_22;
    wire [0:0] token_out_vec_22;
    wire dl_detect_out_22;
    wire dep_chan_vld_20_22;
    wire [40:0] dep_chan_data_20_22;
    wire token_20_22;
    wire dep_chan_vld_29_22;
    wire [40:0] dep_chan_data_29_22;
    wire token_29_22;
    wire [0:0] proc_23_data_FIFO_blk;
    wire [0:0] proc_23_data_PIPO_blk;
    wire [0:0] proc_23_start_FIFO_blk;
    wire [0:0] proc_23_TLF_FIFO_blk;
    wire [0:0] proc_23_input_sync_blk;
    wire [0:0] proc_23_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_23;
    reg [0:0] proc_dep_vld_vec_23_reg;
    wire [1:0] in_chan_dep_vld_vec_23;
    wire [81:0] in_chan_dep_data_vec_23;
    wire [1:0] token_in_vec_23;
    wire [0:0] out_chan_dep_vld_vec_23;
    wire [40:0] out_chan_dep_data_23;
    wire [0:0] token_out_vec_23;
    wire dl_detect_out_23;
    wire dep_chan_vld_20_23;
    wire [40:0] dep_chan_data_20_23;
    wire token_20_23;
    wire dep_chan_vld_29_23;
    wire [40:0] dep_chan_data_29_23;
    wire token_29_23;
    wire [0:0] proc_24_data_FIFO_blk;
    wire [0:0] proc_24_data_PIPO_blk;
    wire [0:0] proc_24_start_FIFO_blk;
    wire [0:0] proc_24_TLF_FIFO_blk;
    wire [0:0] proc_24_input_sync_blk;
    wire [0:0] proc_24_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_24;
    reg [0:0] proc_dep_vld_vec_24_reg;
    wire [1:0] in_chan_dep_vld_vec_24;
    wire [81:0] in_chan_dep_data_vec_24;
    wire [1:0] token_in_vec_24;
    wire [0:0] out_chan_dep_vld_vec_24;
    wire [40:0] out_chan_dep_data_24;
    wire [0:0] token_out_vec_24;
    wire dl_detect_out_24;
    wire dep_chan_vld_20_24;
    wire [40:0] dep_chan_data_20_24;
    wire token_20_24;
    wire dep_chan_vld_29_24;
    wire [40:0] dep_chan_data_29_24;
    wire token_29_24;
    wire [0:0] proc_25_data_FIFO_blk;
    wire [0:0] proc_25_data_PIPO_blk;
    wire [0:0] proc_25_start_FIFO_blk;
    wire [0:0] proc_25_TLF_FIFO_blk;
    wire [0:0] proc_25_input_sync_blk;
    wire [0:0] proc_25_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_25;
    reg [0:0] proc_dep_vld_vec_25_reg;
    wire [1:0] in_chan_dep_vld_vec_25;
    wire [81:0] in_chan_dep_data_vec_25;
    wire [1:0] token_in_vec_25;
    wire [0:0] out_chan_dep_vld_vec_25;
    wire [40:0] out_chan_dep_data_25;
    wire [0:0] token_out_vec_25;
    wire dl_detect_out_25;
    wire dep_chan_vld_20_25;
    wire [40:0] dep_chan_data_20_25;
    wire token_20_25;
    wire dep_chan_vld_29_25;
    wire [40:0] dep_chan_data_29_25;
    wire token_29_25;
    wire [0:0] proc_26_data_FIFO_blk;
    wire [0:0] proc_26_data_PIPO_blk;
    wire [0:0] proc_26_start_FIFO_blk;
    wire [0:0] proc_26_TLF_FIFO_blk;
    wire [0:0] proc_26_input_sync_blk;
    wire [0:0] proc_26_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_26;
    reg [0:0] proc_dep_vld_vec_26_reg;
    wire [1:0] in_chan_dep_vld_vec_26;
    wire [81:0] in_chan_dep_data_vec_26;
    wire [1:0] token_in_vec_26;
    wire [0:0] out_chan_dep_vld_vec_26;
    wire [40:0] out_chan_dep_data_26;
    wire [0:0] token_out_vec_26;
    wire dl_detect_out_26;
    wire dep_chan_vld_20_26;
    wire [40:0] dep_chan_data_20_26;
    wire token_20_26;
    wire dep_chan_vld_29_26;
    wire [40:0] dep_chan_data_29_26;
    wire token_29_26;
    wire [0:0] proc_27_data_FIFO_blk;
    wire [0:0] proc_27_data_PIPO_blk;
    wire [0:0] proc_27_start_FIFO_blk;
    wire [0:0] proc_27_TLF_FIFO_blk;
    wire [0:0] proc_27_input_sync_blk;
    wire [0:0] proc_27_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_27;
    reg [0:0] proc_dep_vld_vec_27_reg;
    wire [1:0] in_chan_dep_vld_vec_27;
    wire [81:0] in_chan_dep_data_vec_27;
    wire [1:0] token_in_vec_27;
    wire [0:0] out_chan_dep_vld_vec_27;
    wire [40:0] out_chan_dep_data_27;
    wire [0:0] token_out_vec_27;
    wire dl_detect_out_27;
    wire dep_chan_vld_20_27;
    wire [40:0] dep_chan_data_20_27;
    wire token_20_27;
    wire dep_chan_vld_29_27;
    wire [40:0] dep_chan_data_29_27;
    wire token_29_27;
    wire [0:0] proc_28_data_FIFO_blk;
    wire [0:0] proc_28_data_PIPO_blk;
    wire [0:0] proc_28_start_FIFO_blk;
    wire [0:0] proc_28_TLF_FIFO_blk;
    wire [0:0] proc_28_input_sync_blk;
    wire [0:0] proc_28_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_28;
    reg [0:0] proc_dep_vld_vec_28_reg;
    wire [1:0] in_chan_dep_vld_vec_28;
    wire [81:0] in_chan_dep_data_vec_28;
    wire [1:0] token_in_vec_28;
    wire [0:0] out_chan_dep_vld_vec_28;
    wire [40:0] out_chan_dep_data_28;
    wire [0:0] token_out_vec_28;
    wire dl_detect_out_28;
    wire dep_chan_vld_20_28;
    wire [40:0] dep_chan_data_20_28;
    wire token_20_28;
    wire dep_chan_vld_29_28;
    wire [40:0] dep_chan_data_29_28;
    wire token_29_28;
    wire [7:0] proc_29_data_FIFO_blk;
    wire [7:0] proc_29_data_PIPO_blk;
    wire [7:0] proc_29_start_FIFO_blk;
    wire [7:0] proc_29_TLF_FIFO_blk;
    wire [7:0] proc_29_input_sync_blk;
    wire [7:0] proc_29_output_sync_blk;
    wire [7:0] proc_dep_vld_vec_29;
    reg [7:0] proc_dep_vld_vec_29_reg;
    wire [0:0] in_chan_dep_vld_vec_29;
    wire [40:0] in_chan_dep_data_vec_29;
    wire [0:0] token_in_vec_29;
    wire [7:0] out_chan_dep_vld_vec_29;
    wire [40:0] out_chan_dep_data_29;
    wire [7:0] token_out_vec_29;
    wire dl_detect_out_29;
    wire dep_chan_vld_21_29;
    wire [40:0] dep_chan_data_21_29;
    wire token_21_29;
    wire [1:0] proc_30_data_FIFO_blk;
    wire [1:0] proc_30_data_PIPO_blk;
    wire [1:0] proc_30_start_FIFO_blk;
    wire [1:0] proc_30_TLF_FIFO_blk;
    wire [1:0] proc_30_input_sync_blk;
    wire [1:0] proc_30_output_sync_blk;
    wire [1:0] proc_dep_vld_vec_30;
    reg [1:0] proc_dep_vld_vec_30_reg;
    wire [1:0] in_chan_dep_vld_vec_30;
    wire [81:0] in_chan_dep_data_vec_30;
    wire [1:0] token_in_vec_30;
    wire [1:0] out_chan_dep_vld_vec_30;
    wire [40:0] out_chan_dep_data_30;
    wire [1:0] token_out_vec_30;
    wire dl_detect_out_30;
    wire dep_chan_vld_31_30;
    wire [40:0] dep_chan_data_31_30;
    wire token_31_30;
    wire dep_chan_vld_40_30;
    wire [40:0] dep_chan_data_40_30;
    wire token_40_30;
    wire [8:0] proc_31_data_FIFO_blk;
    wire [8:0] proc_31_data_PIPO_blk;
    wire [8:0] proc_31_start_FIFO_blk;
    wire [8:0] proc_31_TLF_FIFO_blk;
    wire [8:0] proc_31_input_sync_blk;
    wire [8:0] proc_31_output_sync_blk;
    wire [8:0] proc_dep_vld_vec_31;
    reg [8:0] proc_dep_vld_vec_31_reg;
    wire [8:0] in_chan_dep_vld_vec_31;
    wire [368:0] in_chan_dep_data_vec_31;
    wire [8:0] token_in_vec_31;
    wire [8:0] out_chan_dep_vld_vec_31;
    wire [40:0] out_chan_dep_data_31;
    wire [8:0] token_out_vec_31;
    wire dl_detect_out_31;
    wire dep_chan_vld_30_31;
    wire [40:0] dep_chan_data_30_31;
    wire token_30_31;
    wire dep_chan_vld_32_31;
    wire [40:0] dep_chan_data_32_31;
    wire token_32_31;
    wire dep_chan_vld_33_31;
    wire [40:0] dep_chan_data_33_31;
    wire token_33_31;
    wire dep_chan_vld_34_31;
    wire [40:0] dep_chan_data_34_31;
    wire token_34_31;
    wire dep_chan_vld_35_31;
    wire [40:0] dep_chan_data_35_31;
    wire token_35_31;
    wire dep_chan_vld_36_31;
    wire [40:0] dep_chan_data_36_31;
    wire token_36_31;
    wire dep_chan_vld_37_31;
    wire [40:0] dep_chan_data_37_31;
    wire token_37_31;
    wire dep_chan_vld_38_31;
    wire [40:0] dep_chan_data_38_31;
    wire token_38_31;
    wire dep_chan_vld_39_31;
    wire [40:0] dep_chan_data_39_31;
    wire token_39_31;
    wire [0:0] proc_32_data_FIFO_blk;
    wire [0:0] proc_32_data_PIPO_blk;
    wire [0:0] proc_32_start_FIFO_blk;
    wire [0:0] proc_32_TLF_FIFO_blk;
    wire [0:0] proc_32_input_sync_blk;
    wire [0:0] proc_32_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_32;
    reg [0:0] proc_dep_vld_vec_32_reg;
    wire [1:0] in_chan_dep_vld_vec_32;
    wire [81:0] in_chan_dep_data_vec_32;
    wire [1:0] token_in_vec_32;
    wire [0:0] out_chan_dep_vld_vec_32;
    wire [40:0] out_chan_dep_data_32;
    wire [0:0] token_out_vec_32;
    wire dl_detect_out_32;
    wire dep_chan_vld_31_32;
    wire [40:0] dep_chan_data_31_32;
    wire token_31_32;
    wire dep_chan_vld_40_32;
    wire [40:0] dep_chan_data_40_32;
    wire token_40_32;
    wire [0:0] proc_33_data_FIFO_blk;
    wire [0:0] proc_33_data_PIPO_blk;
    wire [0:0] proc_33_start_FIFO_blk;
    wire [0:0] proc_33_TLF_FIFO_blk;
    wire [0:0] proc_33_input_sync_blk;
    wire [0:0] proc_33_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_33;
    reg [0:0] proc_dep_vld_vec_33_reg;
    wire [1:0] in_chan_dep_vld_vec_33;
    wire [81:0] in_chan_dep_data_vec_33;
    wire [1:0] token_in_vec_33;
    wire [0:0] out_chan_dep_vld_vec_33;
    wire [40:0] out_chan_dep_data_33;
    wire [0:0] token_out_vec_33;
    wire dl_detect_out_33;
    wire dep_chan_vld_31_33;
    wire [40:0] dep_chan_data_31_33;
    wire token_31_33;
    wire dep_chan_vld_40_33;
    wire [40:0] dep_chan_data_40_33;
    wire token_40_33;
    wire [0:0] proc_34_data_FIFO_blk;
    wire [0:0] proc_34_data_PIPO_blk;
    wire [0:0] proc_34_start_FIFO_blk;
    wire [0:0] proc_34_TLF_FIFO_blk;
    wire [0:0] proc_34_input_sync_blk;
    wire [0:0] proc_34_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_34;
    reg [0:0] proc_dep_vld_vec_34_reg;
    wire [1:0] in_chan_dep_vld_vec_34;
    wire [81:0] in_chan_dep_data_vec_34;
    wire [1:0] token_in_vec_34;
    wire [0:0] out_chan_dep_vld_vec_34;
    wire [40:0] out_chan_dep_data_34;
    wire [0:0] token_out_vec_34;
    wire dl_detect_out_34;
    wire dep_chan_vld_31_34;
    wire [40:0] dep_chan_data_31_34;
    wire token_31_34;
    wire dep_chan_vld_40_34;
    wire [40:0] dep_chan_data_40_34;
    wire token_40_34;
    wire [0:0] proc_35_data_FIFO_blk;
    wire [0:0] proc_35_data_PIPO_blk;
    wire [0:0] proc_35_start_FIFO_blk;
    wire [0:0] proc_35_TLF_FIFO_blk;
    wire [0:0] proc_35_input_sync_blk;
    wire [0:0] proc_35_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_35;
    reg [0:0] proc_dep_vld_vec_35_reg;
    wire [1:0] in_chan_dep_vld_vec_35;
    wire [81:0] in_chan_dep_data_vec_35;
    wire [1:0] token_in_vec_35;
    wire [0:0] out_chan_dep_vld_vec_35;
    wire [40:0] out_chan_dep_data_35;
    wire [0:0] token_out_vec_35;
    wire dl_detect_out_35;
    wire dep_chan_vld_31_35;
    wire [40:0] dep_chan_data_31_35;
    wire token_31_35;
    wire dep_chan_vld_40_35;
    wire [40:0] dep_chan_data_40_35;
    wire token_40_35;
    wire [0:0] proc_36_data_FIFO_blk;
    wire [0:0] proc_36_data_PIPO_blk;
    wire [0:0] proc_36_start_FIFO_blk;
    wire [0:0] proc_36_TLF_FIFO_blk;
    wire [0:0] proc_36_input_sync_blk;
    wire [0:0] proc_36_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_36;
    reg [0:0] proc_dep_vld_vec_36_reg;
    wire [1:0] in_chan_dep_vld_vec_36;
    wire [81:0] in_chan_dep_data_vec_36;
    wire [1:0] token_in_vec_36;
    wire [0:0] out_chan_dep_vld_vec_36;
    wire [40:0] out_chan_dep_data_36;
    wire [0:0] token_out_vec_36;
    wire dl_detect_out_36;
    wire dep_chan_vld_31_36;
    wire [40:0] dep_chan_data_31_36;
    wire token_31_36;
    wire dep_chan_vld_40_36;
    wire [40:0] dep_chan_data_40_36;
    wire token_40_36;
    wire [0:0] proc_37_data_FIFO_blk;
    wire [0:0] proc_37_data_PIPO_blk;
    wire [0:0] proc_37_start_FIFO_blk;
    wire [0:0] proc_37_TLF_FIFO_blk;
    wire [0:0] proc_37_input_sync_blk;
    wire [0:0] proc_37_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_37;
    reg [0:0] proc_dep_vld_vec_37_reg;
    wire [1:0] in_chan_dep_vld_vec_37;
    wire [81:0] in_chan_dep_data_vec_37;
    wire [1:0] token_in_vec_37;
    wire [0:0] out_chan_dep_vld_vec_37;
    wire [40:0] out_chan_dep_data_37;
    wire [0:0] token_out_vec_37;
    wire dl_detect_out_37;
    wire dep_chan_vld_31_37;
    wire [40:0] dep_chan_data_31_37;
    wire token_31_37;
    wire dep_chan_vld_40_37;
    wire [40:0] dep_chan_data_40_37;
    wire token_40_37;
    wire [0:0] proc_38_data_FIFO_blk;
    wire [0:0] proc_38_data_PIPO_blk;
    wire [0:0] proc_38_start_FIFO_blk;
    wire [0:0] proc_38_TLF_FIFO_blk;
    wire [0:0] proc_38_input_sync_blk;
    wire [0:0] proc_38_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_38;
    reg [0:0] proc_dep_vld_vec_38_reg;
    wire [1:0] in_chan_dep_vld_vec_38;
    wire [81:0] in_chan_dep_data_vec_38;
    wire [1:0] token_in_vec_38;
    wire [0:0] out_chan_dep_vld_vec_38;
    wire [40:0] out_chan_dep_data_38;
    wire [0:0] token_out_vec_38;
    wire dl_detect_out_38;
    wire dep_chan_vld_31_38;
    wire [40:0] dep_chan_data_31_38;
    wire token_31_38;
    wire dep_chan_vld_40_38;
    wire [40:0] dep_chan_data_40_38;
    wire token_40_38;
    wire [0:0] proc_39_data_FIFO_blk;
    wire [0:0] proc_39_data_PIPO_blk;
    wire [0:0] proc_39_start_FIFO_blk;
    wire [0:0] proc_39_TLF_FIFO_blk;
    wire [0:0] proc_39_input_sync_blk;
    wire [0:0] proc_39_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_39;
    reg [0:0] proc_dep_vld_vec_39_reg;
    wire [1:0] in_chan_dep_vld_vec_39;
    wire [81:0] in_chan_dep_data_vec_39;
    wire [1:0] token_in_vec_39;
    wire [0:0] out_chan_dep_vld_vec_39;
    wire [40:0] out_chan_dep_data_39;
    wire [0:0] token_out_vec_39;
    wire dl_detect_out_39;
    wire dep_chan_vld_31_39;
    wire [40:0] dep_chan_data_31_39;
    wire token_31_39;
    wire dep_chan_vld_40_39;
    wire [40:0] dep_chan_data_40_39;
    wire token_40_39;
    wire [8:0] proc_40_data_FIFO_blk;
    wire [8:0] proc_40_data_PIPO_blk;
    wire [8:0] proc_40_start_FIFO_blk;
    wire [8:0] proc_40_TLF_FIFO_blk;
    wire [8:0] proc_40_input_sync_blk;
    wire [8:0] proc_40_output_sync_blk;
    wire [8:0] proc_dep_vld_vec_40;
    reg [8:0] proc_dep_vld_vec_40_reg;
    wire [0:0] in_chan_dep_vld_vec_40;
    wire [40:0] in_chan_dep_data_vec_40;
    wire [0:0] token_in_vec_40;
    wire [8:0] out_chan_dep_vld_vec_40;
    wire [40:0] out_chan_dep_data_40;
    wire [8:0] token_out_vec_40;
    wire dl_detect_out_40;
    wire dep_chan_vld_30_40;
    wire [40:0] dep_chan_data_30_40;
    wire token_30_40;
    wire [40:0] dl_in_vec;
    wire dl_detect_out;
    wire token_clear;
    reg [40:0] origin;

reg [15:0] trans_in_cnt_0;// for process grp_row_pass_fu_1276.load_rows_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_in_cnt_0 <= 16'h0;
    end
    else if (grp_row_pass_fu_1276.load_rows_U0.start_write == 1'b1) begin
        trans_in_cnt_0 <= trans_in_cnt_0 + 16'h1;
    end
    else begin
        trans_in_cnt_0 <= trans_in_cnt_0;
    end
end

reg [15:0] trans_out_cnt_0;// for process grp_row_pass_fu_1276.load_rows_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_out_cnt_0 <= 16'h0;
    end
    else if (grp_row_pass_fu_1276.load_rows_U0.ap_done == 1'b1 && grp_row_pass_fu_1276.load_rows_U0.ap_continue == 1'b1) begin
        trans_out_cnt_0 <= trans_out_cnt_0 + 16'h1;
    end
    else begin
        trans_out_cnt_0 <= trans_out_cnt_0;
    end
end

reg [15:0] trans_in_cnt_1;// for process grp_row_pass_fu_1276.fft_core_25_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_in_cnt_1 <= 16'h0;
    end
    else if (grp_row_pass_fu_1276.fft_core_25_U0.start_write == 1'b1) begin
        trans_in_cnt_1 <= trans_in_cnt_1 + 16'h1;
    end
    else begin
        trans_in_cnt_1 <= trans_in_cnt_1;
    end
end

reg [15:0] trans_out_cnt_1;// for process grp_row_pass_fu_1276.fft_core_25_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_out_cnt_1 <= 16'h0;
    end
    else if (grp_row_pass_fu_1276.fft_core_25_U0.ap_done == 1'b1 && grp_row_pass_fu_1276.fft_core_25_U0.ap_continue == 1'b1) begin
        trans_out_cnt_1 <= trans_out_cnt_1 + 16'h1;
    end
    else begin
        trans_out_cnt_1 <= trans_out_cnt_1;
    end
end

reg [15:0] trans_in_cnt_2;// for process grp_col_pass_fu_1792.load_cols_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_in_cnt_2 <= 16'h0;
    end
    else if (grp_col_pass_fu_1792.load_cols_U0.start_write == 1'b1) begin
        trans_in_cnt_2 <= trans_in_cnt_2 + 16'h1;
    end
    else begin
        trans_in_cnt_2 <= trans_in_cnt_2;
    end
end

reg [15:0] trans_out_cnt_2;// for process grp_col_pass_fu_1792.load_cols_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_out_cnt_2 <= 16'h0;
    end
    else if (grp_col_pass_fu_1792.load_cols_U0.ap_done == 1'b1 && grp_col_pass_fu_1792.load_cols_U0.ap_continue == 1'b1) begin
        trans_out_cnt_2 <= trans_out_cnt_2 + 16'h1;
    end
    else begin
        trans_out_cnt_2 <= trans_out_cnt_2;
    end
end

reg [15:0] trans_in_cnt_3;// for process grp_col_pass_fu_1792.entry_proc154_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_in_cnt_3 <= 16'h0;
    end
    else if (grp_col_pass_fu_1792.entry_proc154_U0.start_write == 1'b1) begin
        trans_in_cnt_3 <= trans_in_cnt_3 + 16'h1;
    end
    else begin
        trans_in_cnt_3 <= trans_in_cnt_3;
    end
end

reg [15:0] trans_out_cnt_3;// for process grp_col_pass_fu_1792.entry_proc154_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_out_cnt_3 <= 16'h0;
    end
    else if (grp_col_pass_fu_1792.entry_proc154_U0.ap_done == 1'b1 && grp_col_pass_fu_1792.entry_proc154_U0.ap_continue == 1'b1) begin
        trans_out_cnt_3 <= trans_out_cnt_3 + 16'h1;
    end
    else begin
        trans_out_cnt_3 <= trans_out_cnt_3;
    end
end

reg [15:0] trans_in_cnt_4;// for process grp_col_pass_fu_1792.apply_g_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_in_cnt_4 <= 16'h0;
    end
    else if (grp_col_pass_fu_1792.apply_g_U0.start_write == 1'b1) begin
        trans_in_cnt_4 <= trans_in_cnt_4 + 16'h1;
    end
    else begin
        trans_in_cnt_4 <= trans_in_cnt_4;
    end
end

reg [15:0] trans_out_cnt_4;// for process grp_col_pass_fu_1792.apply_g_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_out_cnt_4 <= 16'h0;
    end
    else if (grp_col_pass_fu_1792.apply_g_U0.ap_done == 1'b1 && grp_col_pass_fu_1792.apply_g_U0.ap_continue == 1'b1) begin
        trans_out_cnt_4 <= trans_out_cnt_4 + 16'h1;
    end
    else begin
        trans_out_cnt_4 <= trans_out_cnt_4;
    end
end

reg [15:0] trans_in_cnt_5;// for process grp_col_pass_fu_1792.fft_core_17_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_in_cnt_5 <= 16'h0;
    end
    else if (grp_col_pass_fu_1792.fft_core_17_U0.start_write == 1'b1) begin
        trans_in_cnt_5 <= trans_in_cnt_5 + 16'h1;
    end
    else begin
        trans_in_cnt_5 <= trans_in_cnt_5;
    end
end

reg [15:0] trans_out_cnt_5;// for process grp_col_pass_fu_1792.fft_core_17_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_out_cnt_5 <= 16'h0;
    end
    else if (grp_col_pass_fu_1792.fft_core_17_U0.ap_done == 1'b1 && grp_col_pass_fu_1792.fft_core_17_U0.ap_continue == 1'b1) begin
        trans_out_cnt_5 <= trans_out_cnt_5 + 16'h1;
    end
    else begin
        trans_out_cnt_5 <= trans_out_cnt_5;
    end
end

reg [15:0] trans_in_cnt_6;// for process grp_inv_pass_fu_2319.load_rows2_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_in_cnt_6 <= 16'h0;
    end
    else if (grp_inv_pass_fu_2319.load_rows2_U0.start_write == 1'b1) begin
        trans_in_cnt_6 <= trans_in_cnt_6 + 16'h1;
    end
    else begin
        trans_in_cnt_6 <= trans_in_cnt_6;
    end
end

reg [15:0] trans_out_cnt_6;// for process grp_inv_pass_fu_2319.load_rows2_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_out_cnt_6 <= 16'h0;
    end
    else if (grp_inv_pass_fu_2319.load_rows2_U0.ap_done == 1'b1 && grp_inv_pass_fu_2319.load_rows2_U0.ap_continue == 1'b1) begin
        trans_out_cnt_6 <= trans_out_cnt_6 + 16'h1;
    end
    else begin
        trans_out_cnt_6 <= trans_out_cnt_6;
    end
end

reg [15:0] trans_in_cnt_7;// for process grp_inv_pass_fu_2319.entry_proc_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_in_cnt_7 <= 16'h0;
    end
    else if (grp_inv_pass_fu_2319.entry_proc_U0.start_write == 1'b1) begin
        trans_in_cnt_7 <= trans_in_cnt_7 + 16'h1;
    end
    else begin
        trans_in_cnt_7 <= trans_in_cnt_7;
    end
end

reg [15:0] trans_out_cnt_7;// for process grp_inv_pass_fu_2319.entry_proc_U0
always @(negedge dl_reset or posedge dl_clock) begin
    if (~dl_reset) begin
         trans_out_cnt_7 <= 16'h0;
    end
    else if (grp_inv_pass_fu_2319.entry_proc_U0.ap_done == 1'b1 && grp_inv_pass_fu_2319.entry_proc_U0.ap_continue == 1'b1) begin
        trans_out_cnt_7 <= trans_out_cnt_7 + 16'h1;
    end
    else begin
        trans_out_cnt_7 <= trans_out_cnt_7;
    end
end

    // Process: grp_row_pass_fu_1276.load_rows_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 0, 8, 8) wiener_stream_hls_deadlock_detect_unit_0 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_0),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_0),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_0),
        .token_in_vec(token_in_vec_0),
        .dl_detect_in(dl_detect_out),
        .origin(origin[0]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_0),
        .out_chan_dep_data(out_chan_dep_data_0),
        .token_out_vec(token_out_vec_0),
        .dl_detect_out(dl_in_vec[0]));

    assign proc_0_data_FIFO_blk[0] = 1'b0 | (~grp_row_pass_fu_1276.load_rows_U0.fin_0_blk_n);
    assign proc_0_data_PIPO_blk[0] = 1'b0;
    assign proc_0_start_FIFO_blk[0] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_25_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_25_U0_U.if_read);
    assign proc_0_TLF_FIFO_blk[0] = 1'b0;
    assign proc_0_input_sync_blk[0] = 1'b0;
    assign proc_0_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_0[0] = dl_detect_out ? proc_dep_vld_vec_0_reg[0] : (proc_0_data_FIFO_blk[0] | proc_0_data_PIPO_blk[0] | proc_0_start_FIFO_blk[0] | proc_0_TLF_FIFO_blk[0] | proc_0_input_sync_blk[0] | proc_0_output_sync_blk[0]);
    assign proc_0_data_FIFO_blk[1] = 1'b0 | (~grp_row_pass_fu_1276.load_rows_U0.fin_1_blk_n);
    assign proc_0_data_PIPO_blk[1] = 1'b0;
    assign proc_0_start_FIFO_blk[1] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_26_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_26_U0_U.if_read);
    assign proc_0_TLF_FIFO_blk[1] = 1'b0;
    assign proc_0_input_sync_blk[1] = 1'b0;
    assign proc_0_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_0[1] = dl_detect_out ? proc_dep_vld_vec_0_reg[1] : (proc_0_data_FIFO_blk[1] | proc_0_data_PIPO_blk[1] | proc_0_start_FIFO_blk[1] | proc_0_TLF_FIFO_blk[1] | proc_0_input_sync_blk[1] | proc_0_output_sync_blk[1]);
    assign proc_0_data_FIFO_blk[2] = 1'b0 | (~grp_row_pass_fu_1276.load_rows_U0.fin_2_blk_n);
    assign proc_0_data_PIPO_blk[2] = 1'b0;
    assign proc_0_start_FIFO_blk[2] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_27_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_27_U0_U.if_read);
    assign proc_0_TLF_FIFO_blk[2] = 1'b0;
    assign proc_0_input_sync_blk[2] = 1'b0;
    assign proc_0_output_sync_blk[2] = 1'b0;
    assign proc_dep_vld_vec_0[2] = dl_detect_out ? proc_dep_vld_vec_0_reg[2] : (proc_0_data_FIFO_blk[2] | proc_0_data_PIPO_blk[2] | proc_0_start_FIFO_blk[2] | proc_0_TLF_FIFO_blk[2] | proc_0_input_sync_blk[2] | proc_0_output_sync_blk[2]);
    assign proc_0_data_FIFO_blk[3] = 1'b0 | (~grp_row_pass_fu_1276.load_rows_U0.fin_3_blk_n);
    assign proc_0_data_PIPO_blk[3] = 1'b0;
    assign proc_0_start_FIFO_blk[3] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_28_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_28_U0_U.if_read);
    assign proc_0_TLF_FIFO_blk[3] = 1'b0;
    assign proc_0_input_sync_blk[3] = 1'b0;
    assign proc_0_output_sync_blk[3] = 1'b0;
    assign proc_dep_vld_vec_0[3] = dl_detect_out ? proc_dep_vld_vec_0_reg[3] : (proc_0_data_FIFO_blk[3] | proc_0_data_PIPO_blk[3] | proc_0_start_FIFO_blk[3] | proc_0_TLF_FIFO_blk[3] | proc_0_input_sync_blk[3] | proc_0_output_sync_blk[3]);
    assign proc_0_data_FIFO_blk[4] = 1'b0 | (~grp_row_pass_fu_1276.load_rows_U0.fin_4_blk_n);
    assign proc_0_data_PIPO_blk[4] = 1'b0;
    assign proc_0_start_FIFO_blk[4] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_29_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_29_U0_U.if_read);
    assign proc_0_TLF_FIFO_blk[4] = 1'b0;
    assign proc_0_input_sync_blk[4] = 1'b0;
    assign proc_0_output_sync_blk[4] = 1'b0;
    assign proc_dep_vld_vec_0[4] = dl_detect_out ? proc_dep_vld_vec_0_reg[4] : (proc_0_data_FIFO_blk[4] | proc_0_data_PIPO_blk[4] | proc_0_start_FIFO_blk[4] | proc_0_TLF_FIFO_blk[4] | proc_0_input_sync_blk[4] | proc_0_output_sync_blk[4]);
    assign proc_0_data_FIFO_blk[5] = 1'b0 | (~grp_row_pass_fu_1276.load_rows_U0.fin_5_blk_n);
    assign proc_0_data_PIPO_blk[5] = 1'b0;
    assign proc_0_start_FIFO_blk[5] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_30_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_30_U0_U.if_read);
    assign proc_0_TLF_FIFO_blk[5] = 1'b0;
    assign proc_0_input_sync_blk[5] = 1'b0;
    assign proc_0_output_sync_blk[5] = 1'b0;
    assign proc_dep_vld_vec_0[5] = dl_detect_out ? proc_dep_vld_vec_0_reg[5] : (proc_0_data_FIFO_blk[5] | proc_0_data_PIPO_blk[5] | proc_0_start_FIFO_blk[5] | proc_0_TLF_FIFO_blk[5] | proc_0_input_sync_blk[5] | proc_0_output_sync_blk[5]);
    assign proc_0_data_FIFO_blk[6] = 1'b0 | (~grp_row_pass_fu_1276.load_rows_U0.fin_6_blk_n);
    assign proc_0_data_PIPO_blk[6] = 1'b0;
    assign proc_0_start_FIFO_blk[6] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_31_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_31_U0_U.if_read);
    assign proc_0_TLF_FIFO_blk[6] = 1'b0;
    assign proc_0_input_sync_blk[6] = 1'b0;
    assign proc_0_output_sync_blk[6] = 1'b0;
    assign proc_dep_vld_vec_0[6] = dl_detect_out ? proc_dep_vld_vec_0_reg[6] : (proc_0_data_FIFO_blk[6] | proc_0_data_PIPO_blk[6] | proc_0_start_FIFO_blk[6] | proc_0_TLF_FIFO_blk[6] | proc_0_input_sync_blk[6] | proc_0_output_sync_blk[6]);
    assign proc_0_data_FIFO_blk[7] = 1'b0 | (~grp_row_pass_fu_1276.load_rows_U0.fin_7_blk_n);
    assign proc_0_data_PIPO_blk[7] = 1'b0;
    assign proc_0_start_FIFO_blk[7] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_U0_U.if_read);
    assign proc_0_TLF_FIFO_blk[7] = 1'b0;
    assign proc_0_input_sync_blk[7] = 1'b0;
    assign proc_0_output_sync_blk[7] = 1'b0;
    assign proc_dep_vld_vec_0[7] = dl_detect_out ? proc_dep_vld_vec_0_reg[7] : (proc_0_data_FIFO_blk[7] | proc_0_data_PIPO_blk[7] | proc_0_start_FIFO_blk[7] | proc_0_TLF_FIFO_blk[7] | proc_0_input_sync_blk[7] | proc_0_output_sync_blk[7]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_0_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_0_reg <= proc_dep_vld_vec_0;
        end
    end
    assign in_chan_dep_vld_vec_0[0] = dep_chan_vld_1_0;
    assign in_chan_dep_data_vec_0[40 : 0] = dep_chan_data_1_0;
    assign token_in_vec_0[0] = token_1_0;
    assign in_chan_dep_vld_vec_0[1] = dep_chan_vld_2_0;
    assign in_chan_dep_data_vec_0[81 : 41] = dep_chan_data_2_0;
    assign token_in_vec_0[1] = token_2_0;
    assign in_chan_dep_vld_vec_0[2] = dep_chan_vld_3_0;
    assign in_chan_dep_data_vec_0[122 : 82] = dep_chan_data_3_0;
    assign token_in_vec_0[2] = token_3_0;
    assign in_chan_dep_vld_vec_0[3] = dep_chan_vld_4_0;
    assign in_chan_dep_data_vec_0[163 : 123] = dep_chan_data_4_0;
    assign token_in_vec_0[3] = token_4_0;
    assign in_chan_dep_vld_vec_0[4] = dep_chan_vld_5_0;
    assign in_chan_dep_data_vec_0[204 : 164] = dep_chan_data_5_0;
    assign token_in_vec_0[4] = token_5_0;
    assign in_chan_dep_vld_vec_0[5] = dep_chan_vld_6_0;
    assign in_chan_dep_data_vec_0[245 : 205] = dep_chan_data_6_0;
    assign token_in_vec_0[5] = token_6_0;
    assign in_chan_dep_vld_vec_0[6] = dep_chan_vld_7_0;
    assign in_chan_dep_data_vec_0[286 : 246] = dep_chan_data_7_0;
    assign token_in_vec_0[6] = token_7_0;
    assign in_chan_dep_vld_vec_0[7] = dep_chan_vld_8_0;
    assign in_chan_dep_data_vec_0[327 : 287] = dep_chan_data_8_0;
    assign token_in_vec_0[7] = token_8_0;
    assign dep_chan_vld_0_1 = out_chan_dep_vld_vec_0[0];
    assign dep_chan_data_0_1 = out_chan_dep_data_0;
    assign token_0_1 = token_out_vec_0[0];
    assign dep_chan_vld_0_2 = out_chan_dep_vld_vec_0[1];
    assign dep_chan_data_0_2 = out_chan_dep_data_0;
    assign token_0_2 = token_out_vec_0[1];
    assign dep_chan_vld_0_3 = out_chan_dep_vld_vec_0[2];
    assign dep_chan_data_0_3 = out_chan_dep_data_0;
    assign token_0_3 = token_out_vec_0[2];
    assign dep_chan_vld_0_4 = out_chan_dep_vld_vec_0[3];
    assign dep_chan_data_0_4 = out_chan_dep_data_0;
    assign token_0_4 = token_out_vec_0[3];
    assign dep_chan_vld_0_5 = out_chan_dep_vld_vec_0[4];
    assign dep_chan_data_0_5 = out_chan_dep_data_0;
    assign token_0_5 = token_out_vec_0[4];
    assign dep_chan_vld_0_6 = out_chan_dep_vld_vec_0[5];
    assign dep_chan_data_0_6 = out_chan_dep_data_0;
    assign token_0_6 = token_out_vec_0[5];
    assign dep_chan_vld_0_7 = out_chan_dep_vld_vec_0[6];
    assign dep_chan_data_0_7 = out_chan_dep_data_0;
    assign token_0_7 = token_out_vec_0[6];
    assign dep_chan_vld_0_8 = out_chan_dep_vld_vec_0[7];
    assign dep_chan_data_0_8 = out_chan_dep_data_0;
    assign token_0_8 = token_out_vec_0[7];

    // Process: grp_row_pass_fu_1276.fft_core_25_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 1, 2, 2) wiener_stream_hls_deadlock_detect_unit_1 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_1),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_1),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_1),
        .token_in_vec(token_in_vec_1),
        .dl_detect_in(dl_detect_out),
        .origin(origin[1]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_1),
        .out_chan_dep_data(out_chan_dep_data_1),
        .token_out_vec(token_out_vec_1),
        .dl_detect_out(dl_in_vec[1]));

    assign proc_1_data_FIFO_blk[0] = 1'b0;
    assign proc_1_data_PIPO_blk[0] = 1'b0;
    assign proc_1_start_FIFO_blk[0] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_25_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_25_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_25_U0_U.if_write);
    assign proc_1_TLF_FIFO_blk[0] = 1'b0;
    assign proc_1_input_sync_blk[0] = 1'b0;
    assign proc_1_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_1[0] = dl_detect_out ? proc_dep_vld_vec_1_reg[0] : (proc_1_data_FIFO_blk[0] | proc_1_data_PIPO_blk[0] | proc_1_start_FIFO_blk[0] | proc_1_TLF_FIFO_blk[0] | proc_1_input_sync_blk[0] | proc_1_output_sync_blk[0]);
    assign proc_1_data_FIFO_blk[1] = 1'b0;
    assign proc_1_data_PIPO_blk[1] = 1'b0;
    assign proc_1_start_FIFO_blk[1] = 1'b0 | (~grp_row_pass_fu_1276.start_for_store_rows_U0_U.if_full_n & grp_row_pass_fu_1276.fft_core_25_U0.ap_start & ~grp_row_pass_fu_1276.fft_core_25_U0.real_start & (trans_in_cnt_1 == trans_out_cnt_1) & ~grp_row_pass_fu_1276.start_for_store_rows_U0_U.if_read);
    assign proc_1_TLF_FIFO_blk[1] = 1'b0;
    assign proc_1_input_sync_blk[1] = 1'b0;
    assign proc_1_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_1[1] = dl_detect_out ? proc_dep_vld_vec_1_reg[1] : (proc_1_data_FIFO_blk[1] | proc_1_data_PIPO_blk[1] | proc_1_start_FIFO_blk[1] | proc_1_TLF_FIFO_blk[1] | proc_1_input_sync_blk[1] | proc_1_output_sync_blk[1]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_1_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_1_reg <= proc_dep_vld_vec_1;
        end
    end
    assign in_chan_dep_vld_vec_1[0] = dep_chan_vld_0_1;
    assign in_chan_dep_data_vec_1[40 : 0] = dep_chan_data_0_1;
    assign token_in_vec_1[0] = token_0_1;
    assign in_chan_dep_vld_vec_1[1] = dep_chan_vld_9_1;
    assign in_chan_dep_data_vec_1[81 : 41] = dep_chan_data_9_1;
    assign token_in_vec_1[1] = token_9_1;
    assign dep_chan_vld_1_0 = out_chan_dep_vld_vec_1[0];
    assign dep_chan_data_1_0 = out_chan_dep_data_1;
    assign token_1_0 = token_out_vec_1[0];
    assign dep_chan_vld_1_9 = out_chan_dep_vld_vec_1[1];
    assign dep_chan_data_1_9 = out_chan_dep_data_1;
    assign token_1_9 = token_out_vec_1[1];

    // Process: grp_row_pass_fu_1276.fft_core_26_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 2, 2, 1) wiener_stream_hls_deadlock_detect_unit_2 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_2),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_2),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_2),
        .token_in_vec(token_in_vec_2),
        .dl_detect_in(dl_detect_out),
        .origin(origin[2]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_2),
        .out_chan_dep_data(out_chan_dep_data_2),
        .token_out_vec(token_out_vec_2),
        .dl_detect_out(dl_in_vec[2]));

    assign proc_2_data_FIFO_blk[0] = 1'b0;
    assign proc_2_data_PIPO_blk[0] = 1'b0;
    assign proc_2_start_FIFO_blk[0] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_26_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_26_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_26_U0_U.if_write);
    assign proc_2_TLF_FIFO_blk[0] = 1'b0;
    assign proc_2_input_sync_blk[0] = 1'b0;
    assign proc_2_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_2[0] = dl_detect_out ? proc_dep_vld_vec_2_reg[0] : (proc_2_data_FIFO_blk[0] | proc_2_data_PIPO_blk[0] | proc_2_start_FIFO_blk[0] | proc_2_TLF_FIFO_blk[0] | proc_2_input_sync_blk[0] | proc_2_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_2_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_2_reg <= proc_dep_vld_vec_2;
        end
    end
    assign in_chan_dep_vld_vec_2[0] = dep_chan_vld_0_2;
    assign in_chan_dep_data_vec_2[40 : 0] = dep_chan_data_0_2;
    assign token_in_vec_2[0] = token_0_2;
    assign in_chan_dep_vld_vec_2[1] = dep_chan_vld_9_2;
    assign in_chan_dep_data_vec_2[81 : 41] = dep_chan_data_9_2;
    assign token_in_vec_2[1] = token_9_2;
    assign dep_chan_vld_2_0 = out_chan_dep_vld_vec_2[0];
    assign dep_chan_data_2_0 = out_chan_dep_data_2;
    assign token_2_0 = token_out_vec_2[0];

    // Process: grp_row_pass_fu_1276.fft_core_27_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 3, 2, 1) wiener_stream_hls_deadlock_detect_unit_3 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_3),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_3),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_3),
        .token_in_vec(token_in_vec_3),
        .dl_detect_in(dl_detect_out),
        .origin(origin[3]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_3),
        .out_chan_dep_data(out_chan_dep_data_3),
        .token_out_vec(token_out_vec_3),
        .dl_detect_out(dl_in_vec[3]));

    assign proc_3_data_FIFO_blk[0] = 1'b0;
    assign proc_3_data_PIPO_blk[0] = 1'b0;
    assign proc_3_start_FIFO_blk[0] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_27_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_27_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_27_U0_U.if_write);
    assign proc_3_TLF_FIFO_blk[0] = 1'b0;
    assign proc_3_input_sync_blk[0] = 1'b0;
    assign proc_3_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_3[0] = dl_detect_out ? proc_dep_vld_vec_3_reg[0] : (proc_3_data_FIFO_blk[0] | proc_3_data_PIPO_blk[0] | proc_3_start_FIFO_blk[0] | proc_3_TLF_FIFO_blk[0] | proc_3_input_sync_blk[0] | proc_3_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_3_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_3_reg <= proc_dep_vld_vec_3;
        end
    end
    assign in_chan_dep_vld_vec_3[0] = dep_chan_vld_0_3;
    assign in_chan_dep_data_vec_3[40 : 0] = dep_chan_data_0_3;
    assign token_in_vec_3[0] = token_0_3;
    assign in_chan_dep_vld_vec_3[1] = dep_chan_vld_9_3;
    assign in_chan_dep_data_vec_3[81 : 41] = dep_chan_data_9_3;
    assign token_in_vec_3[1] = token_9_3;
    assign dep_chan_vld_3_0 = out_chan_dep_vld_vec_3[0];
    assign dep_chan_data_3_0 = out_chan_dep_data_3;
    assign token_3_0 = token_out_vec_3[0];

    // Process: grp_row_pass_fu_1276.fft_core_28_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 4, 2, 1) wiener_stream_hls_deadlock_detect_unit_4 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_4),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_4),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_4),
        .token_in_vec(token_in_vec_4),
        .dl_detect_in(dl_detect_out),
        .origin(origin[4]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_4),
        .out_chan_dep_data(out_chan_dep_data_4),
        .token_out_vec(token_out_vec_4),
        .dl_detect_out(dl_in_vec[4]));

    assign proc_4_data_FIFO_blk[0] = 1'b0;
    assign proc_4_data_PIPO_blk[0] = 1'b0;
    assign proc_4_start_FIFO_blk[0] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_28_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_28_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_28_U0_U.if_write);
    assign proc_4_TLF_FIFO_blk[0] = 1'b0;
    assign proc_4_input_sync_blk[0] = 1'b0;
    assign proc_4_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_4[0] = dl_detect_out ? proc_dep_vld_vec_4_reg[0] : (proc_4_data_FIFO_blk[0] | proc_4_data_PIPO_blk[0] | proc_4_start_FIFO_blk[0] | proc_4_TLF_FIFO_blk[0] | proc_4_input_sync_blk[0] | proc_4_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_4_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_4_reg <= proc_dep_vld_vec_4;
        end
    end
    assign in_chan_dep_vld_vec_4[0] = dep_chan_vld_0_4;
    assign in_chan_dep_data_vec_4[40 : 0] = dep_chan_data_0_4;
    assign token_in_vec_4[0] = token_0_4;
    assign in_chan_dep_vld_vec_4[1] = dep_chan_vld_9_4;
    assign in_chan_dep_data_vec_4[81 : 41] = dep_chan_data_9_4;
    assign token_in_vec_4[1] = token_9_4;
    assign dep_chan_vld_4_0 = out_chan_dep_vld_vec_4[0];
    assign dep_chan_data_4_0 = out_chan_dep_data_4;
    assign token_4_0 = token_out_vec_4[0];

    // Process: grp_row_pass_fu_1276.fft_core_29_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 5, 2, 1) wiener_stream_hls_deadlock_detect_unit_5 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_5),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_5),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_5),
        .token_in_vec(token_in_vec_5),
        .dl_detect_in(dl_detect_out),
        .origin(origin[5]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_5),
        .out_chan_dep_data(out_chan_dep_data_5),
        .token_out_vec(token_out_vec_5),
        .dl_detect_out(dl_in_vec[5]));

    assign proc_5_data_FIFO_blk[0] = 1'b0;
    assign proc_5_data_PIPO_blk[0] = 1'b0;
    assign proc_5_start_FIFO_blk[0] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_29_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_29_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_29_U0_U.if_write);
    assign proc_5_TLF_FIFO_blk[0] = 1'b0;
    assign proc_5_input_sync_blk[0] = 1'b0;
    assign proc_5_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_5[0] = dl_detect_out ? proc_dep_vld_vec_5_reg[0] : (proc_5_data_FIFO_blk[0] | proc_5_data_PIPO_blk[0] | proc_5_start_FIFO_blk[0] | proc_5_TLF_FIFO_blk[0] | proc_5_input_sync_blk[0] | proc_5_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_5_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_5_reg <= proc_dep_vld_vec_5;
        end
    end
    assign in_chan_dep_vld_vec_5[0] = dep_chan_vld_0_5;
    assign in_chan_dep_data_vec_5[40 : 0] = dep_chan_data_0_5;
    assign token_in_vec_5[0] = token_0_5;
    assign in_chan_dep_vld_vec_5[1] = dep_chan_vld_9_5;
    assign in_chan_dep_data_vec_5[81 : 41] = dep_chan_data_9_5;
    assign token_in_vec_5[1] = token_9_5;
    assign dep_chan_vld_5_0 = out_chan_dep_vld_vec_5[0];
    assign dep_chan_data_5_0 = out_chan_dep_data_5;
    assign token_5_0 = token_out_vec_5[0];

    // Process: grp_row_pass_fu_1276.fft_core_30_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 6, 2, 1) wiener_stream_hls_deadlock_detect_unit_6 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_6),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_6),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_6),
        .token_in_vec(token_in_vec_6),
        .dl_detect_in(dl_detect_out),
        .origin(origin[6]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_6),
        .out_chan_dep_data(out_chan_dep_data_6),
        .token_out_vec(token_out_vec_6),
        .dl_detect_out(dl_in_vec[6]));

    assign proc_6_data_FIFO_blk[0] = 1'b0;
    assign proc_6_data_PIPO_blk[0] = 1'b0;
    assign proc_6_start_FIFO_blk[0] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_30_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_30_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_30_U0_U.if_write);
    assign proc_6_TLF_FIFO_blk[0] = 1'b0;
    assign proc_6_input_sync_blk[0] = 1'b0;
    assign proc_6_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_6[0] = dl_detect_out ? proc_dep_vld_vec_6_reg[0] : (proc_6_data_FIFO_blk[0] | proc_6_data_PIPO_blk[0] | proc_6_start_FIFO_blk[0] | proc_6_TLF_FIFO_blk[0] | proc_6_input_sync_blk[0] | proc_6_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_6_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_6_reg <= proc_dep_vld_vec_6;
        end
    end
    assign in_chan_dep_vld_vec_6[0] = dep_chan_vld_0_6;
    assign in_chan_dep_data_vec_6[40 : 0] = dep_chan_data_0_6;
    assign token_in_vec_6[0] = token_0_6;
    assign in_chan_dep_vld_vec_6[1] = dep_chan_vld_9_6;
    assign in_chan_dep_data_vec_6[81 : 41] = dep_chan_data_9_6;
    assign token_in_vec_6[1] = token_9_6;
    assign dep_chan_vld_6_0 = out_chan_dep_vld_vec_6[0];
    assign dep_chan_data_6_0 = out_chan_dep_data_6;
    assign token_6_0 = token_out_vec_6[0];

    // Process: grp_row_pass_fu_1276.fft_core_31_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 7, 2, 1) wiener_stream_hls_deadlock_detect_unit_7 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_7),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_7),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_7),
        .token_in_vec(token_in_vec_7),
        .dl_detect_in(dl_detect_out),
        .origin(origin[7]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_7),
        .out_chan_dep_data(out_chan_dep_data_7),
        .token_out_vec(token_out_vec_7),
        .dl_detect_out(dl_in_vec[7]));

    assign proc_7_data_FIFO_blk[0] = 1'b0;
    assign proc_7_data_PIPO_blk[0] = 1'b0;
    assign proc_7_start_FIFO_blk[0] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_31_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_31_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_31_U0_U.if_write);
    assign proc_7_TLF_FIFO_blk[0] = 1'b0;
    assign proc_7_input_sync_blk[0] = 1'b0;
    assign proc_7_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_7[0] = dl_detect_out ? proc_dep_vld_vec_7_reg[0] : (proc_7_data_FIFO_blk[0] | proc_7_data_PIPO_blk[0] | proc_7_start_FIFO_blk[0] | proc_7_TLF_FIFO_blk[0] | proc_7_input_sync_blk[0] | proc_7_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_7_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_7_reg <= proc_dep_vld_vec_7;
        end
    end
    assign in_chan_dep_vld_vec_7[0] = dep_chan_vld_0_7;
    assign in_chan_dep_data_vec_7[40 : 0] = dep_chan_data_0_7;
    assign token_in_vec_7[0] = token_0_7;
    assign in_chan_dep_vld_vec_7[1] = dep_chan_vld_9_7;
    assign in_chan_dep_data_vec_7[81 : 41] = dep_chan_data_9_7;
    assign token_in_vec_7[1] = token_9_7;
    assign dep_chan_vld_7_0 = out_chan_dep_vld_vec_7[0];
    assign dep_chan_data_7_0 = out_chan_dep_data_7;
    assign token_7_0 = token_out_vec_7[0];

    // Process: grp_row_pass_fu_1276.fft_core_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 8, 2, 1) wiener_stream_hls_deadlock_detect_unit_8 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_8),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_8),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_8),
        .token_in_vec(token_in_vec_8),
        .dl_detect_in(dl_detect_out),
        .origin(origin[8]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_8),
        .out_chan_dep_data(out_chan_dep_data_8),
        .token_out_vec(token_out_vec_8),
        .dl_detect_out(dl_in_vec[8]));

    assign proc_8_data_FIFO_blk[0] = 1'b0;
    assign proc_8_data_PIPO_blk[0] = 1'b0;
    assign proc_8_start_FIFO_blk[0] = 1'b0 | (~grp_row_pass_fu_1276.start_for_fft_core_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_U0_U.if_write);
    assign proc_8_TLF_FIFO_blk[0] = 1'b0;
    assign proc_8_input_sync_blk[0] = 1'b0;
    assign proc_8_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_8[0] = dl_detect_out ? proc_dep_vld_vec_8_reg[0] : (proc_8_data_FIFO_blk[0] | proc_8_data_PIPO_blk[0] | proc_8_start_FIFO_blk[0] | proc_8_TLF_FIFO_blk[0] | proc_8_input_sync_blk[0] | proc_8_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_8_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_8_reg <= proc_dep_vld_vec_8;
        end
    end
    assign in_chan_dep_vld_vec_8[0] = dep_chan_vld_0_8;
    assign in_chan_dep_data_vec_8[40 : 0] = dep_chan_data_0_8;
    assign token_in_vec_8[0] = token_0_8;
    assign in_chan_dep_vld_vec_8[1] = dep_chan_vld_9_8;
    assign in_chan_dep_data_vec_8[81 : 41] = dep_chan_data_9_8;
    assign token_in_vec_8[1] = token_9_8;
    assign dep_chan_vld_8_0 = out_chan_dep_vld_vec_8[0];
    assign dep_chan_data_8_0 = out_chan_dep_data_8;
    assign token_8_0 = token_out_vec_8[0];

    // Process: grp_row_pass_fu_1276.store_rows_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 9, 1, 8) wiener_stream_hls_deadlock_detect_unit_9 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_9),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_9),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_9),
        .token_in_vec(token_in_vec_9),
        .dl_detect_in(dl_detect_out),
        .origin(origin[9]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_9),
        .out_chan_dep_data(out_chan_dep_data_9),
        .token_out_vec(token_out_vec_9),
        .dl_detect_out(dl_in_vec[9]));

    assign proc_9_data_FIFO_blk[0] = 1'b0 | (~grp_row_pass_fu_1276.store_rows_U0.fout_0_blk_n);
    assign proc_9_data_PIPO_blk[0] = 1'b0;
    assign proc_9_start_FIFO_blk[0] = 1'b0 | (~grp_row_pass_fu_1276.start_for_store_rows_U0_U.if_empty_n & grp_row_pass_fu_1276.store_rows_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_store_rows_U0_U.if_write);
    assign proc_9_TLF_FIFO_blk[0] = 1'b0;
    assign proc_9_input_sync_blk[0] = 1'b0;
    assign proc_9_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_9[0] = dl_detect_out ? proc_dep_vld_vec_9_reg[0] : (proc_9_data_FIFO_blk[0] | proc_9_data_PIPO_blk[0] | proc_9_start_FIFO_blk[0] | proc_9_TLF_FIFO_blk[0] | proc_9_input_sync_blk[0] | proc_9_output_sync_blk[0]);
    assign proc_9_data_FIFO_blk[1] = 1'b0 | (~grp_row_pass_fu_1276.store_rows_U0.fout_1_blk_n);
    assign proc_9_data_PIPO_blk[1] = 1'b0;
    assign proc_9_start_FIFO_blk[1] = 1'b0;
    assign proc_9_TLF_FIFO_blk[1] = 1'b0;
    assign proc_9_input_sync_blk[1] = 1'b0;
    assign proc_9_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_9[1] = dl_detect_out ? proc_dep_vld_vec_9_reg[1] : (proc_9_data_FIFO_blk[1] | proc_9_data_PIPO_blk[1] | proc_9_start_FIFO_blk[1] | proc_9_TLF_FIFO_blk[1] | proc_9_input_sync_blk[1] | proc_9_output_sync_blk[1]);
    assign proc_9_data_FIFO_blk[2] = 1'b0 | (~grp_row_pass_fu_1276.store_rows_U0.fout_2_blk_n);
    assign proc_9_data_PIPO_blk[2] = 1'b0;
    assign proc_9_start_FIFO_blk[2] = 1'b0;
    assign proc_9_TLF_FIFO_blk[2] = 1'b0;
    assign proc_9_input_sync_blk[2] = 1'b0;
    assign proc_9_output_sync_blk[2] = 1'b0;
    assign proc_dep_vld_vec_9[2] = dl_detect_out ? proc_dep_vld_vec_9_reg[2] : (proc_9_data_FIFO_blk[2] | proc_9_data_PIPO_blk[2] | proc_9_start_FIFO_blk[2] | proc_9_TLF_FIFO_blk[2] | proc_9_input_sync_blk[2] | proc_9_output_sync_blk[2]);
    assign proc_9_data_FIFO_blk[3] = 1'b0 | (~grp_row_pass_fu_1276.store_rows_U0.fout_3_blk_n);
    assign proc_9_data_PIPO_blk[3] = 1'b0;
    assign proc_9_start_FIFO_blk[3] = 1'b0;
    assign proc_9_TLF_FIFO_blk[3] = 1'b0;
    assign proc_9_input_sync_blk[3] = 1'b0;
    assign proc_9_output_sync_blk[3] = 1'b0;
    assign proc_dep_vld_vec_9[3] = dl_detect_out ? proc_dep_vld_vec_9_reg[3] : (proc_9_data_FIFO_blk[3] | proc_9_data_PIPO_blk[3] | proc_9_start_FIFO_blk[3] | proc_9_TLF_FIFO_blk[3] | proc_9_input_sync_blk[3] | proc_9_output_sync_blk[3]);
    assign proc_9_data_FIFO_blk[4] = 1'b0 | (~grp_row_pass_fu_1276.store_rows_U0.fout_4_blk_n);
    assign proc_9_data_PIPO_blk[4] = 1'b0;
    assign proc_9_start_FIFO_blk[4] = 1'b0;
    assign proc_9_TLF_FIFO_blk[4] = 1'b0;
    assign proc_9_input_sync_blk[4] = 1'b0;
    assign proc_9_output_sync_blk[4] = 1'b0;
    assign proc_dep_vld_vec_9[4] = dl_detect_out ? proc_dep_vld_vec_9_reg[4] : (proc_9_data_FIFO_blk[4] | proc_9_data_PIPO_blk[4] | proc_9_start_FIFO_blk[4] | proc_9_TLF_FIFO_blk[4] | proc_9_input_sync_blk[4] | proc_9_output_sync_blk[4]);
    assign proc_9_data_FIFO_blk[5] = 1'b0 | (~grp_row_pass_fu_1276.store_rows_U0.fout_5_blk_n);
    assign proc_9_data_PIPO_blk[5] = 1'b0;
    assign proc_9_start_FIFO_blk[5] = 1'b0;
    assign proc_9_TLF_FIFO_blk[5] = 1'b0;
    assign proc_9_input_sync_blk[5] = 1'b0;
    assign proc_9_output_sync_blk[5] = 1'b0;
    assign proc_dep_vld_vec_9[5] = dl_detect_out ? proc_dep_vld_vec_9_reg[5] : (proc_9_data_FIFO_blk[5] | proc_9_data_PIPO_blk[5] | proc_9_start_FIFO_blk[5] | proc_9_TLF_FIFO_blk[5] | proc_9_input_sync_blk[5] | proc_9_output_sync_blk[5]);
    assign proc_9_data_FIFO_blk[6] = 1'b0 | (~grp_row_pass_fu_1276.store_rows_U0.fout_6_blk_n);
    assign proc_9_data_PIPO_blk[6] = 1'b0;
    assign proc_9_start_FIFO_blk[6] = 1'b0;
    assign proc_9_TLF_FIFO_blk[6] = 1'b0;
    assign proc_9_input_sync_blk[6] = 1'b0;
    assign proc_9_output_sync_blk[6] = 1'b0;
    assign proc_dep_vld_vec_9[6] = dl_detect_out ? proc_dep_vld_vec_9_reg[6] : (proc_9_data_FIFO_blk[6] | proc_9_data_PIPO_blk[6] | proc_9_start_FIFO_blk[6] | proc_9_TLF_FIFO_blk[6] | proc_9_input_sync_blk[6] | proc_9_output_sync_blk[6]);
    assign proc_9_data_FIFO_blk[7] = 1'b0 | (~grp_row_pass_fu_1276.store_rows_U0.fout_7_blk_n);
    assign proc_9_data_PIPO_blk[7] = 1'b0;
    assign proc_9_start_FIFO_blk[7] = 1'b0;
    assign proc_9_TLF_FIFO_blk[7] = 1'b0;
    assign proc_9_input_sync_blk[7] = 1'b0;
    assign proc_9_output_sync_blk[7] = 1'b0;
    assign proc_dep_vld_vec_9[7] = dl_detect_out ? proc_dep_vld_vec_9_reg[7] : (proc_9_data_FIFO_blk[7] | proc_9_data_PIPO_blk[7] | proc_9_start_FIFO_blk[7] | proc_9_TLF_FIFO_blk[7] | proc_9_input_sync_blk[7] | proc_9_output_sync_blk[7]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_9_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_9_reg <= proc_dep_vld_vec_9;
        end
    end
    assign in_chan_dep_vld_vec_9[0] = dep_chan_vld_1_9;
    assign in_chan_dep_data_vec_9[40 : 0] = dep_chan_data_1_9;
    assign token_in_vec_9[0] = token_1_9;
    assign dep_chan_vld_9_1 = out_chan_dep_vld_vec_9[0];
    assign dep_chan_data_9_1 = out_chan_dep_data_9;
    assign token_9_1 = token_out_vec_9[0];
    assign dep_chan_vld_9_2 = out_chan_dep_vld_vec_9[1];
    assign dep_chan_data_9_2 = out_chan_dep_data_9;
    assign token_9_2 = token_out_vec_9[1];
    assign dep_chan_vld_9_3 = out_chan_dep_vld_vec_9[2];
    assign dep_chan_data_9_3 = out_chan_dep_data_9;
    assign token_9_3 = token_out_vec_9[2];
    assign dep_chan_vld_9_4 = out_chan_dep_vld_vec_9[3];
    assign dep_chan_data_9_4 = out_chan_dep_data_9;
    assign token_9_4 = token_out_vec_9[3];
    assign dep_chan_vld_9_5 = out_chan_dep_vld_vec_9[4];
    assign dep_chan_data_9_5 = out_chan_dep_data_9;
    assign token_9_5 = token_out_vec_9[4];
    assign dep_chan_vld_9_6 = out_chan_dep_vld_vec_9[5];
    assign dep_chan_data_9_6 = out_chan_dep_data_9;
    assign token_9_6 = token_out_vec_9[5];
    assign dep_chan_vld_9_7 = out_chan_dep_vld_vec_9[6];
    assign dep_chan_data_9_7 = out_chan_dep_data_9;
    assign token_9_7 = token_out_vec_9[6];
    assign dep_chan_vld_9_8 = out_chan_dep_vld_vec_9[7];
    assign dep_chan_data_9_8 = out_chan_dep_data_9;
    assign token_9_8 = token_out_vec_9[7];

    // Process: grp_col_pass_fu_1792.entry_proc154_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 10, 2, 2) wiener_stream_hls_deadlock_detect_unit_10 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_10),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_10),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_10),
        .token_in_vec(token_in_vec_10),
        .dl_detect_in(dl_detect_out),
        .origin(origin[10]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_10),
        .out_chan_dep_data(out_chan_dep_data_10),
        .token_out_vec(token_out_vec_10),
        .dl_detect_out(dl_in_vec[10]));

    assign proc_10_data_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.entry_proc154_U0.Ln_c_blk_n) | (~grp_col_pass_fu_1792.entry_proc154_U0.ct_c_blk_n) | (~grp_col_pass_fu_1792.entry_proc154_U0.st_c_blk_n);
    assign proc_10_data_PIPO_blk[0] = 1'b0;
    assign proc_10_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_apply_g_U0_U.if_full_n & grp_col_pass_fu_1792.entry_proc154_U0.ap_start & ~grp_col_pass_fu_1792.entry_proc154_U0.real_start & (trans_in_cnt_3 == trans_out_cnt_3) & ~grp_col_pass_fu_1792.start_for_apply_g_U0_U.if_read);
    assign proc_10_TLF_FIFO_blk[0] = 1'b0;
    assign proc_10_input_sync_blk[0] = 1'b0;
    assign proc_10_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_10[0] = dl_detect_out ? proc_dep_vld_vec_10_reg[0] : (proc_10_data_FIFO_blk[0] | proc_10_data_PIPO_blk[0] | proc_10_start_FIFO_blk[0] | proc_10_TLF_FIFO_blk[0] | proc_10_input_sync_blk[0] | proc_10_output_sync_blk[0]);
    assign proc_10_data_FIFO_blk[1] = 1'b0;
    assign proc_10_data_PIPO_blk[1] = 1'b0;
    assign proc_10_start_FIFO_blk[1] = 1'b0;
    assign proc_10_TLF_FIFO_blk[1] = 1'b0;
    assign proc_10_input_sync_blk[1] = 1'b0 | (grp_col_pass_fu_1792.ap_sync_entry_proc154_U0_ap_ready & grp_col_pass_fu_1792.entry_proc154_U0.ap_idle & ~grp_col_pass_fu_1792.ap_sync_load_cols_U0_ap_ready);
    assign proc_10_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_10[1] = dl_detect_out ? proc_dep_vld_vec_10_reg[1] : (proc_10_data_FIFO_blk[1] | proc_10_data_PIPO_blk[1] | proc_10_start_FIFO_blk[1] | proc_10_TLF_FIFO_blk[1] | proc_10_input_sync_blk[1] | proc_10_output_sync_blk[1]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_10_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_10_reg <= proc_dep_vld_vec_10;
        end
    end
    assign in_chan_dep_vld_vec_10[0] = dep_chan_vld_11_10;
    assign in_chan_dep_data_vec_10[40 : 0] = dep_chan_data_11_10;
    assign token_in_vec_10[0] = token_11_10;
    assign in_chan_dep_vld_vec_10[1] = dep_chan_vld_20_10;
    assign in_chan_dep_data_vec_10[81 : 41] = dep_chan_data_20_10;
    assign token_in_vec_10[1] = token_20_10;
    assign dep_chan_vld_10_20 = out_chan_dep_vld_vec_10[0];
    assign dep_chan_data_10_20 = out_chan_dep_data_10;
    assign token_10_20 = token_out_vec_10[0];
    assign dep_chan_vld_10_11 = out_chan_dep_vld_vec_10[1];
    assign dep_chan_data_10_11 = out_chan_dep_data_10;
    assign token_10_11 = token_out_vec_10[1];

    // Process: grp_col_pass_fu_1792.load_cols_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 11, 9, 9) wiener_stream_hls_deadlock_detect_unit_11 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_11),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_11),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_11),
        .token_in_vec(token_in_vec_11),
        .dl_detect_in(dl_detect_out),
        .origin(origin[11]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_11),
        .out_chan_dep_data(out_chan_dep_data_11),
        .token_out_vec(token_out_vec_11),
        .dl_detect_out(dl_in_vec[11]));

    assign proc_11_data_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.load_cols_U0.cin_0_blk_n);
    assign proc_11_data_PIPO_blk[0] = 1'b0;
    assign proc_11_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_9_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_9_U0_U.if_read);
    assign proc_11_TLF_FIFO_blk[0] = 1'b0;
    assign proc_11_input_sync_blk[0] = 1'b0;
    assign proc_11_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_11[0] = dl_detect_out ? proc_dep_vld_vec_11_reg[0] : (proc_11_data_FIFO_blk[0] | proc_11_data_PIPO_blk[0] | proc_11_start_FIFO_blk[0] | proc_11_TLF_FIFO_blk[0] | proc_11_input_sync_blk[0] | proc_11_output_sync_blk[0]);
    assign proc_11_data_FIFO_blk[1] = 1'b0 | (~grp_col_pass_fu_1792.load_cols_U0.cin_1_blk_n);
    assign proc_11_data_PIPO_blk[1] = 1'b0;
    assign proc_11_start_FIFO_blk[1] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_10_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_10_U0_U.if_read);
    assign proc_11_TLF_FIFO_blk[1] = 1'b0;
    assign proc_11_input_sync_blk[1] = 1'b0;
    assign proc_11_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_11[1] = dl_detect_out ? proc_dep_vld_vec_11_reg[1] : (proc_11_data_FIFO_blk[1] | proc_11_data_PIPO_blk[1] | proc_11_start_FIFO_blk[1] | proc_11_TLF_FIFO_blk[1] | proc_11_input_sync_blk[1] | proc_11_output_sync_blk[1]);
    assign proc_11_data_FIFO_blk[2] = 1'b0 | (~grp_col_pass_fu_1792.load_cols_U0.cin_2_blk_n);
    assign proc_11_data_PIPO_blk[2] = 1'b0;
    assign proc_11_start_FIFO_blk[2] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_11_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_11_U0_U.if_read);
    assign proc_11_TLF_FIFO_blk[2] = 1'b0;
    assign proc_11_input_sync_blk[2] = 1'b0;
    assign proc_11_output_sync_blk[2] = 1'b0;
    assign proc_dep_vld_vec_11[2] = dl_detect_out ? proc_dep_vld_vec_11_reg[2] : (proc_11_data_FIFO_blk[2] | proc_11_data_PIPO_blk[2] | proc_11_start_FIFO_blk[2] | proc_11_TLF_FIFO_blk[2] | proc_11_input_sync_blk[2] | proc_11_output_sync_blk[2]);
    assign proc_11_data_FIFO_blk[3] = 1'b0 | (~grp_col_pass_fu_1792.load_cols_U0.cin_3_blk_n);
    assign proc_11_data_PIPO_blk[3] = 1'b0;
    assign proc_11_start_FIFO_blk[3] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_12_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_12_U0_U.if_read);
    assign proc_11_TLF_FIFO_blk[3] = 1'b0;
    assign proc_11_input_sync_blk[3] = 1'b0;
    assign proc_11_output_sync_blk[3] = 1'b0;
    assign proc_dep_vld_vec_11[3] = dl_detect_out ? proc_dep_vld_vec_11_reg[3] : (proc_11_data_FIFO_blk[3] | proc_11_data_PIPO_blk[3] | proc_11_start_FIFO_blk[3] | proc_11_TLF_FIFO_blk[3] | proc_11_input_sync_blk[3] | proc_11_output_sync_blk[3]);
    assign proc_11_data_FIFO_blk[4] = 1'b0 | (~grp_col_pass_fu_1792.load_cols_U0.cin_4_blk_n);
    assign proc_11_data_PIPO_blk[4] = 1'b0;
    assign proc_11_start_FIFO_blk[4] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_13_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_13_U0_U.if_read);
    assign proc_11_TLF_FIFO_blk[4] = 1'b0;
    assign proc_11_input_sync_blk[4] = 1'b0;
    assign proc_11_output_sync_blk[4] = 1'b0;
    assign proc_dep_vld_vec_11[4] = dl_detect_out ? proc_dep_vld_vec_11_reg[4] : (proc_11_data_FIFO_blk[4] | proc_11_data_PIPO_blk[4] | proc_11_start_FIFO_blk[4] | proc_11_TLF_FIFO_blk[4] | proc_11_input_sync_blk[4] | proc_11_output_sync_blk[4]);
    assign proc_11_data_FIFO_blk[5] = 1'b0 | (~grp_col_pass_fu_1792.load_cols_U0.cin_5_blk_n);
    assign proc_11_data_PIPO_blk[5] = 1'b0;
    assign proc_11_start_FIFO_blk[5] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_14_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_14_U0_U.if_read);
    assign proc_11_TLF_FIFO_blk[5] = 1'b0;
    assign proc_11_input_sync_blk[5] = 1'b0;
    assign proc_11_output_sync_blk[5] = 1'b0;
    assign proc_dep_vld_vec_11[5] = dl_detect_out ? proc_dep_vld_vec_11_reg[5] : (proc_11_data_FIFO_blk[5] | proc_11_data_PIPO_blk[5] | proc_11_start_FIFO_blk[5] | proc_11_TLF_FIFO_blk[5] | proc_11_input_sync_blk[5] | proc_11_output_sync_blk[5]);
    assign proc_11_data_FIFO_blk[6] = 1'b0 | (~grp_col_pass_fu_1792.load_cols_U0.cin_6_blk_n);
    assign proc_11_data_PIPO_blk[6] = 1'b0;
    assign proc_11_start_FIFO_blk[6] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_15_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_15_U0_U.if_read);
    assign proc_11_TLF_FIFO_blk[6] = 1'b0;
    assign proc_11_input_sync_blk[6] = 1'b0;
    assign proc_11_output_sync_blk[6] = 1'b0;
    assign proc_dep_vld_vec_11[6] = dl_detect_out ? proc_dep_vld_vec_11_reg[6] : (proc_11_data_FIFO_blk[6] | proc_11_data_PIPO_blk[6] | proc_11_start_FIFO_blk[6] | proc_11_TLF_FIFO_blk[6] | proc_11_input_sync_blk[6] | proc_11_output_sync_blk[6]);
    assign proc_11_data_FIFO_blk[7] = 1'b0 | (~grp_col_pass_fu_1792.load_cols_U0.cin_7_blk_n);
    assign proc_11_data_PIPO_blk[7] = 1'b0;
    assign proc_11_start_FIFO_blk[7] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_16_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_16_U0_U.if_read);
    assign proc_11_TLF_FIFO_blk[7] = 1'b0;
    assign proc_11_input_sync_blk[7] = 1'b0;
    assign proc_11_output_sync_blk[7] = 1'b0;
    assign proc_dep_vld_vec_11[7] = dl_detect_out ? proc_dep_vld_vec_11_reg[7] : (proc_11_data_FIFO_blk[7] | proc_11_data_PIPO_blk[7] | proc_11_start_FIFO_blk[7] | proc_11_TLF_FIFO_blk[7] | proc_11_input_sync_blk[7] | proc_11_output_sync_blk[7]);
    assign proc_11_data_FIFO_blk[8] = 1'b0;
    assign proc_11_data_PIPO_blk[8] = 1'b0;
    assign proc_11_start_FIFO_blk[8] = 1'b0;
    assign proc_11_TLF_FIFO_blk[8] = 1'b0;
    assign proc_11_input_sync_blk[8] = 1'b0 | (grp_col_pass_fu_1792.ap_sync_load_cols_U0_ap_ready & grp_col_pass_fu_1792.load_cols_U0.ap_idle & ~grp_col_pass_fu_1792.ap_sync_entry_proc154_U0_ap_ready);
    assign proc_11_output_sync_blk[8] = 1'b0;
    assign proc_dep_vld_vec_11[8] = dl_detect_out ? proc_dep_vld_vec_11_reg[8] : (proc_11_data_FIFO_blk[8] | proc_11_data_PIPO_blk[8] | proc_11_start_FIFO_blk[8] | proc_11_TLF_FIFO_blk[8] | proc_11_input_sync_blk[8] | proc_11_output_sync_blk[8]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_11_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_11_reg <= proc_dep_vld_vec_11;
        end
    end
    assign in_chan_dep_vld_vec_11[0] = dep_chan_vld_10_11;
    assign in_chan_dep_data_vec_11[40 : 0] = dep_chan_data_10_11;
    assign token_in_vec_11[0] = token_10_11;
    assign in_chan_dep_vld_vec_11[1] = dep_chan_vld_12_11;
    assign in_chan_dep_data_vec_11[81 : 41] = dep_chan_data_12_11;
    assign token_in_vec_11[1] = token_12_11;
    assign in_chan_dep_vld_vec_11[2] = dep_chan_vld_13_11;
    assign in_chan_dep_data_vec_11[122 : 82] = dep_chan_data_13_11;
    assign token_in_vec_11[2] = token_13_11;
    assign in_chan_dep_vld_vec_11[3] = dep_chan_vld_14_11;
    assign in_chan_dep_data_vec_11[163 : 123] = dep_chan_data_14_11;
    assign token_in_vec_11[3] = token_14_11;
    assign in_chan_dep_vld_vec_11[4] = dep_chan_vld_15_11;
    assign in_chan_dep_data_vec_11[204 : 164] = dep_chan_data_15_11;
    assign token_in_vec_11[4] = token_15_11;
    assign in_chan_dep_vld_vec_11[5] = dep_chan_vld_16_11;
    assign in_chan_dep_data_vec_11[245 : 205] = dep_chan_data_16_11;
    assign token_in_vec_11[5] = token_16_11;
    assign in_chan_dep_vld_vec_11[6] = dep_chan_vld_17_11;
    assign in_chan_dep_data_vec_11[286 : 246] = dep_chan_data_17_11;
    assign token_in_vec_11[6] = token_17_11;
    assign in_chan_dep_vld_vec_11[7] = dep_chan_vld_18_11;
    assign in_chan_dep_data_vec_11[327 : 287] = dep_chan_data_18_11;
    assign token_in_vec_11[7] = token_18_11;
    assign in_chan_dep_vld_vec_11[8] = dep_chan_vld_19_11;
    assign in_chan_dep_data_vec_11[368 : 328] = dep_chan_data_19_11;
    assign token_in_vec_11[8] = token_19_11;
    assign dep_chan_vld_11_12 = out_chan_dep_vld_vec_11[0];
    assign dep_chan_data_11_12 = out_chan_dep_data_11;
    assign token_11_12 = token_out_vec_11[0];
    assign dep_chan_vld_11_13 = out_chan_dep_vld_vec_11[1];
    assign dep_chan_data_11_13 = out_chan_dep_data_11;
    assign token_11_13 = token_out_vec_11[1];
    assign dep_chan_vld_11_14 = out_chan_dep_vld_vec_11[2];
    assign dep_chan_data_11_14 = out_chan_dep_data_11;
    assign token_11_14 = token_out_vec_11[2];
    assign dep_chan_vld_11_15 = out_chan_dep_vld_vec_11[3];
    assign dep_chan_data_11_15 = out_chan_dep_data_11;
    assign token_11_15 = token_out_vec_11[3];
    assign dep_chan_vld_11_16 = out_chan_dep_vld_vec_11[4];
    assign dep_chan_data_11_16 = out_chan_dep_data_11;
    assign token_11_16 = token_out_vec_11[4];
    assign dep_chan_vld_11_17 = out_chan_dep_vld_vec_11[5];
    assign dep_chan_data_11_17 = out_chan_dep_data_11;
    assign token_11_17 = token_out_vec_11[5];
    assign dep_chan_vld_11_18 = out_chan_dep_vld_vec_11[6];
    assign dep_chan_data_11_18 = out_chan_dep_data_11;
    assign token_11_18 = token_out_vec_11[6];
    assign dep_chan_vld_11_19 = out_chan_dep_vld_vec_11[7];
    assign dep_chan_data_11_19 = out_chan_dep_data_11;
    assign token_11_19 = token_out_vec_11[7];
    assign dep_chan_vld_11_10 = out_chan_dep_vld_vec_11[8];
    assign dep_chan_data_11_10 = out_chan_dep_data_11;
    assign token_11_10 = token_out_vec_11[8];

    // Process: grp_col_pass_fu_1792.fft_core_9_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 12, 2, 1) wiener_stream_hls_deadlock_detect_unit_12 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_12),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_12),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_12),
        .token_in_vec(token_in_vec_12),
        .dl_detect_in(dl_detect_out),
        .origin(origin[12]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_12),
        .out_chan_dep_data(out_chan_dep_data_12),
        .token_out_vec(token_out_vec_12),
        .dl_detect_out(dl_in_vec[12]));

    assign proc_12_data_FIFO_blk[0] = 1'b0;
    assign proc_12_data_PIPO_blk[0] = 1'b0;
    assign proc_12_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_9_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_9_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_9_U0_U.if_write);
    assign proc_12_TLF_FIFO_blk[0] = 1'b0;
    assign proc_12_input_sync_blk[0] = 1'b0;
    assign proc_12_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_12[0] = dl_detect_out ? proc_dep_vld_vec_12_reg[0] : (proc_12_data_FIFO_blk[0] | proc_12_data_PIPO_blk[0] | proc_12_start_FIFO_blk[0] | proc_12_TLF_FIFO_blk[0] | proc_12_input_sync_blk[0] | proc_12_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_12_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_12_reg <= proc_dep_vld_vec_12;
        end
    end
    assign in_chan_dep_vld_vec_12[0] = dep_chan_vld_11_12;
    assign in_chan_dep_data_vec_12[40 : 0] = dep_chan_data_11_12;
    assign token_in_vec_12[0] = token_11_12;
    assign in_chan_dep_vld_vec_12[1] = dep_chan_vld_20_12;
    assign in_chan_dep_data_vec_12[81 : 41] = dep_chan_data_20_12;
    assign token_in_vec_12[1] = token_20_12;
    assign dep_chan_vld_12_11 = out_chan_dep_vld_vec_12[0];
    assign dep_chan_data_12_11 = out_chan_dep_data_12;
    assign token_12_11 = token_out_vec_12[0];

    // Process: grp_col_pass_fu_1792.fft_core_10_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 13, 2, 1) wiener_stream_hls_deadlock_detect_unit_13 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_13),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_13),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_13),
        .token_in_vec(token_in_vec_13),
        .dl_detect_in(dl_detect_out),
        .origin(origin[13]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_13),
        .out_chan_dep_data(out_chan_dep_data_13),
        .token_out_vec(token_out_vec_13),
        .dl_detect_out(dl_in_vec[13]));

    assign proc_13_data_FIFO_blk[0] = 1'b0;
    assign proc_13_data_PIPO_blk[0] = 1'b0;
    assign proc_13_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_10_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_10_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_10_U0_U.if_write);
    assign proc_13_TLF_FIFO_blk[0] = 1'b0;
    assign proc_13_input_sync_blk[0] = 1'b0;
    assign proc_13_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_13[0] = dl_detect_out ? proc_dep_vld_vec_13_reg[0] : (proc_13_data_FIFO_blk[0] | proc_13_data_PIPO_blk[0] | proc_13_start_FIFO_blk[0] | proc_13_TLF_FIFO_blk[0] | proc_13_input_sync_blk[0] | proc_13_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_13_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_13_reg <= proc_dep_vld_vec_13;
        end
    end
    assign in_chan_dep_vld_vec_13[0] = dep_chan_vld_11_13;
    assign in_chan_dep_data_vec_13[40 : 0] = dep_chan_data_11_13;
    assign token_in_vec_13[0] = token_11_13;
    assign in_chan_dep_vld_vec_13[1] = dep_chan_vld_20_13;
    assign in_chan_dep_data_vec_13[81 : 41] = dep_chan_data_20_13;
    assign token_in_vec_13[1] = token_20_13;
    assign dep_chan_vld_13_11 = out_chan_dep_vld_vec_13[0];
    assign dep_chan_data_13_11 = out_chan_dep_data_13;
    assign token_13_11 = token_out_vec_13[0];

    // Process: grp_col_pass_fu_1792.fft_core_11_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 14, 2, 1) wiener_stream_hls_deadlock_detect_unit_14 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_14),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_14),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_14),
        .token_in_vec(token_in_vec_14),
        .dl_detect_in(dl_detect_out),
        .origin(origin[14]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_14),
        .out_chan_dep_data(out_chan_dep_data_14),
        .token_out_vec(token_out_vec_14),
        .dl_detect_out(dl_in_vec[14]));

    assign proc_14_data_FIFO_blk[0] = 1'b0;
    assign proc_14_data_PIPO_blk[0] = 1'b0;
    assign proc_14_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_11_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_11_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_11_U0_U.if_write);
    assign proc_14_TLF_FIFO_blk[0] = 1'b0;
    assign proc_14_input_sync_blk[0] = 1'b0;
    assign proc_14_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_14[0] = dl_detect_out ? proc_dep_vld_vec_14_reg[0] : (proc_14_data_FIFO_blk[0] | proc_14_data_PIPO_blk[0] | proc_14_start_FIFO_blk[0] | proc_14_TLF_FIFO_blk[0] | proc_14_input_sync_blk[0] | proc_14_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_14_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_14_reg <= proc_dep_vld_vec_14;
        end
    end
    assign in_chan_dep_vld_vec_14[0] = dep_chan_vld_11_14;
    assign in_chan_dep_data_vec_14[40 : 0] = dep_chan_data_11_14;
    assign token_in_vec_14[0] = token_11_14;
    assign in_chan_dep_vld_vec_14[1] = dep_chan_vld_20_14;
    assign in_chan_dep_data_vec_14[81 : 41] = dep_chan_data_20_14;
    assign token_in_vec_14[1] = token_20_14;
    assign dep_chan_vld_14_11 = out_chan_dep_vld_vec_14[0];
    assign dep_chan_data_14_11 = out_chan_dep_data_14;
    assign token_14_11 = token_out_vec_14[0];

    // Process: grp_col_pass_fu_1792.fft_core_12_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 15, 2, 1) wiener_stream_hls_deadlock_detect_unit_15 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_15),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_15),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_15),
        .token_in_vec(token_in_vec_15),
        .dl_detect_in(dl_detect_out),
        .origin(origin[15]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_15),
        .out_chan_dep_data(out_chan_dep_data_15),
        .token_out_vec(token_out_vec_15),
        .dl_detect_out(dl_in_vec[15]));

    assign proc_15_data_FIFO_blk[0] = 1'b0;
    assign proc_15_data_PIPO_blk[0] = 1'b0;
    assign proc_15_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_12_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_12_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_12_U0_U.if_write);
    assign proc_15_TLF_FIFO_blk[0] = 1'b0;
    assign proc_15_input_sync_blk[0] = 1'b0;
    assign proc_15_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_15[0] = dl_detect_out ? proc_dep_vld_vec_15_reg[0] : (proc_15_data_FIFO_blk[0] | proc_15_data_PIPO_blk[0] | proc_15_start_FIFO_blk[0] | proc_15_TLF_FIFO_blk[0] | proc_15_input_sync_blk[0] | proc_15_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_15_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_15_reg <= proc_dep_vld_vec_15;
        end
    end
    assign in_chan_dep_vld_vec_15[0] = dep_chan_vld_11_15;
    assign in_chan_dep_data_vec_15[40 : 0] = dep_chan_data_11_15;
    assign token_in_vec_15[0] = token_11_15;
    assign in_chan_dep_vld_vec_15[1] = dep_chan_vld_20_15;
    assign in_chan_dep_data_vec_15[81 : 41] = dep_chan_data_20_15;
    assign token_in_vec_15[1] = token_20_15;
    assign dep_chan_vld_15_11 = out_chan_dep_vld_vec_15[0];
    assign dep_chan_data_15_11 = out_chan_dep_data_15;
    assign token_15_11 = token_out_vec_15[0];

    // Process: grp_col_pass_fu_1792.fft_core_13_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 16, 2, 1) wiener_stream_hls_deadlock_detect_unit_16 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_16),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_16),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_16),
        .token_in_vec(token_in_vec_16),
        .dl_detect_in(dl_detect_out),
        .origin(origin[16]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_16),
        .out_chan_dep_data(out_chan_dep_data_16),
        .token_out_vec(token_out_vec_16),
        .dl_detect_out(dl_in_vec[16]));

    assign proc_16_data_FIFO_blk[0] = 1'b0;
    assign proc_16_data_PIPO_blk[0] = 1'b0;
    assign proc_16_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_13_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_13_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_13_U0_U.if_write);
    assign proc_16_TLF_FIFO_blk[0] = 1'b0;
    assign proc_16_input_sync_blk[0] = 1'b0;
    assign proc_16_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_16[0] = dl_detect_out ? proc_dep_vld_vec_16_reg[0] : (proc_16_data_FIFO_blk[0] | proc_16_data_PIPO_blk[0] | proc_16_start_FIFO_blk[0] | proc_16_TLF_FIFO_blk[0] | proc_16_input_sync_blk[0] | proc_16_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_16_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_16_reg <= proc_dep_vld_vec_16;
        end
    end
    assign in_chan_dep_vld_vec_16[0] = dep_chan_vld_11_16;
    assign in_chan_dep_data_vec_16[40 : 0] = dep_chan_data_11_16;
    assign token_in_vec_16[0] = token_11_16;
    assign in_chan_dep_vld_vec_16[1] = dep_chan_vld_20_16;
    assign in_chan_dep_data_vec_16[81 : 41] = dep_chan_data_20_16;
    assign token_in_vec_16[1] = token_20_16;
    assign dep_chan_vld_16_11 = out_chan_dep_vld_vec_16[0];
    assign dep_chan_data_16_11 = out_chan_dep_data_16;
    assign token_16_11 = token_out_vec_16[0];

    // Process: grp_col_pass_fu_1792.fft_core_14_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 17, 2, 1) wiener_stream_hls_deadlock_detect_unit_17 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_17),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_17),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_17),
        .token_in_vec(token_in_vec_17),
        .dl_detect_in(dl_detect_out),
        .origin(origin[17]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_17),
        .out_chan_dep_data(out_chan_dep_data_17),
        .token_out_vec(token_out_vec_17),
        .dl_detect_out(dl_in_vec[17]));

    assign proc_17_data_FIFO_blk[0] = 1'b0;
    assign proc_17_data_PIPO_blk[0] = 1'b0;
    assign proc_17_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_14_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_14_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_14_U0_U.if_write);
    assign proc_17_TLF_FIFO_blk[0] = 1'b0;
    assign proc_17_input_sync_blk[0] = 1'b0;
    assign proc_17_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_17[0] = dl_detect_out ? proc_dep_vld_vec_17_reg[0] : (proc_17_data_FIFO_blk[0] | proc_17_data_PIPO_blk[0] | proc_17_start_FIFO_blk[0] | proc_17_TLF_FIFO_blk[0] | proc_17_input_sync_blk[0] | proc_17_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_17_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_17_reg <= proc_dep_vld_vec_17;
        end
    end
    assign in_chan_dep_vld_vec_17[0] = dep_chan_vld_11_17;
    assign in_chan_dep_data_vec_17[40 : 0] = dep_chan_data_11_17;
    assign token_in_vec_17[0] = token_11_17;
    assign in_chan_dep_vld_vec_17[1] = dep_chan_vld_20_17;
    assign in_chan_dep_data_vec_17[81 : 41] = dep_chan_data_20_17;
    assign token_in_vec_17[1] = token_20_17;
    assign dep_chan_vld_17_11 = out_chan_dep_vld_vec_17[0];
    assign dep_chan_data_17_11 = out_chan_dep_data_17;
    assign token_17_11 = token_out_vec_17[0];

    // Process: grp_col_pass_fu_1792.fft_core_15_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 18, 2, 1) wiener_stream_hls_deadlock_detect_unit_18 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_18),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_18),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_18),
        .token_in_vec(token_in_vec_18),
        .dl_detect_in(dl_detect_out),
        .origin(origin[18]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_18),
        .out_chan_dep_data(out_chan_dep_data_18),
        .token_out_vec(token_out_vec_18),
        .dl_detect_out(dl_in_vec[18]));

    assign proc_18_data_FIFO_blk[0] = 1'b0;
    assign proc_18_data_PIPO_blk[0] = 1'b0;
    assign proc_18_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_15_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_15_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_15_U0_U.if_write);
    assign proc_18_TLF_FIFO_blk[0] = 1'b0;
    assign proc_18_input_sync_blk[0] = 1'b0;
    assign proc_18_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_18[0] = dl_detect_out ? proc_dep_vld_vec_18_reg[0] : (proc_18_data_FIFO_blk[0] | proc_18_data_PIPO_blk[0] | proc_18_start_FIFO_blk[0] | proc_18_TLF_FIFO_blk[0] | proc_18_input_sync_blk[0] | proc_18_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_18_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_18_reg <= proc_dep_vld_vec_18;
        end
    end
    assign in_chan_dep_vld_vec_18[0] = dep_chan_vld_11_18;
    assign in_chan_dep_data_vec_18[40 : 0] = dep_chan_data_11_18;
    assign token_in_vec_18[0] = token_11_18;
    assign in_chan_dep_vld_vec_18[1] = dep_chan_vld_20_18;
    assign in_chan_dep_data_vec_18[81 : 41] = dep_chan_data_20_18;
    assign token_in_vec_18[1] = token_20_18;
    assign dep_chan_vld_18_11 = out_chan_dep_vld_vec_18[0];
    assign dep_chan_data_18_11 = out_chan_dep_data_18;
    assign token_18_11 = token_out_vec_18[0];

    // Process: grp_col_pass_fu_1792.fft_core_16_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 19, 2, 1) wiener_stream_hls_deadlock_detect_unit_19 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_19),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_19),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_19),
        .token_in_vec(token_in_vec_19),
        .dl_detect_in(dl_detect_out),
        .origin(origin[19]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_19),
        .out_chan_dep_data(out_chan_dep_data_19),
        .token_out_vec(token_out_vec_19),
        .dl_detect_out(dl_in_vec[19]));

    assign proc_19_data_FIFO_blk[0] = 1'b0;
    assign proc_19_data_PIPO_blk[0] = 1'b0;
    assign proc_19_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_16_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_16_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_16_U0_U.if_write);
    assign proc_19_TLF_FIFO_blk[0] = 1'b0;
    assign proc_19_input_sync_blk[0] = 1'b0;
    assign proc_19_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_19[0] = dl_detect_out ? proc_dep_vld_vec_19_reg[0] : (proc_19_data_FIFO_blk[0] | proc_19_data_PIPO_blk[0] | proc_19_start_FIFO_blk[0] | proc_19_TLF_FIFO_blk[0] | proc_19_input_sync_blk[0] | proc_19_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_19_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_19_reg <= proc_dep_vld_vec_19;
        end
    end
    assign in_chan_dep_vld_vec_19[0] = dep_chan_vld_11_19;
    assign in_chan_dep_data_vec_19[40 : 0] = dep_chan_data_11_19;
    assign token_in_vec_19[0] = token_11_19;
    assign in_chan_dep_vld_vec_19[1] = dep_chan_vld_20_19;
    assign in_chan_dep_data_vec_19[81 : 41] = dep_chan_data_20_19;
    assign token_in_vec_19[1] = token_20_19;
    assign dep_chan_vld_19_11 = out_chan_dep_vld_vec_19[0];
    assign dep_chan_data_19_11 = out_chan_dep_data_19;
    assign token_19_11 = token_out_vec_19[0];

    // Process: grp_col_pass_fu_1792.apply_g_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 20, 9, 17) wiener_stream_hls_deadlock_detect_unit_20 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_20),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_20),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_20),
        .token_in_vec(token_in_vec_20),
        .dl_detect_in(dl_detect_out),
        .origin(origin[20]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_20),
        .out_chan_dep_data(out_chan_dep_data_20),
        .token_out_vec(token_out_vec_20),
        .dl_detect_out(dl_in_vec[20]));

    assign proc_20_data_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_0_blk_n);
    assign proc_20_data_PIPO_blk[0] = 1'b0;
    assign proc_20_start_FIFO_blk[0] = 1'b0;
    assign proc_20_TLF_FIFO_blk[0] = 1'b0;
    assign proc_20_input_sync_blk[0] = 1'b0;
    assign proc_20_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_20[0] = dl_detect_out ? proc_dep_vld_vec_20_reg[0] : (proc_20_data_FIFO_blk[0] | proc_20_data_PIPO_blk[0] | proc_20_start_FIFO_blk[0] | proc_20_TLF_FIFO_blk[0] | proc_20_input_sync_blk[0] | proc_20_output_sync_blk[0]);
    assign proc_20_data_FIFO_blk[1] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_1_blk_n);
    assign proc_20_data_PIPO_blk[1] = 1'b0;
    assign proc_20_start_FIFO_blk[1] = 1'b0;
    assign proc_20_TLF_FIFO_blk[1] = 1'b0;
    assign proc_20_input_sync_blk[1] = 1'b0;
    assign proc_20_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_20[1] = dl_detect_out ? proc_dep_vld_vec_20_reg[1] : (proc_20_data_FIFO_blk[1] | proc_20_data_PIPO_blk[1] | proc_20_start_FIFO_blk[1] | proc_20_TLF_FIFO_blk[1] | proc_20_input_sync_blk[1] | proc_20_output_sync_blk[1]);
    assign proc_20_data_FIFO_blk[2] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_2_blk_n);
    assign proc_20_data_PIPO_blk[2] = 1'b0;
    assign proc_20_start_FIFO_blk[2] = 1'b0;
    assign proc_20_TLF_FIFO_blk[2] = 1'b0;
    assign proc_20_input_sync_blk[2] = 1'b0;
    assign proc_20_output_sync_blk[2] = 1'b0;
    assign proc_dep_vld_vec_20[2] = dl_detect_out ? proc_dep_vld_vec_20_reg[2] : (proc_20_data_FIFO_blk[2] | proc_20_data_PIPO_blk[2] | proc_20_start_FIFO_blk[2] | proc_20_TLF_FIFO_blk[2] | proc_20_input_sync_blk[2] | proc_20_output_sync_blk[2]);
    assign proc_20_data_FIFO_blk[3] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_3_blk_n);
    assign proc_20_data_PIPO_blk[3] = 1'b0;
    assign proc_20_start_FIFO_blk[3] = 1'b0;
    assign proc_20_TLF_FIFO_blk[3] = 1'b0;
    assign proc_20_input_sync_blk[3] = 1'b0;
    assign proc_20_output_sync_blk[3] = 1'b0;
    assign proc_dep_vld_vec_20[3] = dl_detect_out ? proc_dep_vld_vec_20_reg[3] : (proc_20_data_FIFO_blk[3] | proc_20_data_PIPO_blk[3] | proc_20_start_FIFO_blk[3] | proc_20_TLF_FIFO_blk[3] | proc_20_input_sync_blk[3] | proc_20_output_sync_blk[3]);
    assign proc_20_data_FIFO_blk[4] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_4_blk_n);
    assign proc_20_data_PIPO_blk[4] = 1'b0;
    assign proc_20_start_FIFO_blk[4] = 1'b0;
    assign proc_20_TLF_FIFO_blk[4] = 1'b0;
    assign proc_20_input_sync_blk[4] = 1'b0;
    assign proc_20_output_sync_blk[4] = 1'b0;
    assign proc_dep_vld_vec_20[4] = dl_detect_out ? proc_dep_vld_vec_20_reg[4] : (proc_20_data_FIFO_blk[4] | proc_20_data_PIPO_blk[4] | proc_20_start_FIFO_blk[4] | proc_20_TLF_FIFO_blk[4] | proc_20_input_sync_blk[4] | proc_20_output_sync_blk[4]);
    assign proc_20_data_FIFO_blk[5] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_5_blk_n);
    assign proc_20_data_PIPO_blk[5] = 1'b0;
    assign proc_20_start_FIFO_blk[5] = 1'b0;
    assign proc_20_TLF_FIFO_blk[5] = 1'b0;
    assign proc_20_input_sync_blk[5] = 1'b0;
    assign proc_20_output_sync_blk[5] = 1'b0;
    assign proc_dep_vld_vec_20[5] = dl_detect_out ? proc_dep_vld_vec_20_reg[5] : (proc_20_data_FIFO_blk[5] | proc_20_data_PIPO_blk[5] | proc_20_start_FIFO_blk[5] | proc_20_TLF_FIFO_blk[5] | proc_20_input_sync_blk[5] | proc_20_output_sync_blk[5]);
    assign proc_20_data_FIFO_blk[6] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_6_blk_n);
    assign proc_20_data_PIPO_blk[6] = 1'b0;
    assign proc_20_start_FIFO_blk[6] = 1'b0;
    assign proc_20_TLF_FIFO_blk[6] = 1'b0;
    assign proc_20_input_sync_blk[6] = 1'b0;
    assign proc_20_output_sync_blk[6] = 1'b0;
    assign proc_dep_vld_vec_20[6] = dl_detect_out ? proc_dep_vld_vec_20_reg[6] : (proc_20_data_FIFO_blk[6] | proc_20_data_PIPO_blk[6] | proc_20_start_FIFO_blk[6] | proc_20_TLF_FIFO_blk[6] | proc_20_input_sync_blk[6] | proc_20_output_sync_blk[6]);
    assign proc_20_data_FIFO_blk[7] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_7_blk_n);
    assign proc_20_data_PIPO_blk[7] = 1'b0;
    assign proc_20_start_FIFO_blk[7] = 1'b0;
    assign proc_20_TLF_FIFO_blk[7] = 1'b0;
    assign proc_20_input_sync_blk[7] = 1'b0;
    assign proc_20_output_sync_blk[7] = 1'b0;
    assign proc_dep_vld_vec_20[7] = dl_detect_out ? proc_dep_vld_vec_20_reg[7] : (proc_20_data_FIFO_blk[7] | proc_20_data_PIPO_blk[7] | proc_20_start_FIFO_blk[7] | proc_20_TLF_FIFO_blk[7] | proc_20_input_sync_blk[7] | proc_20_output_sync_blk[7]);
    assign proc_20_data_FIFO_blk[8] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_0_blk_n);
    assign proc_20_data_PIPO_blk[8] = 1'b0;
    assign proc_20_start_FIFO_blk[8] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_17_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_17_U0_U.if_read);
    assign proc_20_TLF_FIFO_blk[8] = 1'b0;
    assign proc_20_input_sync_blk[8] = 1'b0;
    assign proc_20_output_sync_blk[8] = 1'b0;
    assign proc_dep_vld_vec_20[8] = dl_detect_out ? proc_dep_vld_vec_20_reg[8] : (proc_20_data_FIFO_blk[8] | proc_20_data_PIPO_blk[8] | proc_20_start_FIFO_blk[8] | proc_20_TLF_FIFO_blk[8] | proc_20_input_sync_blk[8] | proc_20_output_sync_blk[8]);
    assign proc_20_data_FIFO_blk[9] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_1_blk_n);
    assign proc_20_data_PIPO_blk[9] = 1'b0;
    assign proc_20_start_FIFO_blk[9] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_18_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_18_U0_U.if_read);
    assign proc_20_TLF_FIFO_blk[9] = 1'b0;
    assign proc_20_input_sync_blk[9] = 1'b0;
    assign proc_20_output_sync_blk[9] = 1'b0;
    assign proc_dep_vld_vec_20[9] = dl_detect_out ? proc_dep_vld_vec_20_reg[9] : (proc_20_data_FIFO_blk[9] | proc_20_data_PIPO_blk[9] | proc_20_start_FIFO_blk[9] | proc_20_TLF_FIFO_blk[9] | proc_20_input_sync_blk[9] | proc_20_output_sync_blk[9]);
    assign proc_20_data_FIFO_blk[10] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_2_blk_n);
    assign proc_20_data_PIPO_blk[10] = 1'b0;
    assign proc_20_start_FIFO_blk[10] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_19_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_19_U0_U.if_read);
    assign proc_20_TLF_FIFO_blk[10] = 1'b0;
    assign proc_20_input_sync_blk[10] = 1'b0;
    assign proc_20_output_sync_blk[10] = 1'b0;
    assign proc_dep_vld_vec_20[10] = dl_detect_out ? proc_dep_vld_vec_20_reg[10] : (proc_20_data_FIFO_blk[10] | proc_20_data_PIPO_blk[10] | proc_20_start_FIFO_blk[10] | proc_20_TLF_FIFO_blk[10] | proc_20_input_sync_blk[10] | proc_20_output_sync_blk[10]);
    assign proc_20_data_FIFO_blk[11] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_3_blk_n);
    assign proc_20_data_PIPO_blk[11] = 1'b0;
    assign proc_20_start_FIFO_blk[11] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_20_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_20_U0_U.if_read);
    assign proc_20_TLF_FIFO_blk[11] = 1'b0;
    assign proc_20_input_sync_blk[11] = 1'b0;
    assign proc_20_output_sync_blk[11] = 1'b0;
    assign proc_dep_vld_vec_20[11] = dl_detect_out ? proc_dep_vld_vec_20_reg[11] : (proc_20_data_FIFO_blk[11] | proc_20_data_PIPO_blk[11] | proc_20_start_FIFO_blk[11] | proc_20_TLF_FIFO_blk[11] | proc_20_input_sync_blk[11] | proc_20_output_sync_blk[11]);
    assign proc_20_data_FIFO_blk[12] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_4_blk_n);
    assign proc_20_data_PIPO_blk[12] = 1'b0;
    assign proc_20_start_FIFO_blk[12] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_21_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_21_U0_U.if_read);
    assign proc_20_TLF_FIFO_blk[12] = 1'b0;
    assign proc_20_input_sync_blk[12] = 1'b0;
    assign proc_20_output_sync_blk[12] = 1'b0;
    assign proc_dep_vld_vec_20[12] = dl_detect_out ? proc_dep_vld_vec_20_reg[12] : (proc_20_data_FIFO_blk[12] | proc_20_data_PIPO_blk[12] | proc_20_start_FIFO_blk[12] | proc_20_TLF_FIFO_blk[12] | proc_20_input_sync_blk[12] | proc_20_output_sync_blk[12]);
    assign proc_20_data_FIFO_blk[13] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_5_blk_n);
    assign proc_20_data_PIPO_blk[13] = 1'b0;
    assign proc_20_start_FIFO_blk[13] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_22_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_22_U0_U.if_read);
    assign proc_20_TLF_FIFO_blk[13] = 1'b0;
    assign proc_20_input_sync_blk[13] = 1'b0;
    assign proc_20_output_sync_blk[13] = 1'b0;
    assign proc_dep_vld_vec_20[13] = dl_detect_out ? proc_dep_vld_vec_20_reg[13] : (proc_20_data_FIFO_blk[13] | proc_20_data_PIPO_blk[13] | proc_20_start_FIFO_blk[13] | proc_20_TLF_FIFO_blk[13] | proc_20_input_sync_blk[13] | proc_20_output_sync_blk[13]);
    assign proc_20_data_FIFO_blk[14] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_6_blk_n);
    assign proc_20_data_PIPO_blk[14] = 1'b0;
    assign proc_20_start_FIFO_blk[14] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_23_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_23_U0_U.if_read);
    assign proc_20_TLF_FIFO_blk[14] = 1'b0;
    assign proc_20_input_sync_blk[14] = 1'b0;
    assign proc_20_output_sync_blk[14] = 1'b0;
    assign proc_dep_vld_vec_20[14] = dl_detect_out ? proc_dep_vld_vec_20_reg[14] : (proc_20_data_FIFO_blk[14] | proc_20_data_PIPO_blk[14] | proc_20_start_FIFO_blk[14] | proc_20_TLF_FIFO_blk[14] | proc_20_input_sync_blk[14] | proc_20_output_sync_blk[14]);
    assign proc_20_data_FIFO_blk[15] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_7_blk_n);
    assign proc_20_data_PIPO_blk[15] = 1'b0;
    assign proc_20_start_FIFO_blk[15] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_24_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_24_U0_U.if_read);
    assign proc_20_TLF_FIFO_blk[15] = 1'b0;
    assign proc_20_input_sync_blk[15] = 1'b0;
    assign proc_20_output_sync_blk[15] = 1'b0;
    assign proc_dep_vld_vec_20[15] = dl_detect_out ? proc_dep_vld_vec_20_reg[15] : (proc_20_data_FIFO_blk[15] | proc_20_data_PIPO_blk[15] | proc_20_start_FIFO_blk[15] | proc_20_TLF_FIFO_blk[15] | proc_20_input_sync_blk[15] | proc_20_output_sync_blk[15]);
    assign proc_20_data_FIFO_blk[16] = 1'b0 | (~grp_col_pass_fu_1792.apply_g_U0.Ln_blk_n) | (~grp_col_pass_fu_1792.apply_g_U0.ct_blk_n) | (~grp_col_pass_fu_1792.apply_g_U0.st_blk_n);
    assign proc_20_data_PIPO_blk[16] = 1'b0;
    assign proc_20_start_FIFO_blk[16] = 1'b0 | (~grp_col_pass_fu_1792.start_for_apply_g_U0_U.if_empty_n & grp_col_pass_fu_1792.apply_g_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_apply_g_U0_U.if_write);
    assign proc_20_TLF_FIFO_blk[16] = 1'b0;
    assign proc_20_input_sync_blk[16] = 1'b0;
    assign proc_20_output_sync_blk[16] = 1'b0;
    assign proc_dep_vld_vec_20[16] = dl_detect_out ? proc_dep_vld_vec_20_reg[16] : (proc_20_data_FIFO_blk[16] | proc_20_data_PIPO_blk[16] | proc_20_start_FIFO_blk[16] | proc_20_TLF_FIFO_blk[16] | proc_20_input_sync_blk[16] | proc_20_output_sync_blk[16]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_20_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_20_reg <= proc_dep_vld_vec_20;
        end
    end
    assign in_chan_dep_vld_vec_20[0] = dep_chan_vld_10_20;
    assign in_chan_dep_data_vec_20[40 : 0] = dep_chan_data_10_20;
    assign token_in_vec_20[0] = token_10_20;
    assign in_chan_dep_vld_vec_20[1] = dep_chan_vld_21_20;
    assign in_chan_dep_data_vec_20[81 : 41] = dep_chan_data_21_20;
    assign token_in_vec_20[1] = token_21_20;
    assign in_chan_dep_vld_vec_20[2] = dep_chan_vld_22_20;
    assign in_chan_dep_data_vec_20[122 : 82] = dep_chan_data_22_20;
    assign token_in_vec_20[2] = token_22_20;
    assign in_chan_dep_vld_vec_20[3] = dep_chan_vld_23_20;
    assign in_chan_dep_data_vec_20[163 : 123] = dep_chan_data_23_20;
    assign token_in_vec_20[3] = token_23_20;
    assign in_chan_dep_vld_vec_20[4] = dep_chan_vld_24_20;
    assign in_chan_dep_data_vec_20[204 : 164] = dep_chan_data_24_20;
    assign token_in_vec_20[4] = token_24_20;
    assign in_chan_dep_vld_vec_20[5] = dep_chan_vld_25_20;
    assign in_chan_dep_data_vec_20[245 : 205] = dep_chan_data_25_20;
    assign token_in_vec_20[5] = token_25_20;
    assign in_chan_dep_vld_vec_20[6] = dep_chan_vld_26_20;
    assign in_chan_dep_data_vec_20[286 : 246] = dep_chan_data_26_20;
    assign token_in_vec_20[6] = token_26_20;
    assign in_chan_dep_vld_vec_20[7] = dep_chan_vld_27_20;
    assign in_chan_dep_data_vec_20[327 : 287] = dep_chan_data_27_20;
    assign token_in_vec_20[7] = token_27_20;
    assign in_chan_dep_vld_vec_20[8] = dep_chan_vld_28_20;
    assign in_chan_dep_data_vec_20[368 : 328] = dep_chan_data_28_20;
    assign token_in_vec_20[8] = token_28_20;
    assign dep_chan_vld_20_12 = out_chan_dep_vld_vec_20[0];
    assign dep_chan_data_20_12 = out_chan_dep_data_20;
    assign token_20_12 = token_out_vec_20[0];
    assign dep_chan_vld_20_13 = out_chan_dep_vld_vec_20[1];
    assign dep_chan_data_20_13 = out_chan_dep_data_20;
    assign token_20_13 = token_out_vec_20[1];
    assign dep_chan_vld_20_14 = out_chan_dep_vld_vec_20[2];
    assign dep_chan_data_20_14 = out_chan_dep_data_20;
    assign token_20_14 = token_out_vec_20[2];
    assign dep_chan_vld_20_15 = out_chan_dep_vld_vec_20[3];
    assign dep_chan_data_20_15 = out_chan_dep_data_20;
    assign token_20_15 = token_out_vec_20[3];
    assign dep_chan_vld_20_16 = out_chan_dep_vld_vec_20[4];
    assign dep_chan_data_20_16 = out_chan_dep_data_20;
    assign token_20_16 = token_out_vec_20[4];
    assign dep_chan_vld_20_17 = out_chan_dep_vld_vec_20[5];
    assign dep_chan_data_20_17 = out_chan_dep_data_20;
    assign token_20_17 = token_out_vec_20[5];
    assign dep_chan_vld_20_18 = out_chan_dep_vld_vec_20[6];
    assign dep_chan_data_20_18 = out_chan_dep_data_20;
    assign token_20_18 = token_out_vec_20[6];
    assign dep_chan_vld_20_19 = out_chan_dep_vld_vec_20[7];
    assign dep_chan_data_20_19 = out_chan_dep_data_20;
    assign token_20_19 = token_out_vec_20[7];
    assign dep_chan_vld_20_21 = out_chan_dep_vld_vec_20[8];
    assign dep_chan_data_20_21 = out_chan_dep_data_20;
    assign token_20_21 = token_out_vec_20[8];
    assign dep_chan_vld_20_22 = out_chan_dep_vld_vec_20[9];
    assign dep_chan_data_20_22 = out_chan_dep_data_20;
    assign token_20_22 = token_out_vec_20[9];
    assign dep_chan_vld_20_23 = out_chan_dep_vld_vec_20[10];
    assign dep_chan_data_20_23 = out_chan_dep_data_20;
    assign token_20_23 = token_out_vec_20[10];
    assign dep_chan_vld_20_24 = out_chan_dep_vld_vec_20[11];
    assign dep_chan_data_20_24 = out_chan_dep_data_20;
    assign token_20_24 = token_out_vec_20[11];
    assign dep_chan_vld_20_25 = out_chan_dep_vld_vec_20[12];
    assign dep_chan_data_20_25 = out_chan_dep_data_20;
    assign token_20_25 = token_out_vec_20[12];
    assign dep_chan_vld_20_26 = out_chan_dep_vld_vec_20[13];
    assign dep_chan_data_20_26 = out_chan_dep_data_20;
    assign token_20_26 = token_out_vec_20[13];
    assign dep_chan_vld_20_27 = out_chan_dep_vld_vec_20[14];
    assign dep_chan_data_20_27 = out_chan_dep_data_20;
    assign token_20_27 = token_out_vec_20[14];
    assign dep_chan_vld_20_28 = out_chan_dep_vld_vec_20[15];
    assign dep_chan_data_20_28 = out_chan_dep_data_20;
    assign token_20_28 = token_out_vec_20[15];
    assign dep_chan_vld_20_10 = out_chan_dep_vld_vec_20[16];
    assign dep_chan_data_20_10 = out_chan_dep_data_20;
    assign token_20_10 = token_out_vec_20[16];

    // Process: grp_col_pass_fu_1792.fft_core_17_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 21, 2, 2) wiener_stream_hls_deadlock_detect_unit_21 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_21),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_21),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_21),
        .token_in_vec(token_in_vec_21),
        .dl_detect_in(dl_detect_out),
        .origin(origin[21]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_21),
        .out_chan_dep_data(out_chan_dep_data_21),
        .token_out_vec(token_out_vec_21),
        .dl_detect_out(dl_in_vec[21]));

    assign proc_21_data_FIFO_blk[0] = 1'b0;
    assign proc_21_data_PIPO_blk[0] = 1'b0;
    assign proc_21_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_17_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_17_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_17_U0_U.if_write);
    assign proc_21_TLF_FIFO_blk[0] = 1'b0;
    assign proc_21_input_sync_blk[0] = 1'b0;
    assign proc_21_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_21[0] = dl_detect_out ? proc_dep_vld_vec_21_reg[0] : (proc_21_data_FIFO_blk[0] | proc_21_data_PIPO_blk[0] | proc_21_start_FIFO_blk[0] | proc_21_TLF_FIFO_blk[0] | proc_21_input_sync_blk[0] | proc_21_output_sync_blk[0]);
    assign proc_21_data_FIFO_blk[1] = 1'b0;
    assign proc_21_data_PIPO_blk[1] = 1'b0;
    assign proc_21_start_FIFO_blk[1] = 1'b0 | (~grp_col_pass_fu_1792.start_for_store_cols_U0_U.if_full_n & grp_col_pass_fu_1792.fft_core_17_U0.ap_start & ~grp_col_pass_fu_1792.fft_core_17_U0.real_start & (trans_in_cnt_5 == trans_out_cnt_5) & ~grp_col_pass_fu_1792.start_for_store_cols_U0_U.if_read);
    assign proc_21_TLF_FIFO_blk[1] = 1'b0;
    assign proc_21_input_sync_blk[1] = 1'b0;
    assign proc_21_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_21[1] = dl_detect_out ? proc_dep_vld_vec_21_reg[1] : (proc_21_data_FIFO_blk[1] | proc_21_data_PIPO_blk[1] | proc_21_start_FIFO_blk[1] | proc_21_TLF_FIFO_blk[1] | proc_21_input_sync_blk[1] | proc_21_output_sync_blk[1]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_21_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_21_reg <= proc_dep_vld_vec_21;
        end
    end
    assign in_chan_dep_vld_vec_21[0] = dep_chan_vld_20_21;
    assign in_chan_dep_data_vec_21[40 : 0] = dep_chan_data_20_21;
    assign token_in_vec_21[0] = token_20_21;
    assign in_chan_dep_vld_vec_21[1] = dep_chan_vld_29_21;
    assign in_chan_dep_data_vec_21[81 : 41] = dep_chan_data_29_21;
    assign token_in_vec_21[1] = token_29_21;
    assign dep_chan_vld_21_20 = out_chan_dep_vld_vec_21[0];
    assign dep_chan_data_21_20 = out_chan_dep_data_21;
    assign token_21_20 = token_out_vec_21[0];
    assign dep_chan_vld_21_29 = out_chan_dep_vld_vec_21[1];
    assign dep_chan_data_21_29 = out_chan_dep_data_21;
    assign token_21_29 = token_out_vec_21[1];

    // Process: grp_col_pass_fu_1792.fft_core_18_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 22, 2, 1) wiener_stream_hls_deadlock_detect_unit_22 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_22),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_22),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_22),
        .token_in_vec(token_in_vec_22),
        .dl_detect_in(dl_detect_out),
        .origin(origin[22]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_22),
        .out_chan_dep_data(out_chan_dep_data_22),
        .token_out_vec(token_out_vec_22),
        .dl_detect_out(dl_in_vec[22]));

    assign proc_22_data_FIFO_blk[0] = 1'b0;
    assign proc_22_data_PIPO_blk[0] = 1'b0;
    assign proc_22_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_18_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_18_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_18_U0_U.if_write);
    assign proc_22_TLF_FIFO_blk[0] = 1'b0;
    assign proc_22_input_sync_blk[0] = 1'b0;
    assign proc_22_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_22[0] = dl_detect_out ? proc_dep_vld_vec_22_reg[0] : (proc_22_data_FIFO_blk[0] | proc_22_data_PIPO_blk[0] | proc_22_start_FIFO_blk[0] | proc_22_TLF_FIFO_blk[0] | proc_22_input_sync_blk[0] | proc_22_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_22_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_22_reg <= proc_dep_vld_vec_22;
        end
    end
    assign in_chan_dep_vld_vec_22[0] = dep_chan_vld_20_22;
    assign in_chan_dep_data_vec_22[40 : 0] = dep_chan_data_20_22;
    assign token_in_vec_22[0] = token_20_22;
    assign in_chan_dep_vld_vec_22[1] = dep_chan_vld_29_22;
    assign in_chan_dep_data_vec_22[81 : 41] = dep_chan_data_29_22;
    assign token_in_vec_22[1] = token_29_22;
    assign dep_chan_vld_22_20 = out_chan_dep_vld_vec_22[0];
    assign dep_chan_data_22_20 = out_chan_dep_data_22;
    assign token_22_20 = token_out_vec_22[0];

    // Process: grp_col_pass_fu_1792.fft_core_19_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 23, 2, 1) wiener_stream_hls_deadlock_detect_unit_23 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_23),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_23),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_23),
        .token_in_vec(token_in_vec_23),
        .dl_detect_in(dl_detect_out),
        .origin(origin[23]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_23),
        .out_chan_dep_data(out_chan_dep_data_23),
        .token_out_vec(token_out_vec_23),
        .dl_detect_out(dl_in_vec[23]));

    assign proc_23_data_FIFO_blk[0] = 1'b0;
    assign proc_23_data_PIPO_blk[0] = 1'b0;
    assign proc_23_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_19_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_19_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_19_U0_U.if_write);
    assign proc_23_TLF_FIFO_blk[0] = 1'b0;
    assign proc_23_input_sync_blk[0] = 1'b0;
    assign proc_23_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_23[0] = dl_detect_out ? proc_dep_vld_vec_23_reg[0] : (proc_23_data_FIFO_blk[0] | proc_23_data_PIPO_blk[0] | proc_23_start_FIFO_blk[0] | proc_23_TLF_FIFO_blk[0] | proc_23_input_sync_blk[0] | proc_23_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_23_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_23_reg <= proc_dep_vld_vec_23;
        end
    end
    assign in_chan_dep_vld_vec_23[0] = dep_chan_vld_20_23;
    assign in_chan_dep_data_vec_23[40 : 0] = dep_chan_data_20_23;
    assign token_in_vec_23[0] = token_20_23;
    assign in_chan_dep_vld_vec_23[1] = dep_chan_vld_29_23;
    assign in_chan_dep_data_vec_23[81 : 41] = dep_chan_data_29_23;
    assign token_in_vec_23[1] = token_29_23;
    assign dep_chan_vld_23_20 = out_chan_dep_vld_vec_23[0];
    assign dep_chan_data_23_20 = out_chan_dep_data_23;
    assign token_23_20 = token_out_vec_23[0];

    // Process: grp_col_pass_fu_1792.fft_core_20_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 24, 2, 1) wiener_stream_hls_deadlock_detect_unit_24 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_24),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_24),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_24),
        .token_in_vec(token_in_vec_24),
        .dl_detect_in(dl_detect_out),
        .origin(origin[24]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_24),
        .out_chan_dep_data(out_chan_dep_data_24),
        .token_out_vec(token_out_vec_24),
        .dl_detect_out(dl_in_vec[24]));

    assign proc_24_data_FIFO_blk[0] = 1'b0;
    assign proc_24_data_PIPO_blk[0] = 1'b0;
    assign proc_24_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_20_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_20_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_20_U0_U.if_write);
    assign proc_24_TLF_FIFO_blk[0] = 1'b0;
    assign proc_24_input_sync_blk[0] = 1'b0;
    assign proc_24_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_24[0] = dl_detect_out ? proc_dep_vld_vec_24_reg[0] : (proc_24_data_FIFO_blk[0] | proc_24_data_PIPO_blk[0] | proc_24_start_FIFO_blk[0] | proc_24_TLF_FIFO_blk[0] | proc_24_input_sync_blk[0] | proc_24_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_24_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_24_reg <= proc_dep_vld_vec_24;
        end
    end
    assign in_chan_dep_vld_vec_24[0] = dep_chan_vld_20_24;
    assign in_chan_dep_data_vec_24[40 : 0] = dep_chan_data_20_24;
    assign token_in_vec_24[0] = token_20_24;
    assign in_chan_dep_vld_vec_24[1] = dep_chan_vld_29_24;
    assign in_chan_dep_data_vec_24[81 : 41] = dep_chan_data_29_24;
    assign token_in_vec_24[1] = token_29_24;
    assign dep_chan_vld_24_20 = out_chan_dep_vld_vec_24[0];
    assign dep_chan_data_24_20 = out_chan_dep_data_24;
    assign token_24_20 = token_out_vec_24[0];

    // Process: grp_col_pass_fu_1792.fft_core_21_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 25, 2, 1) wiener_stream_hls_deadlock_detect_unit_25 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_25),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_25),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_25),
        .token_in_vec(token_in_vec_25),
        .dl_detect_in(dl_detect_out),
        .origin(origin[25]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_25),
        .out_chan_dep_data(out_chan_dep_data_25),
        .token_out_vec(token_out_vec_25),
        .dl_detect_out(dl_in_vec[25]));

    assign proc_25_data_FIFO_blk[0] = 1'b0;
    assign proc_25_data_PIPO_blk[0] = 1'b0;
    assign proc_25_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_21_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_21_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_21_U0_U.if_write);
    assign proc_25_TLF_FIFO_blk[0] = 1'b0;
    assign proc_25_input_sync_blk[0] = 1'b0;
    assign proc_25_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_25[0] = dl_detect_out ? proc_dep_vld_vec_25_reg[0] : (proc_25_data_FIFO_blk[0] | proc_25_data_PIPO_blk[0] | proc_25_start_FIFO_blk[0] | proc_25_TLF_FIFO_blk[0] | proc_25_input_sync_blk[0] | proc_25_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_25_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_25_reg <= proc_dep_vld_vec_25;
        end
    end
    assign in_chan_dep_vld_vec_25[0] = dep_chan_vld_20_25;
    assign in_chan_dep_data_vec_25[40 : 0] = dep_chan_data_20_25;
    assign token_in_vec_25[0] = token_20_25;
    assign in_chan_dep_vld_vec_25[1] = dep_chan_vld_29_25;
    assign in_chan_dep_data_vec_25[81 : 41] = dep_chan_data_29_25;
    assign token_in_vec_25[1] = token_29_25;
    assign dep_chan_vld_25_20 = out_chan_dep_vld_vec_25[0];
    assign dep_chan_data_25_20 = out_chan_dep_data_25;
    assign token_25_20 = token_out_vec_25[0];

    // Process: grp_col_pass_fu_1792.fft_core_22_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 26, 2, 1) wiener_stream_hls_deadlock_detect_unit_26 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_26),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_26),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_26),
        .token_in_vec(token_in_vec_26),
        .dl_detect_in(dl_detect_out),
        .origin(origin[26]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_26),
        .out_chan_dep_data(out_chan_dep_data_26),
        .token_out_vec(token_out_vec_26),
        .dl_detect_out(dl_in_vec[26]));

    assign proc_26_data_FIFO_blk[0] = 1'b0;
    assign proc_26_data_PIPO_blk[0] = 1'b0;
    assign proc_26_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_22_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_22_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_22_U0_U.if_write);
    assign proc_26_TLF_FIFO_blk[0] = 1'b0;
    assign proc_26_input_sync_blk[0] = 1'b0;
    assign proc_26_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_26[0] = dl_detect_out ? proc_dep_vld_vec_26_reg[0] : (proc_26_data_FIFO_blk[0] | proc_26_data_PIPO_blk[0] | proc_26_start_FIFO_blk[0] | proc_26_TLF_FIFO_blk[0] | proc_26_input_sync_blk[0] | proc_26_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_26_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_26_reg <= proc_dep_vld_vec_26;
        end
    end
    assign in_chan_dep_vld_vec_26[0] = dep_chan_vld_20_26;
    assign in_chan_dep_data_vec_26[40 : 0] = dep_chan_data_20_26;
    assign token_in_vec_26[0] = token_20_26;
    assign in_chan_dep_vld_vec_26[1] = dep_chan_vld_29_26;
    assign in_chan_dep_data_vec_26[81 : 41] = dep_chan_data_29_26;
    assign token_in_vec_26[1] = token_29_26;
    assign dep_chan_vld_26_20 = out_chan_dep_vld_vec_26[0];
    assign dep_chan_data_26_20 = out_chan_dep_data_26;
    assign token_26_20 = token_out_vec_26[0];

    // Process: grp_col_pass_fu_1792.fft_core_23_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 27, 2, 1) wiener_stream_hls_deadlock_detect_unit_27 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_27),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_27),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_27),
        .token_in_vec(token_in_vec_27),
        .dl_detect_in(dl_detect_out),
        .origin(origin[27]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_27),
        .out_chan_dep_data(out_chan_dep_data_27),
        .token_out_vec(token_out_vec_27),
        .dl_detect_out(dl_in_vec[27]));

    assign proc_27_data_FIFO_blk[0] = 1'b0;
    assign proc_27_data_PIPO_blk[0] = 1'b0;
    assign proc_27_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_23_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_23_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_23_U0_U.if_write);
    assign proc_27_TLF_FIFO_blk[0] = 1'b0;
    assign proc_27_input_sync_blk[0] = 1'b0;
    assign proc_27_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_27[0] = dl_detect_out ? proc_dep_vld_vec_27_reg[0] : (proc_27_data_FIFO_blk[0] | proc_27_data_PIPO_blk[0] | proc_27_start_FIFO_blk[0] | proc_27_TLF_FIFO_blk[0] | proc_27_input_sync_blk[0] | proc_27_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_27_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_27_reg <= proc_dep_vld_vec_27;
        end
    end
    assign in_chan_dep_vld_vec_27[0] = dep_chan_vld_20_27;
    assign in_chan_dep_data_vec_27[40 : 0] = dep_chan_data_20_27;
    assign token_in_vec_27[0] = token_20_27;
    assign in_chan_dep_vld_vec_27[1] = dep_chan_vld_29_27;
    assign in_chan_dep_data_vec_27[81 : 41] = dep_chan_data_29_27;
    assign token_in_vec_27[1] = token_29_27;
    assign dep_chan_vld_27_20 = out_chan_dep_vld_vec_27[0];
    assign dep_chan_data_27_20 = out_chan_dep_data_27;
    assign token_27_20 = token_out_vec_27[0];

    // Process: grp_col_pass_fu_1792.fft_core_24_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 28, 2, 1) wiener_stream_hls_deadlock_detect_unit_28 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_28),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_28),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_28),
        .token_in_vec(token_in_vec_28),
        .dl_detect_in(dl_detect_out),
        .origin(origin[28]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_28),
        .out_chan_dep_data(out_chan_dep_data_28),
        .token_out_vec(token_out_vec_28),
        .dl_detect_out(dl_in_vec[28]));

    assign proc_28_data_FIFO_blk[0] = 1'b0;
    assign proc_28_data_PIPO_blk[0] = 1'b0;
    assign proc_28_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_fft_core_24_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_24_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_24_U0_U.if_write);
    assign proc_28_TLF_FIFO_blk[0] = 1'b0;
    assign proc_28_input_sync_blk[0] = 1'b0;
    assign proc_28_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_28[0] = dl_detect_out ? proc_dep_vld_vec_28_reg[0] : (proc_28_data_FIFO_blk[0] | proc_28_data_PIPO_blk[0] | proc_28_start_FIFO_blk[0] | proc_28_TLF_FIFO_blk[0] | proc_28_input_sync_blk[0] | proc_28_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_28_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_28_reg <= proc_dep_vld_vec_28;
        end
    end
    assign in_chan_dep_vld_vec_28[0] = dep_chan_vld_20_28;
    assign in_chan_dep_data_vec_28[40 : 0] = dep_chan_data_20_28;
    assign token_in_vec_28[0] = token_20_28;
    assign in_chan_dep_vld_vec_28[1] = dep_chan_vld_29_28;
    assign in_chan_dep_data_vec_28[81 : 41] = dep_chan_data_29_28;
    assign token_in_vec_28[1] = token_29_28;
    assign dep_chan_vld_28_20 = out_chan_dep_vld_vec_28[0];
    assign dep_chan_data_28_20 = out_chan_dep_data_28;
    assign token_28_20 = token_out_vec_28[0];

    // Process: grp_col_pass_fu_1792.store_cols_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 29, 1, 8) wiener_stream_hls_deadlock_detect_unit_29 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_29),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_29),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_29),
        .token_in_vec(token_in_vec_29),
        .dl_detect_in(dl_detect_out),
        .origin(origin[29]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_29),
        .out_chan_dep_data(out_chan_dep_data_29),
        .token_out_vec(token_out_vec_29),
        .dl_detect_out(dl_in_vec[29]));

    assign proc_29_data_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.store_cols_U0.cout_i_0_blk_n);
    assign proc_29_data_PIPO_blk[0] = 1'b0;
    assign proc_29_start_FIFO_blk[0] = 1'b0 | (~grp_col_pass_fu_1792.start_for_store_cols_U0_U.if_empty_n & grp_col_pass_fu_1792.store_cols_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_store_cols_U0_U.if_write);
    assign proc_29_TLF_FIFO_blk[0] = 1'b0;
    assign proc_29_input_sync_blk[0] = 1'b0;
    assign proc_29_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_29[0] = dl_detect_out ? proc_dep_vld_vec_29_reg[0] : (proc_29_data_FIFO_blk[0] | proc_29_data_PIPO_blk[0] | proc_29_start_FIFO_blk[0] | proc_29_TLF_FIFO_blk[0] | proc_29_input_sync_blk[0] | proc_29_output_sync_blk[0]);
    assign proc_29_data_FIFO_blk[1] = 1'b0 | (~grp_col_pass_fu_1792.store_cols_U0.cout_i_1_blk_n);
    assign proc_29_data_PIPO_blk[1] = 1'b0;
    assign proc_29_start_FIFO_blk[1] = 1'b0;
    assign proc_29_TLF_FIFO_blk[1] = 1'b0;
    assign proc_29_input_sync_blk[1] = 1'b0;
    assign proc_29_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_29[1] = dl_detect_out ? proc_dep_vld_vec_29_reg[1] : (proc_29_data_FIFO_blk[1] | proc_29_data_PIPO_blk[1] | proc_29_start_FIFO_blk[1] | proc_29_TLF_FIFO_blk[1] | proc_29_input_sync_blk[1] | proc_29_output_sync_blk[1]);
    assign proc_29_data_FIFO_blk[2] = 1'b0 | (~grp_col_pass_fu_1792.store_cols_U0.cout_i_2_blk_n);
    assign proc_29_data_PIPO_blk[2] = 1'b0;
    assign proc_29_start_FIFO_blk[2] = 1'b0;
    assign proc_29_TLF_FIFO_blk[2] = 1'b0;
    assign proc_29_input_sync_blk[2] = 1'b0;
    assign proc_29_output_sync_blk[2] = 1'b0;
    assign proc_dep_vld_vec_29[2] = dl_detect_out ? proc_dep_vld_vec_29_reg[2] : (proc_29_data_FIFO_blk[2] | proc_29_data_PIPO_blk[2] | proc_29_start_FIFO_blk[2] | proc_29_TLF_FIFO_blk[2] | proc_29_input_sync_blk[2] | proc_29_output_sync_blk[2]);
    assign proc_29_data_FIFO_blk[3] = 1'b0 | (~grp_col_pass_fu_1792.store_cols_U0.cout_i_3_blk_n);
    assign proc_29_data_PIPO_blk[3] = 1'b0;
    assign proc_29_start_FIFO_blk[3] = 1'b0;
    assign proc_29_TLF_FIFO_blk[3] = 1'b0;
    assign proc_29_input_sync_blk[3] = 1'b0;
    assign proc_29_output_sync_blk[3] = 1'b0;
    assign proc_dep_vld_vec_29[3] = dl_detect_out ? proc_dep_vld_vec_29_reg[3] : (proc_29_data_FIFO_blk[3] | proc_29_data_PIPO_blk[3] | proc_29_start_FIFO_blk[3] | proc_29_TLF_FIFO_blk[3] | proc_29_input_sync_blk[3] | proc_29_output_sync_blk[3]);
    assign proc_29_data_FIFO_blk[4] = 1'b0 | (~grp_col_pass_fu_1792.store_cols_U0.cout_i_4_blk_n);
    assign proc_29_data_PIPO_blk[4] = 1'b0;
    assign proc_29_start_FIFO_blk[4] = 1'b0;
    assign proc_29_TLF_FIFO_blk[4] = 1'b0;
    assign proc_29_input_sync_blk[4] = 1'b0;
    assign proc_29_output_sync_blk[4] = 1'b0;
    assign proc_dep_vld_vec_29[4] = dl_detect_out ? proc_dep_vld_vec_29_reg[4] : (proc_29_data_FIFO_blk[4] | proc_29_data_PIPO_blk[4] | proc_29_start_FIFO_blk[4] | proc_29_TLF_FIFO_blk[4] | proc_29_input_sync_blk[4] | proc_29_output_sync_blk[4]);
    assign proc_29_data_FIFO_blk[5] = 1'b0 | (~grp_col_pass_fu_1792.store_cols_U0.cout_i_5_blk_n);
    assign proc_29_data_PIPO_blk[5] = 1'b0;
    assign proc_29_start_FIFO_blk[5] = 1'b0;
    assign proc_29_TLF_FIFO_blk[5] = 1'b0;
    assign proc_29_input_sync_blk[5] = 1'b0;
    assign proc_29_output_sync_blk[5] = 1'b0;
    assign proc_dep_vld_vec_29[5] = dl_detect_out ? proc_dep_vld_vec_29_reg[5] : (proc_29_data_FIFO_blk[5] | proc_29_data_PIPO_blk[5] | proc_29_start_FIFO_blk[5] | proc_29_TLF_FIFO_blk[5] | proc_29_input_sync_blk[5] | proc_29_output_sync_blk[5]);
    assign proc_29_data_FIFO_blk[6] = 1'b0 | (~grp_col_pass_fu_1792.store_cols_U0.cout_i_6_blk_n);
    assign proc_29_data_PIPO_blk[6] = 1'b0;
    assign proc_29_start_FIFO_blk[6] = 1'b0;
    assign proc_29_TLF_FIFO_blk[6] = 1'b0;
    assign proc_29_input_sync_blk[6] = 1'b0;
    assign proc_29_output_sync_blk[6] = 1'b0;
    assign proc_dep_vld_vec_29[6] = dl_detect_out ? proc_dep_vld_vec_29_reg[6] : (proc_29_data_FIFO_blk[6] | proc_29_data_PIPO_blk[6] | proc_29_start_FIFO_blk[6] | proc_29_TLF_FIFO_blk[6] | proc_29_input_sync_blk[6] | proc_29_output_sync_blk[6]);
    assign proc_29_data_FIFO_blk[7] = 1'b0 | (~grp_col_pass_fu_1792.store_cols_U0.cout_i_7_blk_n);
    assign proc_29_data_PIPO_blk[7] = 1'b0;
    assign proc_29_start_FIFO_blk[7] = 1'b0;
    assign proc_29_TLF_FIFO_blk[7] = 1'b0;
    assign proc_29_input_sync_blk[7] = 1'b0;
    assign proc_29_output_sync_blk[7] = 1'b0;
    assign proc_dep_vld_vec_29[7] = dl_detect_out ? proc_dep_vld_vec_29_reg[7] : (proc_29_data_FIFO_blk[7] | proc_29_data_PIPO_blk[7] | proc_29_start_FIFO_blk[7] | proc_29_TLF_FIFO_blk[7] | proc_29_input_sync_blk[7] | proc_29_output_sync_blk[7]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_29_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_29_reg <= proc_dep_vld_vec_29;
        end
    end
    assign in_chan_dep_vld_vec_29[0] = dep_chan_vld_21_29;
    assign in_chan_dep_data_vec_29[40 : 0] = dep_chan_data_21_29;
    assign token_in_vec_29[0] = token_21_29;
    assign dep_chan_vld_29_21 = out_chan_dep_vld_vec_29[0];
    assign dep_chan_data_29_21 = out_chan_dep_data_29;
    assign token_29_21 = token_out_vec_29[0];
    assign dep_chan_vld_29_22 = out_chan_dep_vld_vec_29[1];
    assign dep_chan_data_29_22 = out_chan_dep_data_29;
    assign token_29_22 = token_out_vec_29[1];
    assign dep_chan_vld_29_23 = out_chan_dep_vld_vec_29[2];
    assign dep_chan_data_29_23 = out_chan_dep_data_29;
    assign token_29_23 = token_out_vec_29[2];
    assign dep_chan_vld_29_24 = out_chan_dep_vld_vec_29[3];
    assign dep_chan_data_29_24 = out_chan_dep_data_29;
    assign token_29_24 = token_out_vec_29[3];
    assign dep_chan_vld_29_25 = out_chan_dep_vld_vec_29[4];
    assign dep_chan_data_29_25 = out_chan_dep_data_29;
    assign token_29_25 = token_out_vec_29[4];
    assign dep_chan_vld_29_26 = out_chan_dep_vld_vec_29[5];
    assign dep_chan_data_29_26 = out_chan_dep_data_29;
    assign token_29_26 = token_out_vec_29[5];
    assign dep_chan_vld_29_27 = out_chan_dep_vld_vec_29[6];
    assign dep_chan_data_29_27 = out_chan_dep_data_29;
    assign token_29_27 = token_out_vec_29[6];
    assign dep_chan_vld_29_28 = out_chan_dep_vld_vec_29[7];
    assign dep_chan_data_29_28 = out_chan_dep_data_29;
    assign token_29_28 = token_out_vec_29[7];

    // Process: grp_inv_pass_fu_2319.entry_proc_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 30, 2, 2) wiener_stream_hls_deadlock_detect_unit_30 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_30),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_30),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_30),
        .token_in_vec(token_in_vec_30),
        .dl_detect_in(dl_detect_out),
        .origin(origin[30]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_30),
        .out_chan_dep_data(out_chan_dep_data_30),
        .token_out_vec(token_out_vec_30),
        .dl_detect_out(dl_in_vec[30]));

    assign proc_30_data_FIFO_blk[0] = 1'b0 | (~grp_inv_pass_fu_2319.entry_proc_U0.ox_c_blk_n) | (~grp_inv_pass_fu_2319.entry_proc_U0.oy_c_blk_n) | (~grp_inv_pass_fu_2319.entry_proc_U0.vx_c_blk_n);
    assign proc_30_data_PIPO_blk[0] = 1'b0;
    assign proc_30_start_FIFO_blk[0] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_store_tile_U0_U.if_full_n & grp_inv_pass_fu_2319.entry_proc_U0.ap_start & ~grp_inv_pass_fu_2319.entry_proc_U0.real_start & (trans_in_cnt_7 == trans_out_cnt_7) & ~grp_inv_pass_fu_2319.start_for_store_tile_U0_U.if_read);
    assign proc_30_TLF_FIFO_blk[0] = 1'b0;
    assign proc_30_input_sync_blk[0] = 1'b0;
    assign proc_30_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_30[0] = dl_detect_out ? proc_dep_vld_vec_30_reg[0] : (proc_30_data_FIFO_blk[0] | proc_30_data_PIPO_blk[0] | proc_30_start_FIFO_blk[0] | proc_30_TLF_FIFO_blk[0] | proc_30_input_sync_blk[0] | proc_30_output_sync_blk[0]);
    assign proc_30_data_FIFO_blk[1] = 1'b0;
    assign proc_30_data_PIPO_blk[1] = 1'b0;
    assign proc_30_start_FIFO_blk[1] = 1'b0;
    assign proc_30_TLF_FIFO_blk[1] = 1'b0;
    assign proc_30_input_sync_blk[1] = 1'b0 | (grp_inv_pass_fu_2319.ap_sync_entry_proc_U0_ap_ready & grp_inv_pass_fu_2319.entry_proc_U0.ap_idle & ~grp_inv_pass_fu_2319.ap_sync_load_rows2_U0_ap_ready);
    assign proc_30_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_30[1] = dl_detect_out ? proc_dep_vld_vec_30_reg[1] : (proc_30_data_FIFO_blk[1] | proc_30_data_PIPO_blk[1] | proc_30_start_FIFO_blk[1] | proc_30_TLF_FIFO_blk[1] | proc_30_input_sync_blk[1] | proc_30_output_sync_blk[1]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_30_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_30_reg <= proc_dep_vld_vec_30;
        end
    end
    assign in_chan_dep_vld_vec_30[0] = dep_chan_vld_31_30;
    assign in_chan_dep_data_vec_30[40 : 0] = dep_chan_data_31_30;
    assign token_in_vec_30[0] = token_31_30;
    assign in_chan_dep_vld_vec_30[1] = dep_chan_vld_40_30;
    assign in_chan_dep_data_vec_30[81 : 41] = dep_chan_data_40_30;
    assign token_in_vec_30[1] = token_40_30;
    assign dep_chan_vld_30_40 = out_chan_dep_vld_vec_30[0];
    assign dep_chan_data_30_40 = out_chan_dep_data_30;
    assign token_30_40 = token_out_vec_30[0];
    assign dep_chan_vld_30_31 = out_chan_dep_vld_vec_30[1];
    assign dep_chan_data_30_31 = out_chan_dep_data_30;
    assign token_30_31 = token_out_vec_30[1];

    // Process: grp_inv_pass_fu_2319.load_rows2_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 31, 9, 9) wiener_stream_hls_deadlock_detect_unit_31 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_31),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_31),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_31),
        .token_in_vec(token_in_vec_31),
        .dl_detect_in(dl_detect_out),
        .origin(origin[31]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_31),
        .out_chan_dep_data(out_chan_dep_data_31),
        .token_out_vec(token_out_vec_31),
        .dl_detect_out(dl_in_vec[31]));

    assign proc_31_data_FIFO_blk[0] = 1'b0 | (~grp_inv_pass_fu_2319.load_rows2_U0.iin_0_blk_n);
    assign proc_31_data_PIPO_blk[0] = 1'b0;
    assign proc_31_start_FIFO_blk[0] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U.if_read);
    assign proc_31_TLF_FIFO_blk[0] = 1'b0;
    assign proc_31_input_sync_blk[0] = 1'b0;
    assign proc_31_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_31[0] = dl_detect_out ? proc_dep_vld_vec_31_reg[0] : (proc_31_data_FIFO_blk[0] | proc_31_data_PIPO_blk[0] | proc_31_start_FIFO_blk[0] | proc_31_TLF_FIFO_blk[0] | proc_31_input_sync_blk[0] | proc_31_output_sync_blk[0]);
    assign proc_31_data_FIFO_blk[1] = 1'b0 | (~grp_inv_pass_fu_2319.load_rows2_U0.iin_1_blk_n);
    assign proc_31_data_PIPO_blk[1] = 1'b0;
    assign proc_31_start_FIFO_blk[1] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U.if_read);
    assign proc_31_TLF_FIFO_blk[1] = 1'b0;
    assign proc_31_input_sync_blk[1] = 1'b0;
    assign proc_31_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_31[1] = dl_detect_out ? proc_dep_vld_vec_31_reg[1] : (proc_31_data_FIFO_blk[1] | proc_31_data_PIPO_blk[1] | proc_31_start_FIFO_blk[1] | proc_31_TLF_FIFO_blk[1] | proc_31_input_sync_blk[1] | proc_31_output_sync_blk[1]);
    assign proc_31_data_FIFO_blk[2] = 1'b0 | (~grp_inv_pass_fu_2319.load_rows2_U0.iin_2_blk_n);
    assign proc_31_data_PIPO_blk[2] = 1'b0;
    assign proc_31_start_FIFO_blk[2] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U.if_read);
    assign proc_31_TLF_FIFO_blk[2] = 1'b0;
    assign proc_31_input_sync_blk[2] = 1'b0;
    assign proc_31_output_sync_blk[2] = 1'b0;
    assign proc_dep_vld_vec_31[2] = dl_detect_out ? proc_dep_vld_vec_31_reg[2] : (proc_31_data_FIFO_blk[2] | proc_31_data_PIPO_blk[2] | proc_31_start_FIFO_blk[2] | proc_31_TLF_FIFO_blk[2] | proc_31_input_sync_blk[2] | proc_31_output_sync_blk[2]);
    assign proc_31_data_FIFO_blk[3] = 1'b0 | (~grp_inv_pass_fu_2319.load_rows2_U0.iin_3_blk_n);
    assign proc_31_data_PIPO_blk[3] = 1'b0;
    assign proc_31_start_FIFO_blk[3] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U.if_read);
    assign proc_31_TLF_FIFO_blk[3] = 1'b0;
    assign proc_31_input_sync_blk[3] = 1'b0;
    assign proc_31_output_sync_blk[3] = 1'b0;
    assign proc_dep_vld_vec_31[3] = dl_detect_out ? proc_dep_vld_vec_31_reg[3] : (proc_31_data_FIFO_blk[3] | proc_31_data_PIPO_blk[3] | proc_31_start_FIFO_blk[3] | proc_31_TLF_FIFO_blk[3] | proc_31_input_sync_blk[3] | proc_31_output_sync_blk[3]);
    assign proc_31_data_FIFO_blk[4] = 1'b0 | (~grp_inv_pass_fu_2319.load_rows2_U0.iin_4_blk_n);
    assign proc_31_data_PIPO_blk[4] = 1'b0;
    assign proc_31_start_FIFO_blk[4] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U.if_read);
    assign proc_31_TLF_FIFO_blk[4] = 1'b0;
    assign proc_31_input_sync_blk[4] = 1'b0;
    assign proc_31_output_sync_blk[4] = 1'b0;
    assign proc_dep_vld_vec_31[4] = dl_detect_out ? proc_dep_vld_vec_31_reg[4] : (proc_31_data_FIFO_blk[4] | proc_31_data_PIPO_blk[4] | proc_31_start_FIFO_blk[4] | proc_31_TLF_FIFO_blk[4] | proc_31_input_sync_blk[4] | proc_31_output_sync_blk[4]);
    assign proc_31_data_FIFO_blk[5] = 1'b0 | (~grp_inv_pass_fu_2319.load_rows2_U0.iin_5_blk_n);
    assign proc_31_data_PIPO_blk[5] = 1'b0;
    assign proc_31_start_FIFO_blk[5] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U.if_read);
    assign proc_31_TLF_FIFO_blk[5] = 1'b0;
    assign proc_31_input_sync_blk[5] = 1'b0;
    assign proc_31_output_sync_blk[5] = 1'b0;
    assign proc_dep_vld_vec_31[5] = dl_detect_out ? proc_dep_vld_vec_31_reg[5] : (proc_31_data_FIFO_blk[5] | proc_31_data_PIPO_blk[5] | proc_31_start_FIFO_blk[5] | proc_31_TLF_FIFO_blk[5] | proc_31_input_sync_blk[5] | proc_31_output_sync_blk[5]);
    assign proc_31_data_FIFO_blk[6] = 1'b0 | (~grp_inv_pass_fu_2319.load_rows2_U0.iin_6_blk_n);
    assign proc_31_data_PIPO_blk[6] = 1'b0;
    assign proc_31_start_FIFO_blk[6] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U.if_read);
    assign proc_31_TLF_FIFO_blk[6] = 1'b0;
    assign proc_31_input_sync_blk[6] = 1'b0;
    assign proc_31_output_sync_blk[6] = 1'b0;
    assign proc_dep_vld_vec_31[6] = dl_detect_out ? proc_dep_vld_vec_31_reg[6] : (proc_31_data_FIFO_blk[6] | proc_31_data_PIPO_blk[6] | proc_31_start_FIFO_blk[6] | proc_31_TLF_FIFO_blk[6] | proc_31_input_sync_blk[6] | proc_31_output_sync_blk[6]);
    assign proc_31_data_FIFO_blk[7] = 1'b0 | (~grp_inv_pass_fu_2319.load_rows2_U0.iin_7_blk_n);
    assign proc_31_data_PIPO_blk[7] = 1'b0;
    assign proc_31_start_FIFO_blk[7] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U.if_read);
    assign proc_31_TLF_FIFO_blk[7] = 1'b0;
    assign proc_31_input_sync_blk[7] = 1'b0;
    assign proc_31_output_sync_blk[7] = 1'b0;
    assign proc_dep_vld_vec_31[7] = dl_detect_out ? proc_dep_vld_vec_31_reg[7] : (proc_31_data_FIFO_blk[7] | proc_31_data_PIPO_blk[7] | proc_31_start_FIFO_blk[7] | proc_31_TLF_FIFO_blk[7] | proc_31_input_sync_blk[7] | proc_31_output_sync_blk[7]);
    assign proc_31_data_FIFO_blk[8] = 1'b0;
    assign proc_31_data_PIPO_blk[8] = 1'b0;
    assign proc_31_start_FIFO_blk[8] = 1'b0;
    assign proc_31_TLF_FIFO_blk[8] = 1'b0;
    assign proc_31_input_sync_blk[8] = 1'b0 | (grp_inv_pass_fu_2319.ap_sync_load_rows2_U0_ap_ready & grp_inv_pass_fu_2319.load_rows2_U0.ap_idle & ~grp_inv_pass_fu_2319.ap_sync_entry_proc_U0_ap_ready);
    assign proc_31_output_sync_blk[8] = 1'b0;
    assign proc_dep_vld_vec_31[8] = dl_detect_out ? proc_dep_vld_vec_31_reg[8] : (proc_31_data_FIFO_blk[8] | proc_31_data_PIPO_blk[8] | proc_31_start_FIFO_blk[8] | proc_31_TLF_FIFO_blk[8] | proc_31_input_sync_blk[8] | proc_31_output_sync_blk[8]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_31_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_31_reg <= proc_dep_vld_vec_31;
        end
    end
    assign in_chan_dep_vld_vec_31[0] = dep_chan_vld_30_31;
    assign in_chan_dep_data_vec_31[40 : 0] = dep_chan_data_30_31;
    assign token_in_vec_31[0] = token_30_31;
    assign in_chan_dep_vld_vec_31[1] = dep_chan_vld_32_31;
    assign in_chan_dep_data_vec_31[81 : 41] = dep_chan_data_32_31;
    assign token_in_vec_31[1] = token_32_31;
    assign in_chan_dep_vld_vec_31[2] = dep_chan_vld_33_31;
    assign in_chan_dep_data_vec_31[122 : 82] = dep_chan_data_33_31;
    assign token_in_vec_31[2] = token_33_31;
    assign in_chan_dep_vld_vec_31[3] = dep_chan_vld_34_31;
    assign in_chan_dep_data_vec_31[163 : 123] = dep_chan_data_34_31;
    assign token_in_vec_31[3] = token_34_31;
    assign in_chan_dep_vld_vec_31[4] = dep_chan_vld_35_31;
    assign in_chan_dep_data_vec_31[204 : 164] = dep_chan_data_35_31;
    assign token_in_vec_31[4] = token_35_31;
    assign in_chan_dep_vld_vec_31[5] = dep_chan_vld_36_31;
    assign in_chan_dep_data_vec_31[245 : 205] = dep_chan_data_36_31;
    assign token_in_vec_31[5] = token_36_31;
    assign in_chan_dep_vld_vec_31[6] = dep_chan_vld_37_31;
    assign in_chan_dep_data_vec_31[286 : 246] = dep_chan_data_37_31;
    assign token_in_vec_31[6] = token_37_31;
    assign in_chan_dep_vld_vec_31[7] = dep_chan_vld_38_31;
    assign in_chan_dep_data_vec_31[327 : 287] = dep_chan_data_38_31;
    assign token_in_vec_31[7] = token_38_31;
    assign in_chan_dep_vld_vec_31[8] = dep_chan_vld_39_31;
    assign in_chan_dep_data_vec_31[368 : 328] = dep_chan_data_39_31;
    assign token_in_vec_31[8] = token_39_31;
    assign dep_chan_vld_31_32 = out_chan_dep_vld_vec_31[0];
    assign dep_chan_data_31_32 = out_chan_dep_data_31;
    assign token_31_32 = token_out_vec_31[0];
    assign dep_chan_vld_31_33 = out_chan_dep_vld_vec_31[1];
    assign dep_chan_data_31_33 = out_chan_dep_data_31;
    assign token_31_33 = token_out_vec_31[1];
    assign dep_chan_vld_31_34 = out_chan_dep_vld_vec_31[2];
    assign dep_chan_data_31_34 = out_chan_dep_data_31;
    assign token_31_34 = token_out_vec_31[2];
    assign dep_chan_vld_31_35 = out_chan_dep_vld_vec_31[3];
    assign dep_chan_data_31_35 = out_chan_dep_data_31;
    assign token_31_35 = token_out_vec_31[3];
    assign dep_chan_vld_31_36 = out_chan_dep_vld_vec_31[4];
    assign dep_chan_data_31_36 = out_chan_dep_data_31;
    assign token_31_36 = token_out_vec_31[4];
    assign dep_chan_vld_31_37 = out_chan_dep_vld_vec_31[5];
    assign dep_chan_data_31_37 = out_chan_dep_data_31;
    assign token_31_37 = token_out_vec_31[5];
    assign dep_chan_vld_31_38 = out_chan_dep_vld_vec_31[6];
    assign dep_chan_data_31_38 = out_chan_dep_data_31;
    assign token_31_38 = token_out_vec_31[6];
    assign dep_chan_vld_31_39 = out_chan_dep_vld_vec_31[7];
    assign dep_chan_data_31_39 = out_chan_dep_data_31;
    assign token_31_39 = token_out_vec_31[7];
    assign dep_chan_vld_31_30 = out_chan_dep_vld_vec_31[8];
    assign dep_chan_data_31_30 = out_chan_dep_data_31;
    assign token_31_30 = token_out_vec_31[8];

    // Process: grp_inv_pass_fu_2319.fft_core_1_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 32, 2, 1) wiener_stream_hls_deadlock_detect_unit_32 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_32),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_32),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_32),
        .token_in_vec(token_in_vec_32),
        .dl_detect_in(dl_detect_out),
        .origin(origin[32]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_32),
        .out_chan_dep_data(out_chan_dep_data_32),
        .token_out_vec(token_out_vec_32),
        .dl_detect_out(dl_in_vec[32]));

    assign proc_32_data_FIFO_blk[0] = 1'b0;
    assign proc_32_data_PIPO_blk[0] = 1'b0;
    assign proc_32_start_FIFO_blk[0] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_1_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U.if_write);
    assign proc_32_TLF_FIFO_blk[0] = 1'b0;
    assign proc_32_input_sync_blk[0] = 1'b0;
    assign proc_32_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_32[0] = dl_detect_out ? proc_dep_vld_vec_32_reg[0] : (proc_32_data_FIFO_blk[0] | proc_32_data_PIPO_blk[0] | proc_32_start_FIFO_blk[0] | proc_32_TLF_FIFO_blk[0] | proc_32_input_sync_blk[0] | proc_32_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_32_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_32_reg <= proc_dep_vld_vec_32;
        end
    end
    assign in_chan_dep_vld_vec_32[0] = dep_chan_vld_31_32;
    assign in_chan_dep_data_vec_32[40 : 0] = dep_chan_data_31_32;
    assign token_in_vec_32[0] = token_31_32;
    assign in_chan_dep_vld_vec_32[1] = dep_chan_vld_40_32;
    assign in_chan_dep_data_vec_32[81 : 41] = dep_chan_data_40_32;
    assign token_in_vec_32[1] = token_40_32;
    assign dep_chan_vld_32_31 = out_chan_dep_vld_vec_32[0];
    assign dep_chan_data_32_31 = out_chan_dep_data_32;
    assign token_32_31 = token_out_vec_32[0];

    // Process: grp_inv_pass_fu_2319.fft_core_2_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 33, 2, 1) wiener_stream_hls_deadlock_detect_unit_33 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_33),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_33),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_33),
        .token_in_vec(token_in_vec_33),
        .dl_detect_in(dl_detect_out),
        .origin(origin[33]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_33),
        .out_chan_dep_data(out_chan_dep_data_33),
        .token_out_vec(token_out_vec_33),
        .dl_detect_out(dl_in_vec[33]));

    assign proc_33_data_FIFO_blk[0] = 1'b0;
    assign proc_33_data_PIPO_blk[0] = 1'b0;
    assign proc_33_start_FIFO_blk[0] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_2_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U.if_write);
    assign proc_33_TLF_FIFO_blk[0] = 1'b0;
    assign proc_33_input_sync_blk[0] = 1'b0;
    assign proc_33_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_33[0] = dl_detect_out ? proc_dep_vld_vec_33_reg[0] : (proc_33_data_FIFO_blk[0] | proc_33_data_PIPO_blk[0] | proc_33_start_FIFO_blk[0] | proc_33_TLF_FIFO_blk[0] | proc_33_input_sync_blk[0] | proc_33_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_33_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_33_reg <= proc_dep_vld_vec_33;
        end
    end
    assign in_chan_dep_vld_vec_33[0] = dep_chan_vld_31_33;
    assign in_chan_dep_data_vec_33[40 : 0] = dep_chan_data_31_33;
    assign token_in_vec_33[0] = token_31_33;
    assign in_chan_dep_vld_vec_33[1] = dep_chan_vld_40_33;
    assign in_chan_dep_data_vec_33[81 : 41] = dep_chan_data_40_33;
    assign token_in_vec_33[1] = token_40_33;
    assign dep_chan_vld_33_31 = out_chan_dep_vld_vec_33[0];
    assign dep_chan_data_33_31 = out_chan_dep_data_33;
    assign token_33_31 = token_out_vec_33[0];

    // Process: grp_inv_pass_fu_2319.fft_core_3_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 34, 2, 1) wiener_stream_hls_deadlock_detect_unit_34 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_34),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_34),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_34),
        .token_in_vec(token_in_vec_34),
        .dl_detect_in(dl_detect_out),
        .origin(origin[34]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_34),
        .out_chan_dep_data(out_chan_dep_data_34),
        .token_out_vec(token_out_vec_34),
        .dl_detect_out(dl_in_vec[34]));

    assign proc_34_data_FIFO_blk[0] = 1'b0;
    assign proc_34_data_PIPO_blk[0] = 1'b0;
    assign proc_34_start_FIFO_blk[0] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_3_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U.if_write);
    assign proc_34_TLF_FIFO_blk[0] = 1'b0;
    assign proc_34_input_sync_blk[0] = 1'b0;
    assign proc_34_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_34[0] = dl_detect_out ? proc_dep_vld_vec_34_reg[0] : (proc_34_data_FIFO_blk[0] | proc_34_data_PIPO_blk[0] | proc_34_start_FIFO_blk[0] | proc_34_TLF_FIFO_blk[0] | proc_34_input_sync_blk[0] | proc_34_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_34_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_34_reg <= proc_dep_vld_vec_34;
        end
    end
    assign in_chan_dep_vld_vec_34[0] = dep_chan_vld_31_34;
    assign in_chan_dep_data_vec_34[40 : 0] = dep_chan_data_31_34;
    assign token_in_vec_34[0] = token_31_34;
    assign in_chan_dep_vld_vec_34[1] = dep_chan_vld_40_34;
    assign in_chan_dep_data_vec_34[81 : 41] = dep_chan_data_40_34;
    assign token_in_vec_34[1] = token_40_34;
    assign dep_chan_vld_34_31 = out_chan_dep_vld_vec_34[0];
    assign dep_chan_data_34_31 = out_chan_dep_data_34;
    assign token_34_31 = token_out_vec_34[0];

    // Process: grp_inv_pass_fu_2319.fft_core_4_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 35, 2, 1) wiener_stream_hls_deadlock_detect_unit_35 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_35),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_35),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_35),
        .token_in_vec(token_in_vec_35),
        .dl_detect_in(dl_detect_out),
        .origin(origin[35]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_35),
        .out_chan_dep_data(out_chan_dep_data_35),
        .token_out_vec(token_out_vec_35),
        .dl_detect_out(dl_in_vec[35]));

    assign proc_35_data_FIFO_blk[0] = 1'b0;
    assign proc_35_data_PIPO_blk[0] = 1'b0;
    assign proc_35_start_FIFO_blk[0] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_4_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U.if_write);
    assign proc_35_TLF_FIFO_blk[0] = 1'b0;
    assign proc_35_input_sync_blk[0] = 1'b0;
    assign proc_35_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_35[0] = dl_detect_out ? proc_dep_vld_vec_35_reg[0] : (proc_35_data_FIFO_blk[0] | proc_35_data_PIPO_blk[0] | proc_35_start_FIFO_blk[0] | proc_35_TLF_FIFO_blk[0] | proc_35_input_sync_blk[0] | proc_35_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_35_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_35_reg <= proc_dep_vld_vec_35;
        end
    end
    assign in_chan_dep_vld_vec_35[0] = dep_chan_vld_31_35;
    assign in_chan_dep_data_vec_35[40 : 0] = dep_chan_data_31_35;
    assign token_in_vec_35[0] = token_31_35;
    assign in_chan_dep_vld_vec_35[1] = dep_chan_vld_40_35;
    assign in_chan_dep_data_vec_35[81 : 41] = dep_chan_data_40_35;
    assign token_in_vec_35[1] = token_40_35;
    assign dep_chan_vld_35_31 = out_chan_dep_vld_vec_35[0];
    assign dep_chan_data_35_31 = out_chan_dep_data_35;
    assign token_35_31 = token_out_vec_35[0];

    // Process: grp_inv_pass_fu_2319.fft_core_5_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 36, 2, 1) wiener_stream_hls_deadlock_detect_unit_36 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_36),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_36),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_36),
        .token_in_vec(token_in_vec_36),
        .dl_detect_in(dl_detect_out),
        .origin(origin[36]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_36),
        .out_chan_dep_data(out_chan_dep_data_36),
        .token_out_vec(token_out_vec_36),
        .dl_detect_out(dl_in_vec[36]));

    assign proc_36_data_FIFO_blk[0] = 1'b0;
    assign proc_36_data_PIPO_blk[0] = 1'b0;
    assign proc_36_start_FIFO_blk[0] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_5_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U.if_write);
    assign proc_36_TLF_FIFO_blk[0] = 1'b0;
    assign proc_36_input_sync_blk[0] = 1'b0;
    assign proc_36_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_36[0] = dl_detect_out ? proc_dep_vld_vec_36_reg[0] : (proc_36_data_FIFO_blk[0] | proc_36_data_PIPO_blk[0] | proc_36_start_FIFO_blk[0] | proc_36_TLF_FIFO_blk[0] | proc_36_input_sync_blk[0] | proc_36_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_36_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_36_reg <= proc_dep_vld_vec_36;
        end
    end
    assign in_chan_dep_vld_vec_36[0] = dep_chan_vld_31_36;
    assign in_chan_dep_data_vec_36[40 : 0] = dep_chan_data_31_36;
    assign token_in_vec_36[0] = token_31_36;
    assign in_chan_dep_vld_vec_36[1] = dep_chan_vld_40_36;
    assign in_chan_dep_data_vec_36[81 : 41] = dep_chan_data_40_36;
    assign token_in_vec_36[1] = token_40_36;
    assign dep_chan_vld_36_31 = out_chan_dep_vld_vec_36[0];
    assign dep_chan_data_36_31 = out_chan_dep_data_36;
    assign token_36_31 = token_out_vec_36[0];

    // Process: grp_inv_pass_fu_2319.fft_core_6_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 37, 2, 1) wiener_stream_hls_deadlock_detect_unit_37 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_37),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_37),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_37),
        .token_in_vec(token_in_vec_37),
        .dl_detect_in(dl_detect_out),
        .origin(origin[37]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_37),
        .out_chan_dep_data(out_chan_dep_data_37),
        .token_out_vec(token_out_vec_37),
        .dl_detect_out(dl_in_vec[37]));

    assign proc_37_data_FIFO_blk[0] = 1'b0;
    assign proc_37_data_PIPO_blk[0] = 1'b0;
    assign proc_37_start_FIFO_blk[0] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_6_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U.if_write);
    assign proc_37_TLF_FIFO_blk[0] = 1'b0;
    assign proc_37_input_sync_blk[0] = 1'b0;
    assign proc_37_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_37[0] = dl_detect_out ? proc_dep_vld_vec_37_reg[0] : (proc_37_data_FIFO_blk[0] | proc_37_data_PIPO_blk[0] | proc_37_start_FIFO_blk[0] | proc_37_TLF_FIFO_blk[0] | proc_37_input_sync_blk[0] | proc_37_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_37_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_37_reg <= proc_dep_vld_vec_37;
        end
    end
    assign in_chan_dep_vld_vec_37[0] = dep_chan_vld_31_37;
    assign in_chan_dep_data_vec_37[40 : 0] = dep_chan_data_31_37;
    assign token_in_vec_37[0] = token_31_37;
    assign in_chan_dep_vld_vec_37[1] = dep_chan_vld_40_37;
    assign in_chan_dep_data_vec_37[81 : 41] = dep_chan_data_40_37;
    assign token_in_vec_37[1] = token_40_37;
    assign dep_chan_vld_37_31 = out_chan_dep_vld_vec_37[0];
    assign dep_chan_data_37_31 = out_chan_dep_data_37;
    assign token_37_31 = token_out_vec_37[0];

    // Process: grp_inv_pass_fu_2319.fft_core_7_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 38, 2, 1) wiener_stream_hls_deadlock_detect_unit_38 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_38),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_38),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_38),
        .token_in_vec(token_in_vec_38),
        .dl_detect_in(dl_detect_out),
        .origin(origin[38]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_38),
        .out_chan_dep_data(out_chan_dep_data_38),
        .token_out_vec(token_out_vec_38),
        .dl_detect_out(dl_in_vec[38]));

    assign proc_38_data_FIFO_blk[0] = 1'b0;
    assign proc_38_data_PIPO_blk[0] = 1'b0;
    assign proc_38_start_FIFO_blk[0] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_7_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U.if_write);
    assign proc_38_TLF_FIFO_blk[0] = 1'b0;
    assign proc_38_input_sync_blk[0] = 1'b0;
    assign proc_38_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_38[0] = dl_detect_out ? proc_dep_vld_vec_38_reg[0] : (proc_38_data_FIFO_blk[0] | proc_38_data_PIPO_blk[0] | proc_38_start_FIFO_blk[0] | proc_38_TLF_FIFO_blk[0] | proc_38_input_sync_blk[0] | proc_38_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_38_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_38_reg <= proc_dep_vld_vec_38;
        end
    end
    assign in_chan_dep_vld_vec_38[0] = dep_chan_vld_31_38;
    assign in_chan_dep_data_vec_38[40 : 0] = dep_chan_data_31_38;
    assign token_in_vec_38[0] = token_31_38;
    assign in_chan_dep_vld_vec_38[1] = dep_chan_vld_40_38;
    assign in_chan_dep_data_vec_38[81 : 41] = dep_chan_data_40_38;
    assign token_in_vec_38[1] = token_40_38;
    assign dep_chan_vld_38_31 = out_chan_dep_vld_vec_38[0];
    assign dep_chan_data_38_31 = out_chan_dep_data_38;
    assign token_38_31 = token_out_vec_38[0];

    // Process: grp_inv_pass_fu_2319.fft_core_8_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 39, 2, 1) wiener_stream_hls_deadlock_detect_unit_39 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_39),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_39),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_39),
        .token_in_vec(token_in_vec_39),
        .dl_detect_in(dl_detect_out),
        .origin(origin[39]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_39),
        .out_chan_dep_data(out_chan_dep_data_39),
        .token_out_vec(token_out_vec_39),
        .dl_detect_out(dl_in_vec[39]));

    assign proc_39_data_FIFO_blk[0] = 1'b0;
    assign proc_39_data_PIPO_blk[0] = 1'b0;
    assign proc_39_start_FIFO_blk[0] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_8_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U.if_write);
    assign proc_39_TLF_FIFO_blk[0] = 1'b0;
    assign proc_39_input_sync_blk[0] = 1'b0;
    assign proc_39_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_39[0] = dl_detect_out ? proc_dep_vld_vec_39_reg[0] : (proc_39_data_FIFO_blk[0] | proc_39_data_PIPO_blk[0] | proc_39_start_FIFO_blk[0] | proc_39_TLF_FIFO_blk[0] | proc_39_input_sync_blk[0] | proc_39_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_39_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_39_reg <= proc_dep_vld_vec_39;
        end
    end
    assign in_chan_dep_vld_vec_39[0] = dep_chan_vld_31_39;
    assign in_chan_dep_data_vec_39[40 : 0] = dep_chan_data_31_39;
    assign token_in_vec_39[0] = token_31_39;
    assign in_chan_dep_vld_vec_39[1] = dep_chan_vld_40_39;
    assign in_chan_dep_data_vec_39[81 : 41] = dep_chan_data_40_39;
    assign token_in_vec_39[1] = token_40_39;
    assign dep_chan_vld_39_31 = out_chan_dep_vld_vec_39[0];
    assign dep_chan_data_39_31 = out_chan_dep_data_39;
    assign token_39_31 = token_out_vec_39[0];

    // Process: grp_inv_pass_fu_2319.store_tile_U0
    wiener_stream_hls_deadlock_detect_unit #(41, 40, 1, 9) wiener_stream_hls_deadlock_detect_unit_40 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_40),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_40),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_40),
        .token_in_vec(token_in_vec_40),
        .dl_detect_in(dl_detect_out),
        .origin(origin[40]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_40),
        .out_chan_dep_data(out_chan_dep_data_40),
        .token_out_vec(token_out_vec_40),
        .dl_detect_out(dl_in_vec[40]));

    assign proc_40_data_FIFO_blk[0] = 1'b0 | (~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_0_blk_n);
    assign proc_40_data_PIPO_blk[0] = 1'b0;
    assign proc_40_start_FIFO_blk[0] = 1'b0;
    assign proc_40_TLF_FIFO_blk[0] = 1'b0;
    assign proc_40_input_sync_blk[0] = 1'b0;
    assign proc_40_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_40[0] = dl_detect_out ? proc_dep_vld_vec_40_reg[0] : (proc_40_data_FIFO_blk[0] | proc_40_data_PIPO_blk[0] | proc_40_start_FIFO_blk[0] | proc_40_TLF_FIFO_blk[0] | proc_40_input_sync_blk[0] | proc_40_output_sync_blk[0]);
    assign proc_40_data_FIFO_blk[1] = 1'b0 | (~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_1_blk_n);
    assign proc_40_data_PIPO_blk[1] = 1'b0;
    assign proc_40_start_FIFO_blk[1] = 1'b0;
    assign proc_40_TLF_FIFO_blk[1] = 1'b0;
    assign proc_40_input_sync_blk[1] = 1'b0;
    assign proc_40_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_40[1] = dl_detect_out ? proc_dep_vld_vec_40_reg[1] : (proc_40_data_FIFO_blk[1] | proc_40_data_PIPO_blk[1] | proc_40_start_FIFO_blk[1] | proc_40_TLF_FIFO_blk[1] | proc_40_input_sync_blk[1] | proc_40_output_sync_blk[1]);
    assign proc_40_data_FIFO_blk[2] = 1'b0 | (~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_2_blk_n);
    assign proc_40_data_PIPO_blk[2] = 1'b0;
    assign proc_40_start_FIFO_blk[2] = 1'b0;
    assign proc_40_TLF_FIFO_blk[2] = 1'b0;
    assign proc_40_input_sync_blk[2] = 1'b0;
    assign proc_40_output_sync_blk[2] = 1'b0;
    assign proc_dep_vld_vec_40[2] = dl_detect_out ? proc_dep_vld_vec_40_reg[2] : (proc_40_data_FIFO_blk[2] | proc_40_data_PIPO_blk[2] | proc_40_start_FIFO_blk[2] | proc_40_TLF_FIFO_blk[2] | proc_40_input_sync_blk[2] | proc_40_output_sync_blk[2]);
    assign proc_40_data_FIFO_blk[3] = 1'b0 | (~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_3_blk_n);
    assign proc_40_data_PIPO_blk[3] = 1'b0;
    assign proc_40_start_FIFO_blk[3] = 1'b0;
    assign proc_40_TLF_FIFO_blk[3] = 1'b0;
    assign proc_40_input_sync_blk[3] = 1'b0;
    assign proc_40_output_sync_blk[3] = 1'b0;
    assign proc_dep_vld_vec_40[3] = dl_detect_out ? proc_dep_vld_vec_40_reg[3] : (proc_40_data_FIFO_blk[3] | proc_40_data_PIPO_blk[3] | proc_40_start_FIFO_blk[3] | proc_40_TLF_FIFO_blk[3] | proc_40_input_sync_blk[3] | proc_40_output_sync_blk[3]);
    assign proc_40_data_FIFO_blk[4] = 1'b0 | (~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_4_blk_n);
    assign proc_40_data_PIPO_blk[4] = 1'b0;
    assign proc_40_start_FIFO_blk[4] = 1'b0;
    assign proc_40_TLF_FIFO_blk[4] = 1'b0;
    assign proc_40_input_sync_blk[4] = 1'b0;
    assign proc_40_output_sync_blk[4] = 1'b0;
    assign proc_dep_vld_vec_40[4] = dl_detect_out ? proc_dep_vld_vec_40_reg[4] : (proc_40_data_FIFO_blk[4] | proc_40_data_PIPO_blk[4] | proc_40_start_FIFO_blk[4] | proc_40_TLF_FIFO_blk[4] | proc_40_input_sync_blk[4] | proc_40_output_sync_blk[4]);
    assign proc_40_data_FIFO_blk[5] = 1'b0 | (~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_5_blk_n);
    assign proc_40_data_PIPO_blk[5] = 1'b0;
    assign proc_40_start_FIFO_blk[5] = 1'b0;
    assign proc_40_TLF_FIFO_blk[5] = 1'b0;
    assign proc_40_input_sync_blk[5] = 1'b0;
    assign proc_40_output_sync_blk[5] = 1'b0;
    assign proc_dep_vld_vec_40[5] = dl_detect_out ? proc_dep_vld_vec_40_reg[5] : (proc_40_data_FIFO_blk[5] | proc_40_data_PIPO_blk[5] | proc_40_start_FIFO_blk[5] | proc_40_TLF_FIFO_blk[5] | proc_40_input_sync_blk[5] | proc_40_output_sync_blk[5]);
    assign proc_40_data_FIFO_blk[6] = 1'b0 | (~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_6_blk_n);
    assign proc_40_data_PIPO_blk[6] = 1'b0;
    assign proc_40_start_FIFO_blk[6] = 1'b0;
    assign proc_40_TLF_FIFO_blk[6] = 1'b0;
    assign proc_40_input_sync_blk[6] = 1'b0;
    assign proc_40_output_sync_blk[6] = 1'b0;
    assign proc_dep_vld_vec_40[6] = dl_detect_out ? proc_dep_vld_vec_40_reg[6] : (proc_40_data_FIFO_blk[6] | proc_40_data_PIPO_blk[6] | proc_40_start_FIFO_blk[6] | proc_40_TLF_FIFO_blk[6] | proc_40_input_sync_blk[6] | proc_40_output_sync_blk[6]);
    assign proc_40_data_FIFO_blk[7] = 1'b0 | (~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_7_blk_n);
    assign proc_40_data_PIPO_blk[7] = 1'b0;
    assign proc_40_start_FIFO_blk[7] = 1'b0;
    assign proc_40_TLF_FIFO_blk[7] = 1'b0;
    assign proc_40_input_sync_blk[7] = 1'b0;
    assign proc_40_output_sync_blk[7] = 1'b0;
    assign proc_dep_vld_vec_40[7] = dl_detect_out ? proc_dep_vld_vec_40_reg[7] : (proc_40_data_FIFO_blk[7] | proc_40_data_PIPO_blk[7] | proc_40_start_FIFO_blk[7] | proc_40_TLF_FIFO_blk[7] | proc_40_input_sync_blk[7] | proc_40_output_sync_blk[7]);
    assign proc_40_data_FIFO_blk[8] = 1'b0 | (~grp_inv_pass_fu_2319.store_tile_U0.ox_blk_n) | (~grp_inv_pass_fu_2319.store_tile_U0.oy_blk_n) | (~grp_inv_pass_fu_2319.store_tile_U0.vx_blk_n);
    assign proc_40_data_PIPO_blk[8] = 1'b0;
    assign proc_40_start_FIFO_blk[8] = 1'b0 | (~grp_inv_pass_fu_2319.start_for_store_tile_U0_U.if_empty_n & grp_inv_pass_fu_2319.store_tile_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_store_tile_U0_U.if_write);
    assign proc_40_TLF_FIFO_blk[8] = 1'b0;
    assign proc_40_input_sync_blk[8] = 1'b0;
    assign proc_40_output_sync_blk[8] = 1'b0;
    assign proc_dep_vld_vec_40[8] = dl_detect_out ? proc_dep_vld_vec_40_reg[8] : (proc_40_data_FIFO_blk[8] | proc_40_data_PIPO_blk[8] | proc_40_start_FIFO_blk[8] | proc_40_TLF_FIFO_blk[8] | proc_40_input_sync_blk[8] | proc_40_output_sync_blk[8]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_40_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_40_reg <= proc_dep_vld_vec_40;
        end
    end
    assign in_chan_dep_vld_vec_40[0] = dep_chan_vld_30_40;
    assign in_chan_dep_data_vec_40[40 : 0] = dep_chan_data_30_40;
    assign token_in_vec_40[0] = token_30_40;
    assign dep_chan_vld_40_32 = out_chan_dep_vld_vec_40[0];
    assign dep_chan_data_40_32 = out_chan_dep_data_40;
    assign token_40_32 = token_out_vec_40[0];
    assign dep_chan_vld_40_33 = out_chan_dep_vld_vec_40[1];
    assign dep_chan_data_40_33 = out_chan_dep_data_40;
    assign token_40_33 = token_out_vec_40[1];
    assign dep_chan_vld_40_34 = out_chan_dep_vld_vec_40[2];
    assign dep_chan_data_40_34 = out_chan_dep_data_40;
    assign token_40_34 = token_out_vec_40[2];
    assign dep_chan_vld_40_35 = out_chan_dep_vld_vec_40[3];
    assign dep_chan_data_40_35 = out_chan_dep_data_40;
    assign token_40_35 = token_out_vec_40[3];
    assign dep_chan_vld_40_36 = out_chan_dep_vld_vec_40[4];
    assign dep_chan_data_40_36 = out_chan_dep_data_40;
    assign token_40_36 = token_out_vec_40[4];
    assign dep_chan_vld_40_37 = out_chan_dep_vld_vec_40[5];
    assign dep_chan_data_40_37 = out_chan_dep_data_40;
    assign token_40_37 = token_out_vec_40[5];
    assign dep_chan_vld_40_38 = out_chan_dep_vld_vec_40[6];
    assign dep_chan_data_40_38 = out_chan_dep_data_40;
    assign token_40_38 = token_out_vec_40[6];
    assign dep_chan_vld_40_39 = out_chan_dep_vld_vec_40[7];
    assign dep_chan_data_40_39 = out_chan_dep_data_40;
    assign token_40_39 = token_out_vec_40[7];
    assign dep_chan_vld_40_30 = out_chan_dep_vld_vec_40[8];
    assign dep_chan_data_40_30 = out_chan_dep_data_40;
    assign token_40_30 = token_out_vec_40[8];


`include "wiener_stream_hls_deadlock_report_unit.vh"
