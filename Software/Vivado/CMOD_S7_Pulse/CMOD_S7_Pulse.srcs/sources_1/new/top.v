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
    input clk
    );
    
    wire clk_250;
    wire clk_locked;
    
    CLOCK_SYNTH U_CLOCK_SYNTH (
        .clk(clk),
        .reset(reset),
        .clk_250(clk_250),
        .clk_locked(clk_locked)
    );
    
    
    
    
endmodule
