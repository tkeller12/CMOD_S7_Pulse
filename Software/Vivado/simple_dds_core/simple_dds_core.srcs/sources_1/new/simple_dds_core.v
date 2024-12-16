`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/15/2024 02:36:44 PM
// Design Name: 
// Module Name: simple_dds_core
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


module simple_dds_core #(parameter DIVIDE = 2)(
    input rst,
    input clk,
    input [3:0] dds_phase,
    output reg [1:0] dds_pulse = 2'b00
    );
    
    reg [3:0] divided_clk = 0;
    reg [4:0] counter = 0;
    
    always @(posedge clk)
    begin
        counter <= counter + 1;
        if (rst)
        begin 
        divided_clk <= 0;
        counter <= 0;
        end
        else if (counter == 0) 
        begin 
            divided_clk[0] <= !divided_clk[0];
            divided_clk[2] <= divided_clk[0];
        end
        else if (counter == 1) 
        begin
            divided_clk[1] <= !divided_clk[1];
            divided_clk[3] <= divided_clk[1];
        end
        
        if (counter == DIVIDE-1) counter <= 0;
    end
    
    always @(posedge clk)
    begin
        case(dds_phase)
        4'b0000 : dds_pulse <= 0;
        4'b0001 : dds_pulse <= {divided_clk[0],divided_clk[3]}; // 0 deg
        4'b0010 : dds_pulse <= {divided_clk[1],divided_clk[0]}; // 90 deg
        4'b0011 : dds_pulse <= {divided_clk[2],divided_clk[1]}; // 180 deg
        4'b0100 : dds_pulse <= {divided_clk[3],divided_clk[2]}; // 270 deg
        default : dds_pulse <= 0;
        endcase
    end
    
    
endmodule
