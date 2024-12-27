// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// -------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

(* BLOCK_STUB = "true" *)
module clock_wizard (
  reset,
  clk_in1,
  clk_out1,
  locked
);

  (* X_INTERFACE_IGNORE = "true" *)
  input reset;
  (* X_INTERFACE_IGNORE = "true" *)
  input clk_in1;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_OUT1 CLK" *)
  (* X_INTERFACE_MODE = "master CLK.CLK_OUT1" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_OUT1, FREQ_HZ 250000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, INSERT_VIP 0" *)
  output clk_out1;
  (* X_INTERFACE_IGNORE = "true" *)
  output locked;

  // stub module has no contents

endmodule
