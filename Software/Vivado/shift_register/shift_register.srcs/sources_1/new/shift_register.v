`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2024 07:29:23 PM
// Design Name: 
// Module Name: shift_register
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


module shift_register #(parameter WIDTH = 64)
(
    input i_Clk,    // Input Clock
    input i_Wr_DV,  // Write Data Valid
    input [7:0] i_Data, // Input data for shift register
    output [WIDTH-1:0] o_Reg //
    );
    
    reg [WIDTH-1:0] r_Reg;
    
    always @(posedge i_Clk)
    begin
        if (i_Wr_DV)
            begin
                r_Reg[WIDTH-1:8] <= r_Reg[WIDTH-7:0];
                r_Reg[7:0] <= i_Data;
            end
    end
    
    assign o_Reg = r_Reg;
    
endmodule
