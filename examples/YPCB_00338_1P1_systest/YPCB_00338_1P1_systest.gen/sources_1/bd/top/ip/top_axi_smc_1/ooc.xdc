# aclk {FREQ_HZ 133333333 CLK_DOMAIN top_mig_7series_0_0_c0_ui_clk PHASE 0} aclk1 {FREQ_HZ 100000000 CLK_DOMAIN /clk_wiz_1_clk_out1 PHASE 0.0} aclk2 {FREQ_HZ 133333333 CLK_DOMAIN top_mig_7series_0_0_c1_ui_clk PHASE 0} aclk3 {FREQ_HZ 62500000 CLK_DOMAIN top_xdma_0_0_axi_aclk PHASE 0.0} aclk4 {FREQ_HZ 250000000 CLK_DOMAIN /clk_wiz_1_clk_out1 PHASE 0.0}
# Clock Domain: top_mig_7series_0_0_c0_ui_clk
create_clock -name aclk -period 7.500 [get_ports aclk]
# Clock Domain: /clk_wiz_1_clk_out1
create_clock -name aclk1 -period 10.000 [get_ports aclk1]
# Clock Domain: top_mig_7series_0_0_c1_ui_clk
create_clock -name aclk2 -period 7.500 [get_ports aclk2]
# Clock Domain: top_xdma_0_0_axi_aclk
create_clock -name aclk3 -period 16.000 [get_ports aclk3]
# Generated clocks
create_generated_clock -name aclk4 -source [get_ports aclk1] -multiply_by 5 -divide_by 2 [get_ports aclk4]
