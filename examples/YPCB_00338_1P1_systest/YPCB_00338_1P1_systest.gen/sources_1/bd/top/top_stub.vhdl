-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.2 (lin64) Build 5239630 Fri Nov 08 22:34:34 MST 2024
-- Date        : Sun Nov  1 20:37:50 2026
-- Host        : selbizopc-System-Product-Name running 64-bit Ubuntu 24.04.5 LTS
-- Command     : write_vhdl -force -mode synth_stub {/mnt/data/FPGA
--               projects/ypcb_00338_1p1_hack/examples/YPCB_00338_1P1_systest/YPCB_00338_1P1_systest.gen/sources_1/bd/top/top_stub.vhdl}
-- Design      : top
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k480tffg1156-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
  Port ( 
    DDR3_0_addr : out STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR3_0_ba : out STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR3_0_cas_n : out STD_LOGIC;
    DDR3_0_ck_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR3_0_ck_p : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR3_0_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR3_0_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR3_0_dq : inout STD_LOGIC_VECTOR ( 71 downto 0 );
    DDR3_0_dqs_n : inout STD_LOGIC_VECTOR ( 8 downto 0 );
    DDR3_0_dqs_p : inout STD_LOGIC_VECTOR ( 8 downto 0 );
    DDR3_0_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR3_0_ras_n : out STD_LOGIC;
    DDR3_0_reset_n : out STD_LOGIC;
    DDR3_0_we_n : out STD_LOGIC;
    DDR3_1_addr : out STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR3_1_ba : out STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR3_1_cas_n : out STD_LOGIC;
    DDR3_1_ck_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR3_1_ck_p : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR3_1_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR3_1_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR3_1_dq : inout STD_LOGIC_VECTOR ( 71 downto 0 );
    DDR3_1_dqs_n : inout STD_LOGIC_VECTOR ( 8 downto 0 );
    DDR3_1_dqs_p : inout STD_LOGIC_VECTOR ( 8 downto 0 );
    DDR3_1_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
    DDR3_1_ras_n : out STD_LOGIC;
    DDR3_1_reset_n : out STD_LOGIC;
    DDR3_1_we_n : out STD_LOGIC;
    DDR3_CLK_0_clk_n : in STD_LOGIC;
    DDR3_CLK_0_clk_p : in STD_LOGIC;
    DDR3_CLK_1_clk_n : in STD_LOGIC;
    DDR3_CLK_1_clk_p : in STD_LOGIC;
    SYS_CLK : in STD_LOGIC;
    SYS_RSTN : in STD_LOGIC;
    alert_lm73_tri_i : in STD_LOGIC;
    bpi_flash_addr : out STD_LOGIC_VECTOR ( 25 downto 1 );
    bpi_flash_adv_ldn : out STD_LOGIC;
    bpi_flash_ce_n : out STD_LOGIC;
    bpi_flash_dq_i : in STD_LOGIC_VECTOR ( 15 downto 0 );
    bpi_flash_dq_o : out STD_LOGIC_VECTOR ( 15 downto 0 );
    bpi_flash_dq_t : out STD_LOGIC_VECTOR ( 15 downto 0 );
    bpi_flash_oen : out STD_LOGIC;
    bpi_flash_wen : out STD_LOGIC;
    iic_lm73_scl_i : in STD_LOGIC;
    iic_lm73_scl_o : out STD_LOGIC;
    iic_lm73_scl_t : out STD_LOGIC;
    iic_lm73_sda_i : in STD_LOGIC;
    iic_lm73_sda_o : out STD_LOGIC;
    iic_lm73_sda_t : out STD_LOGIC;
    iic_pcie_scl_i : in STD_LOGIC;
    iic_pcie_scl_o : out STD_LOGIC;
    iic_pcie_scl_t : out STD_LOGIC;
    iic_pcie_sda_i : in STD_LOGIC;
    iic_pcie_sda_o : out STD_LOGIC;
    iic_pcie_sda_t : out STD_LOGIC;
    led_3bits_tri_o : out STD_LOGIC_VECTOR ( 2 downto 0 );
    pci_express_x8_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    pci_express_x8_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    pci_express_x8_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    pci_express_x8_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    pcie_perstn : in STD_LOGIC;
    pcie_refclk_clk_n : in STD_LOGIC;
    pcie_refclk_clk_p : in STD_LOGIC
  );

  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of top : entity is "top,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=top,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=38,numReposBlks=26,numNonXlnxBlks=0,numHierBlks=12,maxHierDepth=1,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_axi4_cnt=20,da_board_cnt=8,da_clkrst_cnt=1,da_mb_cnt=1,da_xdma_cnt=1,synth_mode=Singular}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of top : entity is "top.hwdef";
