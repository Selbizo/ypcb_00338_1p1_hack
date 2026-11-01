// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// -------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

(* BLOCK_STUB = "true" *)
module top (
  DDR3_0_dq,
  DDR3_0_dqs_p,
  DDR3_0_dqs_n,
  DDR3_0_addr,
  DDR3_0_ba,
  DDR3_0_ras_n,
  DDR3_0_cas_n,
  DDR3_0_we_n,
  DDR3_0_reset_n,
  DDR3_0_ck_p,
  DDR3_0_ck_n,
  DDR3_0_cke,
  DDR3_0_cs_n,
  DDR3_0_odt,
  DDR3_CLK_0_clk_p,
  DDR3_CLK_0_clk_n,
  DDR3_1_dq,
  DDR3_1_dqs_p,
  DDR3_1_dqs_n,
  DDR3_1_addr,
  DDR3_1_ba,
  DDR3_1_ras_n,
  DDR3_1_cas_n,
  DDR3_1_we_n,
  DDR3_1_reset_n,
  DDR3_1_ck_p,
  DDR3_1_ck_n,
  DDR3_1_cke,
  DDR3_1_cs_n,
  DDR3_1_odt,
  DDR3_CLK_1_clk_p,
  DDR3_CLK_1_clk_n,
  iic_lm73_scl_i,
  iic_lm73_scl_o,
  iic_lm73_scl_t,
  iic_lm73_sda_i,
  iic_lm73_sda_o,
  iic_lm73_sda_t,
  iic_pcie_scl_i,
  iic_pcie_scl_o,
  iic_pcie_scl_t,
  iic_pcie_sda_i,
  iic_pcie_sda_o,
  iic_pcie_sda_t,
  pci_express_x8_rxn,
  pci_express_x8_rxp,
  pci_express_x8_txn,
  pci_express_x8_txp,
  led_3bits_tri_o,
  alert_lm73_tri_i,
  bpi_flash_addr,
  bpi_flash_adv_ldn,
  bpi_flash_ce_n,
  bpi_flash_dq_i,
  bpi_flash_dq_o,
  bpi_flash_dq_t,
  bpi_flash_oen,
  bpi_flash_wen,
  SYS_CLK,
  SYS_RSTN,
  pcie_perstn,
  pcie_refclk_clk_n,
  pcie_refclk_clk_p
);

  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_0 DQ" *)
  (* X_INTERFACE_MODE = "master DDR3_0" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DDR3_0, CAN_DEBUG false, TIMEPERIOD_PS 1250, MEMORY_TYPE COMPONENTS, DATA_WIDTH 8, CS_ENABLED true, DATA_MASK_ENABLED true, SLOT Single, MEM_ADDR_MAP ROW_COLUMN_BANK, BURST_LENGTH 8, AXI_ARBITRATION_SCHEME TDM, CAS_LATENCY 11, CAS_WRITE_LATENCY 11" *)
  inout [71:0]DDR3_0_dq;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_0 DQS_P" *)
  inout [8:0]DDR3_0_dqs_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_0 DQS_N" *)
  inout [8:0]DDR3_0_dqs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_0 ADDR" *)
  output [14:0]DDR3_0_addr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_0 BA" *)
  output [2:0]DDR3_0_ba;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_0 RAS_N" *)
  output DDR3_0_ras_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_0 CAS_N" *)
  output DDR3_0_cas_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_0 WE_N" *)
  output DDR3_0_we_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_0 RESET_N" *)
  output DDR3_0_reset_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_0 CK_P" *)
  output [0:0]DDR3_0_ck_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_0 CK_N" *)
  output [0:0]DDR3_0_ck_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_0 CKE" *)
  output [0:0]DDR3_0_cke;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_0 CS_N" *)
  output [0:0]DDR3_0_cs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_0 ODT" *)
  output [0:0]DDR3_0_odt;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 DDR3_CLK_0 CLK_P" *)
  (* X_INTERFACE_MODE = "slave DDR3_CLK_0" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DDR3_CLK_0, CAN_DEBUG false, FREQ_HZ 100000000" *)
  input DDR3_CLK_0_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 DDR3_CLK_0 CLK_N" *)
  input DDR3_CLK_0_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_1 DQ" *)
  (* X_INTERFACE_MODE = "master DDR3_1" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DDR3_1, CAN_DEBUG false, TIMEPERIOD_PS 1250, MEMORY_TYPE COMPONENTS, DATA_WIDTH 8, CS_ENABLED true, DATA_MASK_ENABLED true, SLOT Single, MEM_ADDR_MAP ROW_COLUMN_BANK, BURST_LENGTH 8, AXI_ARBITRATION_SCHEME TDM, CAS_LATENCY 11, CAS_WRITE_LATENCY 11" *)
  inout [71:0]DDR3_1_dq;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_1 DQS_P" *)
  inout [8:0]DDR3_1_dqs_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_1 DQS_N" *)
  inout [8:0]DDR3_1_dqs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_1 ADDR" *)
  output [14:0]DDR3_1_addr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_1 BA" *)
  output [2:0]DDR3_1_ba;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_1 RAS_N" *)
  output DDR3_1_ras_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_1 CAS_N" *)
  output DDR3_1_cas_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_1 WE_N" *)
  output DDR3_1_we_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_1 RESET_N" *)
  output DDR3_1_reset_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_1 CK_P" *)
  output [0:0]DDR3_1_ck_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_1 CK_N" *)
  output [0:0]DDR3_1_ck_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_1 CKE" *)
  output [0:0]DDR3_1_cke;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_1 CS_N" *)
  output [0:0]DDR3_1_cs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR3_1 ODT" *)
  output [0:0]DDR3_1_odt;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 DDR3_CLK_1 CLK_P" *)
  (* X_INTERFACE_MODE = "slave DDR3_CLK_1" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DDR3_CLK_1, CAN_DEBUG false, FREQ_HZ 100000000" *)
  input DDR3_CLK_1_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 DDR3_CLK_1 CLK_N" *)
  input DDR3_CLK_1_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 iic_lm73 SCL_I" *)
  (* X_INTERFACE_MODE = "master iic_lm73" *)
  input iic_lm73_scl_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 iic_lm73 SCL_O" *)
  output iic_lm73_scl_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 iic_lm73 SCL_T" *)
  output iic_lm73_scl_t;
  (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 iic_lm73 SDA_I" *)
  input iic_lm73_sda_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 iic_lm73 SDA_O" *)
  output iic_lm73_sda_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 iic_lm73 SDA_T" *)
  output iic_lm73_sda_t;
  (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 iic_pcie SCL_I" *)
  (* X_INTERFACE_MODE = "master iic_pcie" *)
  input iic_pcie_scl_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 iic_pcie SCL_O" *)
  output iic_pcie_scl_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 iic_pcie SCL_T" *)
  output iic_pcie_scl_t;
  (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 iic_pcie SDA_I" *)
  input iic_pcie_sda_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 iic_pcie SDA_O" *)
  output iic_pcie_sda_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:iic:1.0 iic_pcie SDA_T" *)
  output iic_pcie_sda_t;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pci_express_x8 rxn" *)
  (* X_INTERFACE_MODE = "master pci_express_x8" *)
  input [0:0]pci_express_x8_rxn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pci_express_x8 rxp" *)
  input [0:0]pci_express_x8_rxp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pci_express_x8 txn" *)
  output [0:0]pci_express_x8_txn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pci_express_x8 txp" *)
  output [0:0]pci_express_x8_txp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 led_3bits TRI_O" *)
  (* X_INTERFACE_MODE = "master led_3bits" *)
  output [2:0]led_3bits_tri_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 alert_lm73 TRI_I" *)
  (* X_INTERFACE_MODE = "master alert_lm73" *)
  input alert_lm73_tri_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:emc:1.0 bpi_flash ADDR" *)
  (* X_INTERFACE_MODE = "master bpi_flash" *)
  output [25:1]bpi_flash_addr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:emc:1.0 bpi_flash ADV_LDN" *)
  output bpi_flash_adv_ldn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:emc:1.0 bpi_flash CE_N" *)
  output bpi_flash_ce_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:emc:1.0 bpi_flash DQ_I" *)
  input [15:0]bpi_flash_dq_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:emc:1.0 bpi_flash DQ_O" *)
  output [15:0]bpi_flash_dq_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:emc:1.0 bpi_flash DQ_T" *)
  output [15:0]bpi_flash_dq_t;
  (* X_INTERFACE_INFO = "xilinx.com:interface:emc:1.0 bpi_flash OEN" *)
  output bpi_flash_oen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:emc:1.0 bpi_flash WEN" *)
  output bpi_flash_wen;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.SYS_CLK CLK" *)
  (* X_INTERFACE_MODE = "slave CLK.SYS_CLK" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.SYS_CLK, FREQ_HZ 50000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN top_SYS_CLK, INSERT_VIP 0" *)
  input SYS_CLK;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.SYS_RSTN RST" *)
  (* X_INTERFACE_MODE = "slave RST.SYS_RSTN" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.SYS_RSTN, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
  input SYS_RSTN;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.PCIE_PERSTN RST" *)
  (* X_INTERFACE_MODE = "slave RST.PCIE_PERSTN" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.PCIE_PERSTN, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
  input pcie_perstn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 pcie_refclk CLK_N" *)
  (* X_INTERFACE_MODE = "slave pcie_refclk" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME pcie_refclk, CAN_DEBUG false, FREQ_HZ 100000000" *)
  input pcie_refclk_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 pcie_refclk CLK_P" *)
  input pcie_refclk_clk_p;

  // stub module has no contents

endmodule
