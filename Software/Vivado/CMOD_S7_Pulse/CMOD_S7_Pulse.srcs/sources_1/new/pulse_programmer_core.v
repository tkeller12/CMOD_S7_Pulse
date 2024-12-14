`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2024 08:00:24 PM
// Design Name: 
// Module Name: pulse_programmer_core
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


module pulse_programmer_core (
    input rst,
    input clk,
    input [63:0] instruction,
    output addr,
    output [7:0] pulse
    );
    
    
    reg [31:0] r_delay = 0;
    reg [7:0] r_pulse = 0;
    
    reg [31:0] r_count = 0;
    reg [12:0] r_addr = 0;
    
    reg [3:0] OP_CODE = 0;
    
    reg [3:0] NO_OP = 4'b0000;
    reg [3:0] DELAY = 4'b0001;
    //reg [3:0] LONG_DELAY = 4'b0010;
    
    always @(posedge clk)
    begin
        if (rst)
        begin
        
        end
        else
        begin
            case (OP_CODE)
                NO_OP:
                begin
                    r_addr <= r_addr+1;
                end
                DELAY:
                begin
                    if (r_count == r_delay)
                    begin
                        r_count <= 0;
                        r_addr <= r_addr + 1;
                    end
                    
                    else
                    begin
                        r_count <= r_count + 1;
                    end
                end
            endcase
        end
        
    
    end
    
    assign pulse = r_pulse;
    assign addr = r_addr;
    
    
endmodule
