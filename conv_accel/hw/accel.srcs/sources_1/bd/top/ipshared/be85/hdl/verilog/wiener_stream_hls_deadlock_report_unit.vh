   
    parameter PROC_NUM = 41;
    parameter ST_IDLE = 3'b000;
    parameter ST_FILTER_FAKE = 3'b001;
    parameter ST_DL_DETECTED = 3'b010;
    parameter ST_DL_REPORT = 3'b100;
   

    reg [2:0] CS_fsm;
    reg [2:0] NS_fsm;
    reg [PROC_NUM - 1:0] dl_detect_reg;
    reg [PROC_NUM - 1:0] dl_done_reg;
    reg [PROC_NUM - 1:0] origin_reg;
    reg [PROC_NUM - 1:0] dl_in_vec_reg;
    reg [31:0] dl_keep_cnt;
    reg stop_report_path;
    reg [PROC_NUM - 1:0] reported_proc;
    integer i;
    integer fp;

    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            reported_proc <= 'b0;
        end
        else if (CS_fsm == ST_DL_REPORT) begin
            reported_proc <= reported_proc | dl_in_vec;
        end
        else if (CS_fsm == ST_DL_DETECTED) begin
            reported_proc <= 'b0;
        end
    end

    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            stop_report_path <= 1'b0;
        end
        else if (CS_fsm == ST_DL_REPORT && (|(dl_in_vec & reported_proc))) begin
            stop_report_path <= 1'b1;
        end
        else if (CS_fsm == ST_IDLE) begin
            stop_report_path <= 1'b0;
        end
    end

    // FSM State machine
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            CS_fsm <= ST_IDLE;
        end
        else begin
            CS_fsm <= NS_fsm;
        end
    end

    always @ (CS_fsm or dl_in_vec or dl_detect_reg or dl_done_reg or dl_in_vec or origin_reg or dl_keep_cnt) begin
        case (CS_fsm)
            ST_IDLE : begin
                if (|dl_in_vec) begin
                    NS_fsm = ST_FILTER_FAKE;
                end
                else begin
                    NS_fsm = ST_IDLE;
                end
            end
            ST_FILTER_FAKE: begin
                if (dl_keep_cnt >= 32'd1000) begin
                    NS_fsm = ST_DL_DETECTED;
                end
                else if (dl_detect_reg != (dl_detect_reg & dl_in_vec)) begin
                    NS_fsm = ST_IDLE;
                end
                else begin
                    NS_fsm = ST_FILTER_FAKE;
                end
            end
            ST_DL_DETECTED: begin
                // has unreported deadlock cycle
                if ((dl_detect_reg != dl_done_reg) && stop_report_path == 1'b0) begin
                    NS_fsm = ST_DL_REPORT;
                end
                else begin
                    NS_fsm = ST_DL_DETECTED;
                end
            end
            ST_DL_REPORT: begin
                if (|(dl_in_vec & origin_reg)) begin
                    NS_fsm = ST_DL_DETECTED;
                end
                // avoid report deadlock ring.
                else if (|(dl_in_vec & reported_proc)) begin
                    NS_fsm = ST_DL_DETECTED;
                end
                else begin
                    NS_fsm = ST_DL_REPORT;
                end
            end
            default: NS_fsm = ST_IDLE;
        endcase
    end

    // dl_detect_reg record the procs that first detect deadlock
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            dl_detect_reg <= 'b0;
        end
        else begin
            if (CS_fsm == ST_IDLE) begin
                dl_detect_reg <= dl_in_vec;
            end
        end
    end

    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            dl_keep_cnt <= 32'h0;
        end
        else begin
            if (CS_fsm == ST_FILTER_FAKE && (dl_detect_reg == (dl_detect_reg & dl_in_vec))) begin
                dl_keep_cnt <= dl_keep_cnt + 32'h1;
            end
            else if (CS_fsm == ST_FILTER_FAKE && (dl_detect_reg != (dl_detect_reg & dl_in_vec))) begin
                dl_keep_cnt <= 32'h0;
            end
        end
    end

    // dl_detect_out keeps in high after deadlock detected
    assign dl_detect_out = (|dl_detect_reg) && (CS_fsm == ST_DL_DETECTED || CS_fsm == ST_DL_REPORT);

    // dl_done_reg record the cycles has been reported
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            dl_done_reg <= 'b0;
        end
        else begin
            if ((CS_fsm == ST_DL_REPORT) && (|(dl_in_vec & dl_detect_reg) == 'b1)) begin
                dl_done_reg <= dl_done_reg | dl_in_vec;
            end
        end
    end

    // clear token once a cycle is done
    assign token_clear = (CS_fsm == ST_DL_REPORT) ? ((|(dl_in_vec & origin_reg)) ? 'b1 : 'b0) : 'b0;

    // origin_reg record the current cycle start id
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            origin_reg <= 'b0;
        end
        else begin
            if (CS_fsm == ST_DL_DETECTED) begin
                origin_reg <= origin;
            end
        end
    end
   
    // origin will be valid for only one cycle
    wire [PROC_NUM*PROC_NUM - 1:0] origin_tmp;
    assign origin_tmp[PROC_NUM - 1:0] = (dl_detect_reg[0] & ~dl_done_reg[0]) ? 'b1 : 'b0;
    genvar j;
    generate
    for(j = 1;j < PROC_NUM;j = j + 1) begin: F1
        assign origin_tmp[j*PROC_NUM +: PROC_NUM] = (dl_detect_reg[j] & ~dl_done_reg[j]) ? ('b1 << j) : origin_tmp[(j - 1)*PROC_NUM +: PROC_NUM];
    end
    endgenerate
    always @ (CS_fsm or origin_tmp) begin
        if (CS_fsm == ST_DL_DETECTED) begin
            origin = origin_tmp[(PROC_NUM - 1)*PROC_NUM +: PROC_NUM];
        end
        else begin
            origin = 'b0;
        end
    end

    
    // dl_in_vec_reg record the current cycle dl_in_vec
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            dl_in_vec_reg <= 'b0;
        end
        else begin
            if (CS_fsm == ST_DL_DETECTED) begin
                dl_in_vec_reg <= origin;
            end
            else if (CS_fsm == ST_DL_REPORT) begin
                dl_in_vec_reg <= dl_in_vec;
            end
        end
    end
    
    // find_df_deadlock to report the deadlock
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            find_df_deadlock <= 1'b0;
        end
        else begin
            if (CS_fsm == ST_DL_DETECTED && ((dl_detect_reg == dl_done_reg) || (stop_report_path == 1'b1))) begin
                find_df_deadlock <= 1'b1;
            end
            else if (CS_fsm == ST_IDLE) begin
                find_df_deadlock <= 1'b0;
            end
        end
    end
    
    // get the first valid proc index in dl vector
    function integer proc_index(input [PROC_NUM - 1:0] dl_vec);
        begin
            proc_index = 0;
            for (i = 0; i < PROC_NUM; i = i + 1) begin
                if (dl_vec[i]) begin
                    proc_index = i;
                end
            end
        end
    endfunction

    // get the proc path based on dl vector
    function [560:0] proc_path(input [PROC_NUM - 1:0] dl_vec);
        integer index;
        begin
            index = proc_index(dl_vec);
            case (index)
                0 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0";
                end
                1 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_25_U0";
                end
                2 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_26_U0";
                end
                3 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_27_U0";
                end
                4 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_28_U0";
                end
                5 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_29_U0";
                end
                6 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_30_U0";
                end
                7 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_31_U0";
                end
                8 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_U0";
                end
                9 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_row_pass_fu_1276.store_rows_U0";
                end
                10 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.entry_proc154_U0";
                end
                11 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0";
                end
                12 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_9_U0";
                end
                13 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_10_U0";
                end
                14 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_11_U0";
                end
                15 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_12_U0";
                end
                16 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_13_U0";
                end
                17 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_14_U0";
                end
                18 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_15_U0";
                end
                19 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_16_U0";
                end
                20 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0";
                end
                21 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_17_U0";
                end
                22 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_18_U0";
                end
                23 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_19_U0";
                end
                24 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_20_U0";
                end
                25 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_21_U0";
                end
                26 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_22_U0";
                end
                27 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_23_U0";
                end
                28 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_24_U0";
                end
                29 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_col_pass_fu_1792.store_cols_U0";
                end
                30 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_inv_pass_fu_2319.entry_proc_U0";
                end
                31 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0";
                end
                32 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_1_U0";
                end
                33 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_2_U0";
                end
                34 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_3_U0";
                end
                35 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_4_U0";
                end
                36 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_5_U0";
                end
                37 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_6_U0";
                end
                38 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_7_U0";
                end
                39 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_8_U0";
                end
                40 : begin
                    proc_path = "wiener_stream_wiener_stream.grp_inv_pass_fu_2319.store_tile_U0";
                end
                default : begin
                    proc_path = "unknown";
                end
            endcase
        end
    endfunction

    // print the headlines of deadlock detection
    task print_dl_head;
        begin
            $display("\n//////////////////////////////////////////////////////////////////////////////");
            $display("// ERROR!!! DEADLOCK DETECTED at %0t ns! SIMULATION WILL BE STOPPED! //", $time);
            $display("//////////////////////////////////////////////////////////////////////////////");
            fp = $fopen("deadlock_db.dat", "w");
        end
    endtask

    // print the start of a cycle
    task print_cycle_start(input reg [560:0] proc_path, input integer cycle_id);
        begin
            $display("/////////////////////////");
            $display("// Dependence cycle %0d:", cycle_id);
            $display("// (1): Process: %0s", proc_path);
            $fdisplay(fp, "Dependence_Cycle_ID %0d", cycle_id);
            $fdisplay(fp, "Dependence_Process_ID 1");
            $fdisplay(fp, "Dependence_Process_path %0s", proc_path);
        end
    endtask

    // print the end of deadlock detection
    task print_dl_end(input integer num, input integer record_time);
        begin
            $display("////////////////////////////////////////////////////////////////////////");
            $display("// Totally %0d cycles detected!", num);
            $display("////////////////////////////////////////////////////////////////////////");
            $display("// ERROR!!! DEADLOCK DETECTED at %0t ns! SIMULATION WILL BE STOPPED! //", record_time);
            $display("//////////////////////////////////////////////////////////////////////////////");
            $fdisplay(fp, "Dependence_Cycle_Number %0d", num);
            $fclose(fp);
        end
    endtask

    // print one proc component in the cycle
    task print_cycle_proc_comp(input reg [560:0] proc_path, input integer cycle_comp_id);
        begin
            $display("// (%0d): Process: %0s", cycle_comp_id, proc_path);
            $fdisplay(fp, "Dependence_Process_ID %0d", cycle_comp_id);
            $fdisplay(fp, "Dependence_Process_path %0s", proc_path);
        end
    endtask

    // print one channel component in the cycle
    task print_cycle_chan_comp(input [PROC_NUM - 1:0] dl_vec1, input [PROC_NUM - 1:0] dl_vec2);
        reg [640:0] chan_path;
        integer index1;
        integer index2;
        begin
            index1 = proc_index(dl_vec1);
            index2 = proc_index(dl_vec2);
            case (index1)
                0 : begin // for proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0'
                    case(index2)
                    1: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_25_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_0_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.fin_0_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.load_rows_U0.fin_0_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fin_0_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_0_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_25_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_0_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fin_0_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_0_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_25_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_0_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_25_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_25_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_25_U0_U.if_read} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_25_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_25_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_25_U0_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_25_U0',");
                        end
                    end
                    2: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_26_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_1_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.fin_1_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.load_rows_U0.fin_1_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fin_1_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_1_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_26_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_1_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fin_1_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_1_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_26_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_1_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_26_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_26_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_26_U0_U.if_read} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_26_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_26_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_26_U0_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_26_U0',");
                        end
                    end
                    3: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_27_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_2_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.fin_2_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.load_rows_U0.fin_2_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fin_2_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_2_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_27_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_2_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fin_2_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_2_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_27_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_2_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_27_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_27_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_27_U0_U.if_read} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_27_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_27_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_27_U0_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_27_U0',");
                        end
                    end
                    4: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_28_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_3_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.fin_3_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.load_rows_U0.fin_3_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fin_3_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_3_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_28_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_3_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fin_3_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_3_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_28_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_3_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_28_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_28_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_28_U0_U.if_read} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_28_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_28_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_28_U0_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_28_U0',");
                        end
                    end
                    5: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_29_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_4_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.fin_4_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.load_rows_U0.fin_4_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fin_4_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_4_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_29_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_4_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fin_4_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_4_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_29_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_4_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_29_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_29_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_29_U0_U.if_read} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_29_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_29_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_29_U0_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_29_U0',");
                        end
                    end
                    6: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_30_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_5_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.fin_5_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.load_rows_U0.fin_5_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fin_5_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_5_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_30_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_5_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fin_5_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_5_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_30_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_5_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_30_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_30_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_30_U0_U.if_read} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_30_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_30_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_30_U0_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_30_U0',");
                        end
                    end
                    7: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_31_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_6_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.fin_6_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.load_rows_U0.fin_6_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fin_6_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_6_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_31_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_6_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fin_6_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_6_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_31_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_6_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_31_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_31_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_31_U0_U.if_read} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_31_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_31_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_31_U0_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_31_U0',");
                        end
                    end
                    8: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_7_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.fin_7_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.load_rows_U0.fin_7_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fin_7_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_7_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_7_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fin_7_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_7_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fin_7_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_U0_U.if_read} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_U0_U.if_full_n & grp_row_pass_fu_1276.load_rows_U0.ap_start & ~grp_row_pass_fu_1276.load_rows_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~grp_row_pass_fu_1276.start_for_fft_core_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_U0_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_U0',");
                        end
                    end
                    endcase
                end
                1 : begin // for proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_25_U0'
                    case(index2)
                    0: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_25_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_25_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.fft_core_25_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_25_U0_U.if_write} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_25_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_25_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_25_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_25_U0_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0',");
                        end
                    end
                    9: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.store_rows_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_store_rows_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_store_rows_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.fft_core_25_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.fft_core_25_U0.real_start & (trans_in_cnt_1 == trans_out_cnt_1) & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_store_rows_U0_U.if_read} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_store_rows_U0_U.if_full_n & grp_row_pass_fu_1276.fft_core_25_U0.ap_start & ~grp_row_pass_fu_1276.fft_core_25_U0.real_start & (trans_in_cnt_1 == trans_out_cnt_1) & ~grp_row_pass_fu_1276.start_for_store_rows_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_store_rows_U0_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.store_rows_U0',");
                        end
                    end
                    endcase
                end
                2 : begin // for proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_26_U0'
                    case(index2)
                    0: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_26_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_26_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.fft_core_26_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_26_U0_U.if_write} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_26_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_26_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_26_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_26_U0_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0',");
                        end
                    end
                    endcase
                end
                3 : begin // for proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_27_U0'
                    case(index2)
                    0: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_27_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_27_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.fft_core_27_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_27_U0_U.if_write} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_27_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_27_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_27_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_27_U0_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0',");
                        end
                    end
                    endcase
                end
                4 : begin // for proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_28_U0'
                    case(index2)
                    0: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_28_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_28_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.fft_core_28_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_28_U0_U.if_write} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_28_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_28_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_28_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_28_U0_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0',");
                        end
                    end
                    endcase
                end
                5 : begin // for proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_29_U0'
                    case(index2)
                    0: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_29_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_29_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.fft_core_29_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_29_U0_U.if_write} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_29_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_29_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_29_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_29_U0_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0',");
                        end
                    end
                    endcase
                end
                6 : begin // for proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_30_U0'
                    case(index2)
                    0: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_30_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_30_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.fft_core_30_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_30_U0_U.if_write} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_30_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_30_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_30_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_30_U0_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0',");
                        end
                    end
                    endcase
                end
                7 : begin // for proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_31_U0'
                    case(index2)
                    0: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_31_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_31_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.fft_core_31_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_31_U0_U.if_write} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_31_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_31_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_31_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_31_U0_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0',");
                        end
                    end
                    endcase
                end
                8 : begin // for proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_U0'
                    case(index2)
                    0: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.fft_core_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_fft_core_U0_U.if_write} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_fft_core_U0_U.if_empty_n & grp_row_pass_fu_1276.fft_core_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_fft_core_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_fft_core_U0_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.load_rows_U0',");
                        end
                    end
                    endcase
                end
                9 : begin // for proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.store_rows_U0'
                    case(index2)
                    1: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_25_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_0_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.store_rows_U0.fout_0_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.store_rows_U0.fout_0_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fout_0_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_0_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_25_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_0_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fout_0_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_0_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_25_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_0_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_store_rows_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_store_rows_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.store_rows_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.start_for_store_rows_U0_U.if_write} start_FIFO}
                        if ((~grp_row_pass_fu_1276.start_for_store_rows_U0_U.if_empty_n & grp_row_pass_fu_1276.store_rows_U0.ap_idle & ~grp_row_pass_fu_1276.start_for_store_rows_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.start_for_store_rows_U0_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_25_U0',");
                        end
                    end
                    2: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_26_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_1_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.store_rows_U0.fout_1_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.store_rows_U0.fout_1_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fout_1_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_1_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_26_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_1_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fout_1_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_1_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_26_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_1_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    3: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_27_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_2_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.store_rows_U0.fout_2_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.store_rows_U0.fout_2_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fout_2_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_2_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_27_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_2_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fout_2_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_2_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_27_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_2_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    4: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_28_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_3_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.store_rows_U0.fout_3_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.store_rows_U0.fout_3_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fout_3_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_3_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_28_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_3_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fout_3_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_3_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_28_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_3_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    5: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_29_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_4_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.store_rows_U0.fout_4_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.store_rows_U0.fout_4_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fout_4_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_4_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_29_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_4_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fout_4_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_4_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_29_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_4_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    6: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_30_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_5_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.store_rows_U0.fout_5_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.store_rows_U0.fout_5_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fout_5_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_5_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_30_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_5_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fout_5_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_5_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_30_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_5_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    7: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_31_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_6_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.store_rows_U0.fout_6_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.store_rows_U0.fout_6_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fout_6_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_6_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_31_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_6_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fout_6_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_6_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_31_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_6_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    8: begin //  for dep proc 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_7_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_row_pass_fu_1276.store_rows_U0.fout_7_blk_n data_FIFO}
                        if ((~grp_row_pass_fu_1276.store_rows_U0.fout_7_blk_n)) begin
                            if (~grp_row_pass_fu_1276.fout_7_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_7_U' written by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_7_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_row_pass_fu_1276.fout_7_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_7_U' read by process 'wiener_stream_wiener_stream.grp_row_pass_fu_1276.fft_core_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_row_pass_fu_1276.fout_7_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    endcase
                end
                10 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.entry_proc154_U0'
                    case(index2)
                    20: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.Ln_c_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.entry_proc154_U0.Ln_c_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.entry_proc154_U0.Ln_c_blk_n)) begin
                            if (~grp_col_pass_fu_1792.Ln_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.Ln_c_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.Ln_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.Ln_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.Ln_c_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.Ln_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.ct_c_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.entry_proc154_U0.ct_c_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.entry_proc154_U0.ct_c_blk_n)) begin
                            if (~grp_col_pass_fu_1792.ct_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.ct_c_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.ct_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.ct_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.ct_c_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.ct_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.st_c_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.entry_proc154_U0.st_c_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.entry_proc154_U0.st_c_blk_n)) begin
                            if (~grp_col_pass_fu_1792.st_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.st_c_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.st_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.st_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.st_c_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.st_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_apply_g_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_apply_g_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.entry_proc154_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.entry_proc154_U0.real_start & (trans_in_cnt_3 == trans_out_cnt_3) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_apply_g_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_apply_g_U0_U.if_full_n & grp_col_pass_fu_1792.entry_proc154_U0.ap_start & ~grp_col_pass_fu_1792.entry_proc154_U0.real_start & (trans_in_cnt_3 == trans_out_cnt_3) & ~grp_col_pass_fu_1792.start_for_apply_g_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_apply_g_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0',");
                        end
                    end
                    11: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0'
// for dep channel '' info is :
// blk sig is {{wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.ap_sync_entry_proc154_U0_ap_ready & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.entry_proc154_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.ap_sync_load_cols_U0_ap_ready} input_sync}
                        if ((grp_col_pass_fu_1792.ap_sync_entry_proc154_U0_ap_ready & grp_col_pass_fu_1792.entry_proc154_U0.ap_idle & ~grp_col_pass_fu_1792.ap_sync_load_cols_U0_ap_ready)) begin
                            $display("//      Blocked by input sync logic with process : 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0'");
                        end
                    end
                    endcase
                end
                11 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0'
                    case(index2)
                    12: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_9_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_0_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.cin_0_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.load_cols_U0.cin_0_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cin_0_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_9_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_0_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cin_0_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_9_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_0_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_9_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_9_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_9_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_9_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_9_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_9_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_9_U0',");
                        end
                    end
                    13: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_10_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_1_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.cin_1_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.load_cols_U0.cin_1_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cin_1_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_1_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_10_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_1_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cin_1_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_1_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_10_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_1_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_10_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_10_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_10_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_10_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_10_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_10_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_10_U0',");
                        end
                    end
                    14: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_11_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_2_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.cin_2_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.load_cols_U0.cin_2_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cin_2_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_2_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_11_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_2_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cin_2_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_2_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_11_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_2_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_11_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_11_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_11_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_11_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_11_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_11_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_11_U0',");
                        end
                    end
                    15: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_12_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_3_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.cin_3_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.load_cols_U0.cin_3_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cin_3_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_3_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_12_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_3_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cin_3_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_3_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_12_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_3_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_12_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_12_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_12_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_12_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_12_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_12_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_12_U0',");
                        end
                    end
                    16: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_13_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_4_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.cin_4_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.load_cols_U0.cin_4_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cin_4_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_4_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_13_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_4_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cin_4_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_4_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_13_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_4_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_13_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_13_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_13_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_13_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_13_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_13_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_13_U0',");
                        end
                    end
                    17: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_14_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_5_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.cin_5_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.load_cols_U0.cin_5_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cin_5_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_5_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_14_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_5_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cin_5_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_5_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_14_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_5_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_14_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_14_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_14_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_14_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_14_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_14_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_14_U0',");
                        end
                    end
                    18: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_15_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_6_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.cin_6_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.load_cols_U0.cin_6_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cin_6_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_6_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_15_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_6_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cin_6_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_6_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_15_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_6_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_15_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_15_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_15_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_15_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_15_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_15_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_15_U0',");
                        end
                    end
                    19: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_16_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_7_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.cin_7_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.load_cols_U0.cin_7_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cin_7_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_7_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_16_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_7_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cin_7_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_7_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_16_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cin_7_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_16_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_16_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_16_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_16_U0_U.if_full_n & grp_col_pass_fu_1792.load_cols_U0.ap_start & ~grp_col_pass_fu_1792.load_cols_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~grp_col_pass_fu_1792.start_for_fft_core_16_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_16_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_16_U0',");
                        end
                    end
                    10: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.entry_proc154_U0'
// for dep channel '' info is :
// blk sig is {{wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.ap_sync_load_cols_U0_ap_ready & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.load_cols_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.ap_sync_entry_proc154_U0_ap_ready} input_sync}
                        if ((grp_col_pass_fu_1792.ap_sync_load_cols_U0_ap_ready & grp_col_pass_fu_1792.load_cols_U0.ap_idle & ~grp_col_pass_fu_1792.ap_sync_entry_proc154_U0_ap_ready)) begin
                            $display("//      Blocked by input sync logic with process : 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.entry_proc154_U0'");
                        end
                    end
                    endcase
                end
                12 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_9_U0'
                    case(index2)
                    11: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_9_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_9_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_9_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_9_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_9_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_9_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_9_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_9_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0',");
                        end
                    end
                    endcase
                end
                13 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_10_U0'
                    case(index2)
                    11: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_10_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_10_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_10_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_10_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_10_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_10_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_10_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_10_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0',");
                        end
                    end
                    endcase
                end
                14 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_11_U0'
                    case(index2)
                    11: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_11_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_11_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_11_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_11_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_11_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_11_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_11_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_11_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0',");
                        end
                    end
                    endcase
                end
                15 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_12_U0'
                    case(index2)
                    11: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_12_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_12_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_12_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_12_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_12_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_12_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_12_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_12_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0',");
                        end
                    end
                    endcase
                end
                16 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_13_U0'
                    case(index2)
                    11: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_13_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_13_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_13_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_13_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_13_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_13_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_13_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_13_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0',");
                        end
                    end
                    endcase
                end
                17 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_14_U0'
                    case(index2)
                    11: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_14_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_14_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_14_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_14_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_14_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_14_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_14_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_14_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0',");
                        end
                    end
                    endcase
                end
                18 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_15_U0'
                    case(index2)
                    11: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_15_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_15_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_15_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_15_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_15_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_15_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_15_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_15_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0',");
                        end
                    end
                    endcase
                end
                19 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_16_U0'
                    case(index2)
                    11: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_16_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_16_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_16_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_16_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_16_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_16_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_16_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_16_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.load_cols_U0',");
                        end
                    end
                    endcase
                end
                20 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'
                    case(index2)
                    12: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_9_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_0_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_0_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_0_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_f_0_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_9_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_0_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_f_0_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_9_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_0_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    13: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_10_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_1_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_1_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_1_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_f_1_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_1_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_10_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_1_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_f_1_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_1_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_10_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_1_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    14: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_11_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_2_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_2_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_2_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_f_2_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_2_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_11_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_2_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_f_2_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_2_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_11_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_2_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    15: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_12_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_3_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_3_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_3_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_f_3_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_3_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_12_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_3_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_f_3_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_3_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_12_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_3_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    16: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_13_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_4_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_4_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_4_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_f_4_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_4_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_13_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_4_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_f_4_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_4_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_13_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_4_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    17: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_14_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_5_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_5_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_5_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_f_5_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_5_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_14_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_5_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_f_5_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_5_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_14_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_5_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    18: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_15_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_6_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_6_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_6_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_f_6_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_6_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_15_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_6_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_f_6_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_6_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_15_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_6_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    19: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_16_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_7_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_7_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cout_f_7_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_f_7_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_7_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_16_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_7_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_f_7_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_7_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_16_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_f_7_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    21: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_17_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_0_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_0_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_0_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cinv_0_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_17_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_0_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cinv_0_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_17_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_0_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_17_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_17_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_17_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_17_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_17_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_17_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_17_U0',");
                        end
                    end
                    22: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_18_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_1_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_1_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_1_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cinv_1_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_1_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_18_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_1_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cinv_1_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_1_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_18_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_1_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_18_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_18_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_18_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_18_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_18_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_18_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_18_U0',");
                        end
                    end
                    23: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_19_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_2_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_2_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_2_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cinv_2_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_2_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_19_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_2_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cinv_2_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_2_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_19_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_2_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_19_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_19_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_19_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_19_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_19_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_19_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_19_U0',");
                        end
                    end
                    24: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_20_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_3_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_3_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_3_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cinv_3_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_3_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_20_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_3_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cinv_3_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_3_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_20_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_3_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_20_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_20_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_20_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_20_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_20_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_20_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_20_U0',");
                        end
                    end
                    25: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_21_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_4_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_4_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_4_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cinv_4_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_4_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_21_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_4_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cinv_4_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_4_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_21_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_4_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_21_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_21_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_21_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_21_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_21_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_21_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_21_U0',");
                        end
                    end
                    26: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_22_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_5_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_5_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_5_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cinv_5_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_5_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_22_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_5_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cinv_5_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_5_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_22_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_5_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_22_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_22_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_22_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_22_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_22_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_22_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_22_U0',");
                        end
                    end
                    27: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_23_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_6_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_6_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_6_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cinv_6_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_6_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_23_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_6_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cinv_6_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_6_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_23_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_6_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_23_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_23_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_23_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_23_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_23_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_23_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_23_U0',");
                        end
                    end
                    28: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_24_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_7_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_7_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.grp_apply_g_Pipeline_VITIS_LOOP_133_1_VITIS_LOOP_134_2_fu_118.cinv_7_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cinv_7_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_7_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_24_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_7_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cinv_7_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_7_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_24_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cinv_7_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_24_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_24_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_24_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_24_U0_U.if_full_n & grp_col_pass_fu_1792.apply_g_U0.ap_start & ~grp_col_pass_fu_1792.apply_g_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~grp_col_pass_fu_1792.start_for_fft_core_24_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_24_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_24_U0',");
                        end
                    end
                    10: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.entry_proc154_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.Ln_c_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.Ln_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.Ln_blk_n)) begin
                            if (~grp_col_pass_fu_1792.Ln_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.Ln_c_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.entry_proc154_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.Ln_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.Ln_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.Ln_c_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.entry_proc154_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.Ln_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.ct_c_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.ct_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.ct_blk_n)) begin
                            if (~grp_col_pass_fu_1792.ct_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.ct_c_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.entry_proc154_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.ct_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.ct_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.ct_c_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.entry_proc154_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.ct_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.st_c_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.st_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.apply_g_U0.st_blk_n)) begin
                            if (~grp_col_pass_fu_1792.st_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.st_c_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.entry_proc154_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.st_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.st_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.st_c_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.entry_proc154_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.st_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_apply_g_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_apply_g_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.apply_g_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_apply_g_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_apply_g_U0_U.if_empty_n & grp_col_pass_fu_1792.apply_g_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_apply_g_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_apply_g_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.entry_proc154_U0',");
                        end
                    end
                    endcase
                end
                21 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_17_U0'
                    case(index2)
                    20: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_17_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_17_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_17_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_17_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_17_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_17_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_17_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_17_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0',");
                        end
                    end
                    29: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.store_cols_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_store_cols_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_store_cols_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_17_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_17_U0.real_start & (trans_in_cnt_5 == trans_out_cnt_5) & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_store_cols_U0_U.if_read} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_store_cols_U0_U.if_full_n & grp_col_pass_fu_1792.fft_core_17_U0.ap_start & ~grp_col_pass_fu_1792.fft_core_17_U0.real_start & (trans_in_cnt_5 == trans_out_cnt_5) & ~grp_col_pass_fu_1792.start_for_store_cols_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_store_cols_U0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.store_cols_U0',");
                        end
                    end
                    endcase
                end
                22 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_18_U0'
                    case(index2)
                    20: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_18_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_18_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_18_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_18_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_18_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_18_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_18_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_18_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0',");
                        end
                    end
                    endcase
                end
                23 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_19_U0'
                    case(index2)
                    20: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_19_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_19_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_19_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_19_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_19_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_19_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_19_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_19_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0',");
                        end
                    end
                    endcase
                end
                24 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_20_U0'
                    case(index2)
                    20: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_20_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_20_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_20_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_20_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_20_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_20_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_20_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_20_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0',");
                        end
                    end
                    endcase
                end
                25 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_21_U0'
                    case(index2)
                    20: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_21_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_21_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_21_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_21_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_21_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_21_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_21_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_21_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0',");
                        end
                    end
                    endcase
                end
                26 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_22_U0'
                    case(index2)
                    20: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_22_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_22_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_22_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_22_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_22_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_22_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_22_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_22_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0',");
                        end
                    end
                    endcase
                end
                27 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_23_U0'
                    case(index2)
                    20: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_23_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_23_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_23_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_23_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_23_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_23_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_23_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_23_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0',");
                        end
                    end
                    endcase
                end
                28 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_24_U0'
                    case(index2)
                    20: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_24_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_24_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.fft_core_24_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_fft_core_24_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_fft_core_24_U0_U.if_empty_n & grp_col_pass_fu_1792.fft_core_24_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_fft_core_24_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_fft_core_24_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.apply_g_U0',");
                        end
                    end
                    endcase
                end
                29 : begin // for proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.store_cols_U0'
                    case(index2)
                    21: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_17_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_0_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.store_cols_U0.cout_i_0_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.store_cols_U0.cout_i_0_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_i_0_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_17_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_0_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_i_0_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_0_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_17_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_0_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_store_cols_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_store_cols_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.store_cols_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.start_for_store_cols_U0_U.if_write} start_FIFO}
                        if ((~grp_col_pass_fu_1792.start_for_store_cols_U0_U.if_empty_n & grp_col_pass_fu_1792.store_cols_U0.ap_idle & ~grp_col_pass_fu_1792.start_for_store_cols_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.start_for_store_cols_U0_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_17_U0',");
                        end
                    end
                    22: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_18_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_1_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.store_cols_U0.cout_i_1_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.store_cols_U0.cout_i_1_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_i_1_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_1_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_18_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_1_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_i_1_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_1_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_18_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_1_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    23: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_19_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_2_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.store_cols_U0.cout_i_2_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.store_cols_U0.cout_i_2_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_i_2_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_2_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_19_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_2_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_i_2_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_2_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_19_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_2_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    24: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_20_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_3_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.store_cols_U0.cout_i_3_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.store_cols_U0.cout_i_3_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_i_3_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_3_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_20_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_3_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_i_3_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_3_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_20_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_3_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    25: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_21_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_4_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.store_cols_U0.cout_i_4_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.store_cols_U0.cout_i_4_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_i_4_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_4_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_21_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_4_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_i_4_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_4_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_21_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_4_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    26: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_22_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_5_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.store_cols_U0.cout_i_5_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.store_cols_U0.cout_i_5_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_i_5_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_5_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_22_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_5_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_i_5_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_5_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_22_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_5_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    27: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_23_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_6_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.store_cols_U0.cout_i_6_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.store_cols_U0.cout_i_6_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_i_6_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_6_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_23_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_6_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_i_6_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_6_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_23_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_6_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    28: begin //  for dep proc 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_24_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_7_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_col_pass_fu_1792.store_cols_U0.cout_i_7_blk_n data_FIFO}
                        if ((~grp_col_pass_fu_1792.store_cols_U0.cout_i_7_blk_n)) begin
                            if (~grp_col_pass_fu_1792.cout_i_7_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_7_U' written by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_24_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_7_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_col_pass_fu_1792.cout_i_7_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_7_U' read by process 'wiener_stream_wiener_stream.grp_col_pass_fu_1792.fft_core_24_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_col_pass_fu_1792.cout_i_7_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    endcase
                end
                30 : begin // for proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.entry_proc_U0'
                    case(index2)
                    40: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.store_tile_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.ox_c_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.entry_proc_U0.ox_c_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.entry_proc_U0.ox_c_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.ox_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.ox_c_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.store_tile_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.ox_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.ox_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.ox_c_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.store_tile_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.ox_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.oy_c_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.entry_proc_U0.oy_c_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.entry_proc_U0.oy_c_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.oy_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.oy_c_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.store_tile_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.oy_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.oy_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.oy_c_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.store_tile_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.oy_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.vx_c_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.entry_proc_U0.vx_c_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.entry_proc_U0.vx_c_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.vx_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.vx_c_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.store_tile_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.vx_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.vx_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.vx_c_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.store_tile_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.vx_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_store_tile_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_store_tile_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.entry_proc_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.entry_proc_U0.real_start & (trans_in_cnt_7 == trans_out_cnt_7) & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_store_tile_U0_U.if_read} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_store_tile_U0_U.if_full_n & grp_inv_pass_fu_2319.entry_proc_U0.ap_start & ~grp_inv_pass_fu_2319.entry_proc_U0.real_start & (trans_in_cnt_7 == trans_out_cnt_7) & ~grp_inv_pass_fu_2319.start_for_store_tile_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_store_tile_U0_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.store_tile_U0',");
                        end
                    end
                    31: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0'
// for dep channel '' info is :
// blk sig is {{wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.ap_sync_entry_proc_U0_ap_ready & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.entry_proc_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.ap_sync_load_rows2_U0_ap_ready} input_sync}
                        if ((grp_inv_pass_fu_2319.ap_sync_entry_proc_U0_ap_ready & grp_inv_pass_fu_2319.entry_proc_U0.ap_idle & ~grp_inv_pass_fu_2319.ap_sync_load_rows2_U0_ap_ready)) begin
                            $display("//      Blocked by input sync logic with process : 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0'");
                        end
                    end
                    endcase
                end
                31 : begin // for proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0'
                    case(index2)
                    32: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_1_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_0_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.iin_0_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.load_rows2_U0.iin_0_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iin_0_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_0_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_1_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_0_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iin_0_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_0_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_1_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_0_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U.if_read} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_1_U0',");
                        end
                    end
                    33: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_2_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_1_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.iin_1_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.load_rows2_U0.iin_1_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iin_1_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_1_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_2_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_1_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iin_1_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_1_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_2_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_1_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U.if_read} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_2_U0',");
                        end
                    end
                    34: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_3_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_2_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.iin_2_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.load_rows2_U0.iin_2_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iin_2_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_2_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_3_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_2_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iin_2_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_2_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_3_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_2_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U.if_read} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_3_U0',");
                        end
                    end
                    35: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_4_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_3_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.iin_3_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.load_rows2_U0.iin_3_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iin_3_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_3_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_4_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_3_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iin_3_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_3_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_4_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_3_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U.if_read} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_4_U0',");
                        end
                    end
                    36: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_5_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_4_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.iin_4_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.load_rows2_U0.iin_4_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iin_4_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_4_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_5_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_4_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iin_4_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_4_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_5_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_4_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U.if_read} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_5_U0',");
                        end
                    end
                    37: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_6_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_5_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.iin_5_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.load_rows2_U0.iin_5_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iin_5_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_5_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_6_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_5_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iin_5_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_5_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_6_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_5_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U.if_read} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_6_U0',");
                        end
                    end
                    38: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_7_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_6_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.iin_6_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.load_rows2_U0.iin_6_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iin_6_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_6_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_7_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_6_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iin_6_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_6_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_7_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_6_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U.if_read} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_7_U0',");
                        end
                    end
                    39: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_8_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_7_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.iin_7_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.load_rows2_U0.iin_7_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iin_7_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_7_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_8_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_7_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iin_7_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_7_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_8_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iin_7_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U.if_full_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U.if_read} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U.if_full_n & grp_inv_pass_fu_2319.load_rows2_U0.ap_start & ~grp_inv_pass_fu_2319.load_rows2_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U.if_read)) begin
                            $display("//      Blocked by full output start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_8_U0',");
                        end
                    end
                    30: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.entry_proc_U0'
