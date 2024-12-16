`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2024 01:56:29 PM
// Design Name: 
// Module Name: PP_RAM_2Port
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PP_RAM_2Port #(parameter WIDTH = 64, DEPTH = 256)
  (// Write Signals
   input                     i_Wr_Clk,
   input [$clog2(DEPTH)-1:0] i_Wr_Addr,
   input                     i_Wr_DV,
   input [WIDTH-1:0]         i_Wr_Data,
   // Read Signals
   input                     i_Rd_Clk,
   input [$clog2(DEPTH)-1:0] i_Rd_Addr,
   input                     i_Rd_En,
   output reg                o_Rd_DV,
   output reg [WIDTH-1:0]    o_Rd_Data,
   output reg [7:0]          pulse,
   output reg [19:0]         data,
   output reg [3:0]          op_code,
   output reg [31:0]         delay
   );

  // Declare the Memory variable
  reg [WIDTH-1:0] r_Mem[DEPTH-1:0];

  // Handle writes to memory
  always @ (posedge i_Wr_Clk)
  begin
    if (i_Wr_DV)
    begin
      r_Mem[i_Wr_Addr] <= i_Wr_Data;
    end
  end

  // Handle reads from memory
  always @ (posedge i_Rd_Clk)
  begin
    o_Rd_Data <= r_Mem[i_Rd_Addr];
    pulse <= r_Mem[i_Rd_Addr][63:56];
    data <= r_Mem[i_Rd_Addr][55:36];
    op_code <= r_Mem[i_Rd_Addr][35:32];
    delay <= r_Mem[i_Rd_Addr][31:0];    
    o_Rd_DV   <= i_Rd_En;
  end

    
    
    
    
endmodule
