`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2024 06:56:05 PM
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


module top(
    input clk,
    output pio1,
    output pio2
    );
    
    
    clocking_wizard u_clocking_wizard (
        .clk_in1(clk),
        .reset(reset),
        .clk_out1(clk_250M),
        .clk_out2(clk_10M),
        .locked(locked)
    );
    
    
    assign pio1 = clk_250M;
    assign pio2 = clk_10M;
    
    
endmodule
