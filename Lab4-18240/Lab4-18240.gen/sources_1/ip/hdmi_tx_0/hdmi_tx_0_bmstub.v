// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// -------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

(* BLOCK_STUB = "true" *)
module hdmi_tx_0 (
  pix_clk,
  pix_clkx5,
  pix_clk_locked,
  rst,
  red,
  green,
  blue,
  hsync,
  vsync,
  vde,
  TMDS_CLK_P,
  TMDS_CLK_N,
  TMDS_DATA_P,
  TMDS_DATA_N
);

  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 pix_clk CLK" *)
  (* X_INTERFACE_MODE = "slave pix_clk" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME pix_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN , ASSOCIATED_BUSIF , ASSOCIATED_PORT , ASSOCIATED_RESET , INSERT_VIP 0" *)
  input pix_clk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 pix_clkx5 CLK" *)
  (* X_INTERFACE_MODE = "slave pix_clkx5" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME pix_clkx5, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN , ASSOCIATED_BUSIF , ASSOCIATED_PORT , ASSOCIATED_RESET , INSERT_VIP 0" *)
  input pix_clkx5;
  (* X_INTERFACE_IGNORE = "true" *)
  input pix_clk_locked;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst RST" *)
  (* X_INTERFACE_MODE = "slave rst" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rst, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
  input rst;
  (* X_INTERFACE_IGNORE = "true" *)
  input [7:0]red;
  (* X_INTERFACE_IGNORE = "true" *)
  input [7:0]green;
  (* X_INTERFACE_IGNORE = "true" *)
  input [7:0]blue;
  (* X_INTERFACE_IGNORE = "true" *)
  input hsync;
  (* X_INTERFACE_IGNORE = "true" *)
  input vsync;
  (* X_INTERFACE_IGNORE = "true" *)
  input vde;
  (* X_INTERFACE_INFO = "xilinx.com:interface:hdmi:2.0 hdmi_tx TMDS_CLK_P" *)
  (* X_INTERFACE_MODE = "master hdmi_tx" *)
  output TMDS_CLK_P;
  (* X_INTERFACE_INFO = "xilinx.com:interface:hdmi:2.0 hdmi_tx TMDS_CLK_N" *)
  output TMDS_CLK_N;
  (* X_INTERFACE_INFO = "xilinx.com:interface:hdmi:2.0 hdmi_tx TMDS_DATA_P" *)
  output [2:0]TMDS_DATA_P;
  (* X_INTERFACE_INFO = "xilinx.com:interface:hdmi:2.0 hdmi_tx TMDS_DATA_N" *)
  output [2:0]TMDS_DATA_N;

  // stub module has no contents

endmodule