end top;

architecture stub of top is
  attribute syn_black_box : boolean;
  attribute black_box_pad_pin : string;
  attribute syn_black_box of stub : architecture is true;
  attribute black_box_pad_pin of stub : architecture is "DDR3_0_addr[14:0],DDR3_0_ba[2:0],DDR3_0_cas_n,DDR3_0_ck_n[0:0],DDR3_0_ck_p[0:0],DDR3_0_cke[0:0],DDR3_0_cs_n[0:0],DDR3_0_dq[71:0],DDR3_0_dqs_n[8:0],DDR3_0_dqs_p[8:0],DDR3_0_odt[0:0],DDR3_0_ras_n,DDR3_0_reset_n,DDR3_0_we_n,DDR3_1_addr[14:0],DDR3_1_ba[2:0],DDR3_1_cas_n,DDR3_1_ck_n[0:0],DDR3_1_ck_p[0:0],DDR3_1_cke[0:0],DDR3_1_cs_n[0:0],DDR3_1_dq[71:0],DDR3_1_dqs_n[8:0],DDR3_1_dqs_p[8:0],DDR3_1_odt[0:0],DDR3_1_ras_n,DDR3_1_reset_n,DDR3_1_we_n,DDR3_CLK_0_clk_n,DDR3_CLK_0_clk_p,DDR3_CLK_1_clk_n,DDR3_CLK_1_clk_p,SYS_CLK,SYS_RSTN,alert_lm73_tri_i,bpi_flash_addr[25:1],bpi_flash_adv_ldn,bpi_flash_ce_n,bpi_flash_dq_i[15:0],bpi_flash_dq_o[15:0],bpi_flash_dq_t[15:0],bpi_flash_oen,bpi_flash_wen,iic_lm73_scl_i,iic_lm73_scl_o,iic_lm73_scl_t,iic_lm73_sda_i,iic_lm73_sda_o,iic_lm73_sda_t,iic_pcie_scl_i,iic_pcie_scl_o,iic_pcie_scl_t,iic_pcie_sda_i,iic_pcie_sda_o,iic_pcie_sda_t,led_3bits_tri_o[2:0],pci_express_x8_rxn[0:0],pci_express_x8_rxp[0:0],pci_express_x8_txn[0:0],pci_express_x8_txp[0:0],pcie_perstn,pcie_refclk_clk_n,pcie_refclk_clk_p";
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of DDR3_0_addr : signal is "xilinx.com:interface:ddrx:1.0 DDR3_0 ADDR";
  attribute X_INTERFACE_MODE : string;
  attribute X_INTERFACE_MODE of DDR3_0_addr : signal is "Master";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of DDR3_0_addr : signal is "XIL_INTERFACENAME DDR3_0, AXI_ARBITRATION_SCHEME TDM, BURST_LENGTH 8, CAN_DEBUG false, CAS_LATENCY 11, CAS_WRITE_LATENCY 11, CS_ENABLED true, DATA_MASK_ENABLED true, DATA_WIDTH 8, MEMORY_TYPE COMPONENTS, MEM_ADDR_MAP ROW_COLUMN_BANK, SLOT Single, TIMEPERIOD_PS 1250";
  attribute X_INTERFACE_INFO of DDR3_0_ba : signal is "xilinx.com:interface:ddrx:1.0 DDR3_0 BA";
  attribute X_INTERFACE_INFO of DDR3_0_cas_n : signal is "xilinx.com:interface:ddrx:1.0 DDR3_0 CAS_N";
  attribute X_INTERFACE_INFO of DDR3_0_ck_n : signal is "xilinx.com:interface:ddrx:1.0 DDR3_0 CK_N";
  attribute X_INTERFACE_INFO of DDR3_0_ck_p : signal is "xilinx.com:interface:ddrx:1.0 DDR3_0 CK_P";
  attribute X_INTERFACE_INFO of DDR3_0_cke : signal is "xilinx.com:interface:ddrx:1.0 DDR3_0 CKE";
  attribute X_INTERFACE_INFO of DDR3_0_cs_n : signal is "xilinx.com:interface:ddrx:1.0 DDR3_0 CS_N";
  attribute X_INTERFACE_INFO of DDR3_0_dq : signal is "xilinx.com:interface:ddrx:1.0 DDR3_0 DQ";
  attribute X_INTERFACE_INFO of DDR3_0_dqs_n : signal is "xilinx.com:interface:ddrx:1.0 DDR3_0 DQS_N";
  attribute X_INTERFACE_INFO of DDR3_0_dqs_p : signal is "xilinx.com:interface:ddrx:1.0 DDR3_0 DQS_P";
  attribute X_INTERFACE_INFO of DDR3_0_odt : signal is "xilinx.com:interface:ddrx:1.0 DDR3_0 ODT";
  attribute X_INTERFACE_INFO of DDR3_0_ras_n : signal is "xilinx.com:interface:ddrx:1.0 DDR3_0 RAS_N";
  attribute X_INTERFACE_INFO of DDR3_0_reset_n : signal is "xilinx.com:interface:ddrx:1.0 DDR3_0 RESET_N";
  attribute X_INTERFACE_INFO of DDR3_0_we_n : signal is "xilinx.com:interface:ddrx:1.0 DDR3_0 WE_N";
  attribute X_INTERFACE_INFO of DDR3_1_addr : signal is "xilinx.com:interface:ddrx:1.0 DDR3_1 ADDR";
  attribute X_INTERFACE_MODE of DDR3_1_addr : signal is "Master";
  attribute X_INTERFACE_PARAMETER of DDR3_1_addr : signal is "XIL_INTERFACENAME DDR3_1, AXI_ARBITRATION_SCHEME TDM, BURST_LENGTH 8, CAN_DEBUG false, CAS_LATENCY 11, CAS_WRITE_LATENCY 11, CS_ENABLED true, DATA_MASK_ENABLED true, DATA_WIDTH 8, MEMORY_TYPE COMPONENTS, MEM_ADDR_MAP ROW_COLUMN_BANK, SLOT Single, TIMEPERIOD_PS 1250";
  attribute X_INTERFACE_INFO of DDR3_1_ba : signal is "xilinx.com:interface:ddrx:1.0 DDR3_1 BA";
  attribute X_INTERFACE_INFO of DDR3_1_cas_n : signal is "xilinx.com:interface:ddrx:1.0 DDR3_1 CAS_N";
  attribute X_INTERFACE_INFO of DDR3_1_ck_n : signal is "xilinx.com:interface:ddrx:1.0 DDR3_1 CK_N";
  attribute X_INTERFACE_INFO of DDR3_1_ck_p : signal is "xilinx.com:interface:ddrx:1.0 DDR3_1 CK_P";
  attribute X_INTERFACE_INFO of DDR3_1_cke : signal is "xilinx.com:interface:ddrx:1.0 DDR3_1 CKE";
  attribute X_INTERFACE_INFO of DDR3_1_cs_n : signal is "xilinx.com:interface:ddrx:1.0 DDR3_1 CS_N";
  attribute X_INTERFACE_INFO of DDR3_1_dq : signal is "xilinx.com:interface:ddrx:1.0 DDR3_1 DQ";
  attribute X_INTERFACE_INFO of DDR3_1_dqs_n : signal is "xilinx.com:interface:ddrx:1.0 DDR3_1 DQS_N";
  attribute X_INTERFACE_INFO of DDR3_1_dqs_p : signal is "xilinx.com:interface:ddrx:1.0 DDR3_1 DQS_P";
  attribute X_INTERFACE_INFO of DDR3_1_odt : signal is "xilinx.com:interface:ddrx:1.0 DDR3_1 ODT";
  attribute X_INTERFACE_INFO of DDR3_1_ras_n : signal is "xilinx.com:interface:ddrx:1.0 DDR3_1 RAS_N";
  attribute X_INTERFACE_INFO of DDR3_1_reset_n : signal is "xilinx.com:interface:ddrx:1.0 DDR3_1 RESET_N";
  attribute X_INTERFACE_INFO of DDR3_1_we_n : signal is "xilinx.com:interface:ddrx:1.0 DDR3_1 WE_N";
  attribute X_INTERFACE_INFO of DDR3_CLK_0_clk_n : signal is "xilinx.com:interface:diff_clock:1.0 DDR3_CLK_0 CLK_N";
  attribute X_INTERFACE_MODE of DDR3_CLK_0_clk_n : signal is "Slave";
  attribute X_INTERFACE_PARAMETER of DDR3_CLK_0_clk_n : signal is "XIL_INTERFACENAME DDR3_CLK_0, CAN_DEBUG false, FREQ_HZ 100000000";
  attribute X_INTERFACE_INFO of DDR3_CLK_0_clk_p : signal is "xilinx.com:interface:diff_clock:1.0 DDR3_CLK_0 CLK_P";
  attribute X_INTERFACE_INFO of DDR3_CLK_1_clk_n : signal is "xilinx.com:interface:diff_clock:1.0 DDR3_CLK_1 CLK_N";
  attribute X_INTERFACE_MODE of DDR3_CLK_1_clk_n : signal is "Slave";
  attribute X_INTERFACE_PARAMETER of DDR3_CLK_1_clk_n : signal is "XIL_INTERFACENAME DDR3_CLK_1, CAN_DEBUG false, FREQ_HZ 100000000";
  attribute X_INTERFACE_INFO of DDR3_CLK_1_clk_p : signal is "xilinx.com:interface:diff_clock:1.0 DDR3_CLK_1 CLK_P";
  attribute X_INTERFACE_INFO of SYS_CLK : signal is "xilinx.com:signal:clock:1.0 CLK.SYS_CLK CLK";
  attribute X_INTERFACE_PARAMETER of SYS_CLK : signal is "XIL_INTERFACENAME CLK.SYS_CLK, CLK_DOMAIN top_SYS_CLK, FREQ_HZ 50000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of SYS_RSTN : signal is "xilinx.com:signal:reset:1.0 RST.SYS_RSTN RST";
  attribute X_INTERFACE_PARAMETER of SYS_RSTN : signal is "XIL_INTERFACENAME RST.SYS_RSTN, INSERT_VIP 0, POLARITY ACTIVE_LOW";
  attribute X_INTERFACE_INFO of alert_lm73_tri_i : signal is "xilinx.com:interface:gpio:1.0 alert_lm73 TRI_I";
  attribute X_INTERFACE_MODE of alert_lm73_tri_i : signal is "Master";
  attribute X_INTERFACE_INFO of bpi_flash_addr : signal is "xilinx.com:interface:emc:1.0 bpi_flash ADDR";
  attribute X_INTERFACE_MODE of bpi_flash_addr : signal is "Master";
  attribute X_INTERFACE_INFO of bpi_flash_adv_ldn : signal is "xilinx.com:interface:emc:1.0 bpi_flash ADV_LDN";
  attribute X_INTERFACE_INFO of bpi_flash_ce_n : signal is "xilinx.com:interface:emc:1.0 bpi_flash CE_N";
  attribute X_INTERFACE_INFO of bpi_flash_dq_i : signal is "xilinx.com:interface:emc:1.0 bpi_flash DQ_I";
  attribute X_INTERFACE_INFO of bpi_flash_dq_o : signal is "xilinx.com:interface:emc:1.0 bpi_flash DQ_O";
  attribute X_INTERFACE_INFO of bpi_flash_dq_t : signal is "xilinx.com:interface:emc:1.0 bpi_flash DQ_T";
  attribute X_INTERFACE_INFO of bpi_flash_oen : signal is "xilinx.com:interface:emc:1.0 bpi_flash OEN";
  attribute X_INTERFACE_INFO of bpi_flash_wen : signal is "xilinx.com:interface:emc:1.0 bpi_flash WEN";
  attribute X_INTERFACE_INFO of iic_lm73_scl_i : signal is "xilinx.com:interface:iic:1.0 iic_lm73 SCL_I";
  attribute X_INTERFACE_MODE of iic_lm73_scl_i : signal is "Master";
  attribute X_INTERFACE_INFO of iic_lm73_scl_o : signal is "xilinx.com:interface:iic:1.0 iic_lm73 SCL_O";
  attribute X_INTERFACE_INFO of iic_lm73_scl_t : signal is "xilinx.com:interface:iic:1.0 iic_lm73 SCL_T";
  attribute X_INTERFACE_INFO of iic_lm73_sda_i : signal is "xilinx.com:interface:iic:1.0 iic_lm73 SDA_I";
  attribute X_INTERFACE_INFO of iic_lm73_sda_o : signal is "xilinx.com:interface:iic:1.0 iic_lm73 SDA_O";
  attribute X_INTERFACE_INFO of iic_lm73_sda_t : signal is "xilinx.com:interface:iic:1.0 iic_lm73 SDA_T";
  attribute X_INTERFACE_INFO of iic_pcie_scl_i : signal is "xilinx.com:interface:iic:1.0 iic_pcie SCL_I";
  attribute X_INTERFACE_MODE of iic_pcie_scl_i : signal is "Master";
  attribute X_INTERFACE_INFO of iic_pcie_scl_o : signal is "xilinx.com:interface:iic:1.0 iic_pcie SCL_O";
  attribute X_INTERFACE_INFO of iic_pcie_scl_t : signal is "xilinx.com:interface:iic:1.0 iic_pcie SCL_T";
  attribute X_INTERFACE_INFO of iic_pcie_sda_i : signal is "xilinx.com:interface:iic:1.0 iic_pcie SDA_I";
  attribute X_INTERFACE_INFO of iic_pcie_sda_o : signal is "xilinx.com:interface:iic:1.0 iic_pcie SDA_O";
  attribute X_INTERFACE_INFO of iic_pcie_sda_t : signal is "xilinx.com:interface:iic:1.0 iic_pcie SDA_T";
  attribute X_INTERFACE_INFO of led_3bits_tri_o : signal is "xilinx.com:interface:gpio:1.0 led_3bits TRI_O";
  attribute X_INTERFACE_MODE of led_3bits_tri_o : signal is "Master";
  attribute X_INTERFACE_INFO of pci_express_x8_rxn : signal is "xilinx.com:interface:pcie_7x_mgt:1.0 pci_express_x8 rxn";
  attribute X_INTERFACE_MODE of pci_express_x8_rxn : signal is "Master";
  attribute X_INTERFACE_INFO of pci_express_x8_rxp : signal is "xilinx.com:interface:pcie_7x_mgt:1.0 pci_express_x8 rxp";
  attribute X_INTERFACE_INFO of pci_express_x8_txn : signal is "xilinx.com:interface:pcie_7x_mgt:1.0 pci_express_x8 txn";
  attribute X_INTERFACE_INFO of pci_express_x8_txp : signal is "xilinx.com:interface:pcie_7x_mgt:1.0 pci_express_x8 txp";
  attribute X_INTERFACE_INFO of pcie_perstn : signal is "xilinx.com:signal:reset:1.0 RST.PCIE_PERSTN RST";
  attribute X_INTERFACE_PARAMETER of pcie_perstn : signal is "XIL_INTERFACENAME RST.PCIE_PERSTN, INSERT_VIP 0, POLARITY ACTIVE_LOW";
  attribute X_INTERFACE_INFO of pcie_refclk_clk_n : signal is "xilinx.com:interface:diff_clock:1.0 pcie_refclk CLK_N";
  attribute X_INTERFACE_MODE of pcie_refclk_clk_n : signal is "Slave";
  attribute X_INTERFACE_PARAMETER of pcie_refclk_clk_n : signal is "XIL_INTERFACENAME pcie_refclk, CAN_DEBUG false, FREQ_HZ 100000000";
  attribute X_INTERFACE_INFO of pcie_refclk_clk_p : signal is "xilinx.com:interface:diff_clock:1.0 pcie_refclk CLK_P";
begin
end;
