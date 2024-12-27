//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.1.2 (win64) Build 5164865 Thu Sep  5 14:37:11 MDT 2024
//Date        : Fri Dec 13 19:26:14 2024
//Host        : Tim-Workstation running 64-bit major release  (build 9200)
//Command     : generate_target clock_wizard.bd
//Design      : clock_wizard
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "clock_wizard,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=clock_wizard,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "clock_wizard.hwdef" *) 
module clock_wizard
   (clk_in1,
    clk_out1,
    locked,
    reset);
  input clk_in1;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_OUT1 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_OUT1, CLK_DOMAIN /clk_wiz_0_clk_out1, FREQ_HZ 250000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) output clk_out1;
  output locked;
  input reset;

  wire clk_in1_1;
  wire clk_wiz_0_clk_out1;
  wire clk_wiz_0_locked;
  wire reset_1;

  assign clk_in1_1 = clk_in1;
  assign clk_out1 = clk_wiz_0_clk_out1;
  assign locked = clk_wiz_0_locked;
  assign reset_1 = reset;
  clock_wizard_clk_wiz_0_0 clk_wiz_0
       (.clk_in1(clk_in1_1),
        .clk_out1(clk_wiz_0_clk_out1),
        .locked(clk_wiz_0_locked),
        .reset(reset_1));
endmodule
