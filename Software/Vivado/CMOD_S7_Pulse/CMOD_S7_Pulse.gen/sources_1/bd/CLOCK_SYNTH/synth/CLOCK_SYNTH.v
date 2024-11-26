//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.1.2 (win64) Build 5164865 Thu Sep  5 14:37:11 MDT 2024
//Date        : Mon Nov 25 19:09:21 2024
//Host        : Tim-Workstation running 64-bit major release  (build 9200)
//Command     : generate_target CLOCK_SYNTH.bd
//Design      : CLOCK_SYNTH
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "CLOCK_SYNTH,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=CLOCK_SYNTH,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_board_cnt=1,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "CLOCK_SYNTH.hwdef" *) 
module CLOCK_SYNTH
   (clk,
    clk_250,
    clk_locked,
    reset);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK, CLK_DOMAIN CLOCK_SYNTH_clk, FREQ_HZ 12000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input clk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_250 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_250, CLK_DOMAIN /clk_wiz_0_clk_out1, FREQ_HZ 250000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) output clk_250;
  output clk_locked;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RESET RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RESET, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) input reset;

  wire clk;
  wire clk_wiz_0_clk_out1;
  wire clk_wiz_0_locked;
  wire reset_1;

  assign clk_250 = clk_wiz_0_clk_out1;
  assign clk_locked = clk_wiz_0_locked;
  assign reset_1 = reset;
  CLOCK_SYNTH_clk_wiz_0_0 clk_wiz_0
       (.clk_in1(clk),
        .clk_out1(clk_wiz_0_clk_out1),
        .locked(clk_wiz_0_locked),
        .reset(reset_1));
endmodule
