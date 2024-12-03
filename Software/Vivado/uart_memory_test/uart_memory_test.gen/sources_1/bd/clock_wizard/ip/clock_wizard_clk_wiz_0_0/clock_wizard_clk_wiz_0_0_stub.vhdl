-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.1.2 (win64) Build 5164865 Thu Sep  5 14:37:11 MDT 2024
-- Date        : Mon Dec  2 21:51:15 2024
-- Host        : Tim-Workstation running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/jkell/Repositories/CMOD_S7_Pulse/Software/Vivado/uart_memory_test/uart_memory_test.gen/sources_1/bd/clock_wizard/ip/clock_wizard_clk_wiz_0_0/clock_wizard_clk_wiz_0_0_stub.vhdl
-- Design      : clock_wizard_clk_wiz_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7s25csga225-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_wizard_clk_wiz_0_0 is
  Port ( 
    clk_out1 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end clock_wizard_clk_wiz_0_0;

architecture stub of clock_wizard_clk_wiz_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_out1,reset,locked,clk_in1";
begin
end;