// for dep channel '' info is :
// blk sig is {{wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.ap_sync_load_rows2_U0_ap_ready & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.load_rows2_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.ap_sync_entry_proc_U0_ap_ready} input_sync}
                        if ((grp_inv_pass_fu_2319.ap_sync_load_rows2_U0_ap_ready & grp_inv_pass_fu_2319.load_rows2_U0.ap_idle & ~grp_inv_pass_fu_2319.ap_sync_entry_proc_U0_ap_ready)) begin
                            $display("//      Blocked by input sync logic with process : 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.entry_proc_U0'");
                        end
                    end
                    endcase
                end
                32 : begin // for proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_1_U0'
                    case(index2)
                    31: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.fft_core_1_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U.if_write} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_1_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_1_U0_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0',");
                        end
                    end
                    endcase
                end
                33 : begin // for proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_2_U0'
                    case(index2)
                    31: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.fft_core_2_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U.if_write} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_2_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_2_U0_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0',");
                        end
                    end
                    endcase
                end
                34 : begin // for proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_3_U0'
                    case(index2)
                    31: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.fft_core_3_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U.if_write} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_3_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_3_U0_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0',");
                        end
                    end
                    endcase
                end
                35 : begin // for proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_4_U0'
                    case(index2)
                    31: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.fft_core_4_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U.if_write} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_4_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_4_U0_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0',");
                        end
                    end
                    endcase
                end
                36 : begin // for proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_5_U0'
                    case(index2)
                    31: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.fft_core_5_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U.if_write} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_5_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_5_U0_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0',");
                        end
                    end
                    endcase
                end
                37 : begin // for proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_6_U0'
                    case(index2)
                    31: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.fft_core_6_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U.if_write} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_6_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_6_U0_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0',");
                        end
                    end
                    endcase
                end
                38 : begin // for proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_7_U0'
                    case(index2)
                    31: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.fft_core_7_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U.if_write} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_7_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_7_U0_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0',");
                        end
                    end
                    endcase
                end
                39 : begin // for proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_8_U0'
                    case(index2)
                    31: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.fft_core_8_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U.if_write} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U.if_empty_n & grp_inv_pass_fu_2319.fft_core_8_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_fft_core_8_U0_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.load_rows2_U0',");
                        end
                    end
                    endcase
                end
                40 : begin // for proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.store_tile_U0'
                    case(index2)
                    32: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_1_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_0_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_0_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_0_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iout_0_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_0_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_1_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_0_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iout_0_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_0_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_1_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_0_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    33: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_2_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_1_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_1_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_1_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iout_1_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_1_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_2_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_1_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iout_1_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_1_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_2_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_1_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    34: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_3_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_2_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_2_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_2_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iout_2_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_2_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_3_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_2_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iout_2_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_2_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_3_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_2_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    35: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_4_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_3_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_3_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_3_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iout_3_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_3_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_4_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_3_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iout_3_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_3_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_4_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_3_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    36: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_5_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_4_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_4_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_4_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iout_4_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_4_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_5_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_4_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iout_4_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_4_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_5_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_4_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    37: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_6_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_5_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_5_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_5_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iout_5_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_5_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_6_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_5_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iout_5_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_5_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_6_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_5_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    38: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_7_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_6_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_6_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_6_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iout_6_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_6_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_7_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_6_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iout_6_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_6_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_7_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_6_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    39: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_8_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_7_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_7_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.store_tile_U0.grp_store_tile_Pipeline_VITIS_LOOP_161_1_VITIS_LOOP_162_2_fu_114.iout_7_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.iout_7_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_7_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_8_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_7_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.iout_7_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_7_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.fft_core_8_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.iout_7_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    30: begin //  for dep proc 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.entry_proc_U0'
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.ox_c_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.store_tile_U0.ox_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.store_tile_U0.ox_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.ox_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.ox_c_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.entry_proc_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.ox_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.ox_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.ox_c_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.entry_proc_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.ox_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.oy_c_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.store_tile_U0.oy_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.store_tile_U0.oy_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.oy_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.oy_c_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.entry_proc_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.oy_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.oy_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.oy_c_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.entry_proc_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.oy_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.vx_c_U' info is :
// blk sig is {~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.store_tile_U0.vx_blk_n data_FIFO}
                        if ((~grp_inv_pass_fu_2319.store_tile_U0.vx_blk_n)) begin
                            if (~grp_inv_pass_fu_2319.vx_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.vx_c_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.entry_proc_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.vx_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grp_inv_pass_fu_2319.vx_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.vx_c_U' read by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.entry_proc_U0'");
                                $fdisplay(fp, "Dependence_Channel_path wiener_stream_wiener_stream.grp_inv_pass_fu_2319.vx_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
// for dep channel 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_store_tile_U0_U' info is :
// blk sig is {{~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_store_tile_U0_U.if_empty_n & wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.store_tile_U0.ap_idle & ~wiener_stream_wiener_stream_inst.grp_inv_pass_fu_2319.start_for_store_tile_U0_U.if_write} start_FIFO}
                        if ((~grp_inv_pass_fu_2319.start_for_store_tile_U0_U.if_empty_n & grp_inv_pass_fu_2319.store_tile_U0.ap_idle & ~grp_inv_pass_fu_2319.start_for_store_tile_U0_U.if_write)) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.start_for_store_tile_U0_U' written by process 'wiener_stream_wiener_stream.grp_inv_pass_fu_2319.entry_proc_U0',");
                        end
                    end
                    endcase
                end
            endcase
        end
    endtask

    // report
    initial begin : report_deadlock
        integer cycle_id;
        integer cycle_comp_id;
        integer record_time;
        wait (dl_reset == 1);
        cycle_id = 1;
        record_time = 0;
        while (1) begin
            @ (negedge dl_clock);
            case (CS_fsm)
                ST_DL_DETECTED: begin
                    cycle_comp_id = 2;
                    if (dl_detect_reg != dl_done_reg && stop_report_path == 1'b0) begin
                        if (dl_done_reg == 'b0) begin
                            print_dl_head;
                            record_time = $time;
                        end
                        print_cycle_start(proc_path(origin), cycle_id);
                        cycle_id = cycle_id + 1;
                    end
                    else begin
                        print_dl_end((cycle_id - 1),record_time);
                        @(negedge dl_clock);
                        @(negedge dl_clock);
                        $finish;
                    end
                end
                ST_DL_REPORT: begin
                    if ((|(dl_in_vec)) & ~(|(dl_in_vec & origin_reg)) & ~(|(reported_proc & dl_in_vec))) begin
                        print_cycle_chan_comp(dl_in_vec_reg, dl_in_vec);
                        print_cycle_proc_comp(proc_path(dl_in_vec), cycle_comp_id);
                        cycle_comp_id = cycle_comp_id + 1;
                    end
                    else if (~(|(dl_in_vec)))begin
                        print_cycle_chan_comp(dl_in_vec_reg, dl_in_vec);
                    end
                end
            endcase
        end
    end
 
