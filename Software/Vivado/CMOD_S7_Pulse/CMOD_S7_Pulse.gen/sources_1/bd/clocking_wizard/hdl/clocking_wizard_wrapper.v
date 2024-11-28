//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.1.2 (win64) Build 5164865 Thu Sep  5 14:37:11 MDT 2024
//Date        : Thu Nov 28 10:15:48 2024
//Host        : Tim-Workstation running 64-bit major release  (build 9200)
//Command     : generate_target clocking_wizard_wrapper.bd
//Design      : clocking_wizard_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module clocking_wizard_wrapper
   (clk_in1,
    clk_out1,
    clk_out2,
    locked,
    reset);
  input clk_in1;
  output clk_out1;
  output clk_out2;
  output locked;
  input reset;

  wire clk_in1;
  wire clk_out1;
  wire clk_out2;
  wire locked;
  wire reset;

  clocking_wizard clocking_wizard_i
       (.clk_in1(clk_in1),
        .clk_out1(clk_out1),
        .clk_out2(clk_out2),
        .locked(locked),
        .reset(reset));
endmodule
