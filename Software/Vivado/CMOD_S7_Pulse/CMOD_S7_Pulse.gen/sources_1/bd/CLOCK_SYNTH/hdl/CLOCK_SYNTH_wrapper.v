//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.1.2 (win64) Build 5164865 Thu Sep  5 14:37:11 MDT 2024
//Date        : Mon Nov 25 19:09:21 2024
//Host        : Tim-Workstation running 64-bit major release  (build 9200)
//Command     : generate_target CLOCK_SYNTH_wrapper.bd
//Design      : CLOCK_SYNTH_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module CLOCK_SYNTH_wrapper
   (clk,
    clk_250,
    clk_locked,
    reset);
  input clk;
  output clk_250;
  output clk_locked;
  input reset;

  wire clk;
  wire clk_250;
  wire clk_locked;
  wire reset;

  CLOCK_SYNTH CLOCK_SYNTH_i
       (.clk(clk),
        .clk_250(clk_250),
        .clk_locked(clk_locked),
        .reset(reset));
endmodule
