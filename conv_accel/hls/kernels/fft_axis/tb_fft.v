`timescale 1ns/1ps
module tb_fft;
  reg aclk=0, aclken=1, aresetn=0;
  reg [47:0] s_tdata=0; reg s_tvalid=0, s_tlast=0; wire s_tready;
  reg [7:0] cfg_tdata=8'h00; reg cfg_tvalid=0;
  wire [79:0] m_tdata; wire m_tvalid, m_tlast;
  integer sent=0, out_count=0, first_cycle=-1, last_cycle=-1, cycle=0;
  integer frame=0;

  fft_axis uut (
    .aclk(aclk), .aclken(aclken), .aresetn(aresetn),
    .s_axis_config_tdata(cfg_tdata), .s_axis_config_tvalid(cfg_tvalid),
    .s_axis_data_tdata(s_tdata), .s_axis_data_tvalid(s_tvalid),
    .s_axis_data_tready(s_tready), .s_axis_data_tlast(s_tlast),
    .m_axis_data_tdata(m_tdata), .m_axis_data_tvalid(m_tvalid), .m_axis_data_tlast(m_tlast)
  );

  always #2 aclk = ~aclk;
  always @(posedge aclk) cycle <= cycle + 1;

  always @(posedge aclk) begin
    if (!aresetn) begin s_tvalid<=0; s_tlast<=0; sent<=0; end
    else begin
      if (sent < 512) begin
        s_tdata <= {sent[23:0], 24'h0};
        s_tvalid <= 1;
        s_tlast <= ((sent % 256) == 255);
        if (s_tready) sent <= sent + 1;
      end else begin
        s_tvalid <= 0; s_tlast <= 0;
      end
    end
  end

  always @(posedge aclk) begin
    if (m_tvalid) begin
      if (first_cycle < 0) first_cycle = cycle;
      last_cycle = cycle;
      out_count <= out_count + 1;
      if (m_tlast) begin
        frame = frame + 1;
        $display("frame %0d end at cycle %0d", frame, cycle);
      end
    end
  end

  initial begin
    aresetn = 0; cfg_tvalid = 0;
    repeat(10) @(posedge aclk);
    aresetn = 1; cfg_tvalid = 1;
    wait(out_count == 512);
    @(posedge aclk);
    $display("RESULT: out=%0d first=%0d last=%0d span=%0d", out_count, first_cycle, last_cycle, last_cycle-first_cycle+1);
    $finish;
  end
endmodule
