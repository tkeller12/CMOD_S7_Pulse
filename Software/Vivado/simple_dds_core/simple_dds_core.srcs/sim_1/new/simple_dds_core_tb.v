`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/15/2024 02:56:24 PM
// Design Name: 
// Module Name: simple_dds_core_tb
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


module simple_dds_core_tb;
    reg rst = 0;
    reg clk = 0;
    reg [3:0] dds_phase = 0;
    wire [1:0] dds_pulse;
    
    wire [3:0] divided_clk;
    
    simple_dds_core #(.DIVIDE(2)) u_simple_dds_core(
        .rst(rst),
        .clk(clk),
        .dds_phase(dds_phase),
        .dds_pulse(dds_pulse)
    );
    
    assign divided_clk = u_simple_dds_core.divided_clk;
    
    always
    begin
        #2 clk <= ~clk;
    end
    
    reg [7:0] dds_counter = 0;
    
    always @(posedge clk)
    begin
        dds_counter <= dds_counter + 1;
        if (dds_counter == 16)
        begin
            dds_counter <= 0;
            if (dds_phase == 4)
            begin
                dds_phase <= 0;
            end
            else
            begin
                dds_phase <= dds_phase + 1;
            end
            
        end
    end
    
    
endmodule
