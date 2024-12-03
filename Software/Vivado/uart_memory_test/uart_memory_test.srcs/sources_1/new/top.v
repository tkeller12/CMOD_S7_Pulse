`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2024 08:14:29 PM
// Design Name: 
// Module Name: top
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


module top #(parameter WIDTH = 32, DEPTH = 256)
(
    input clk,
    output [31:0] pio,
    output [3:0] led
    );
    
   reg [WIDTH-1:0] counter = 0;
   reg [7:0] addr = 0;
   reg Wr_DV = 1;
   reg Rd_En = 1;
   wire Rd_DV;
   wire [WIDTH-1:0] Rd_Data;
   
   wire clk_250M;
   wire locked;
   reg reset = 0;
   clock_wizard_wrapper u_clock_wizard_wrapper
   (.clk_in1(clk),
    .clk_out1(clk_250M),
    .locked(locked),
    .reset(reset)
    );
    
   RAM_2Port #(.WIDTH(WIDTH), .DEPTH(DEPTH)) u_RAM_2Port
  (// Write Signals
   .i_Wr_Clk(clk_250M),
   .i_Wr_Addr(addr),
   .i_Wr_DV(Wr_DV),
   .i_Wr_Data(counter),
   // Read Signals
   .i_Rd_Clk(clk_250M),
   .i_Rd_Addr(addr),
   .i_Rd_En(Rd_En),
   .o_Rd_DV(Rd_DV),
   .o_Rd_Data(Rd_Data)
   );
   
   always @(posedge clk_250M)
   begin
    counter <= counter + 1;
    addr <= addr + 1;
    Wr_DV <= 1;
   end
   
   //assign led = counter[3:0];
   //assign pio = counter[31:0];
   assign led = Rd_Data[3:0];
   assign pio = Rd_Data[31:0];  
endmodule
