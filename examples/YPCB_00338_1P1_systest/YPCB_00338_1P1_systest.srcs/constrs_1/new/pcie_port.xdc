set_property LOC GTXE2_CHANNEL_X0Y23 [get_cells {top_i/xdma_0/inst/top_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN F2 [get_ports {pci_express_x8_txp[0]}]
set_property LOC GTXE2_CHANNEL_X0Y22 [get_cells {top_i/xdma_0/inst/top_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN H2 [get_ports {pci_express_x8_txp[1]}]
set_property LOC GTXE2_CHANNEL_X0Y21 [get_cells {top_i/xdma_0/inst/top_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[2].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN K2 [get_ports {pci_express_x8_txp[2]}]
set_property LOC GTXE2_CHANNEL_X0Y20 [get_cells {top_i/xdma_0/inst/top_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[3].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN M2 [get_ports {pci_express_x8_txp[3]}]
set_property LOC GTXE2_CHANNEL_X0Y19 [get_cells {top_i/xdma_0/inst/top_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[4].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN N4 [get_ports {pci_express_x8_txp[4]}]
set_property LOC GTXE2_CHANNEL_X0Y18 [get_cells {top_i/xdma_0/inst/top_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[5].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN P2 [get_ports {pci_express_x8_txp[5]}]
set_property LOC GTXE2_CHANNEL_X0Y17 [get_cells {top_i/xdma_0/inst/top_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[6].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN T2 [get_ports {pci_express_x8_txp[6]}]
set_property LOC GTXE2_CHANNEL_X0Y16 [get_cells {top_i/xdma_0/inst/top_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[7].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN U4 [get_ports {pci_express_x8_txp[7]}]

set_property PACKAGE_PIN Y26 [get_ports pcie_perstn]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_perstn]

###################### Boot from BPI flash ######################
# The board is wired for SYNCHRONOUS BPI (flash ADV#/CLK are used). With the
# default asynchronous mode CCLK is not generated, the flash never returns
# data and configuration from flash fails (BOOT_STATUS.WRAP_ERROR / no boot).
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
# Default is 3 MHz => ~52 s to configure 18 MB. 33 MHz boots in ~5 s.
set_property BITSTREAM.CONFIG.CONFIGRATE   33    [current_design]
# Bank 0 / config banks are 1.8 V on this board (also silences CFGBVS-1 DRC).
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
#
# NOTE for JTAG-only debug builds: with the default StartUpClk=Cclk the startup
# sequence never completes over JTAG (CCLK is not clocked in JTAG mode), so
# programming fails with "End of startup status: LOW". For a JTAG test image add
#   set_property BITSTREAM.STARTUP.STARTUPCLK JtagClk [current_design]
# Keep Cclk (default) for the image that is written to the BPI flash.