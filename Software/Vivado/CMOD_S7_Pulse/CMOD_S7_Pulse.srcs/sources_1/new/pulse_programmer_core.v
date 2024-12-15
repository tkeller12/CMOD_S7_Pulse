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
    output reg [7:0] addr = 0,
    input [3:0] op_code,
    input [31:0] delay,
    input [19:0] data
    //input trig
    );
    
    reg [31:0] count = 0;
    
    reg [3:0] NO_OP = 4'b0000;
    reg [3:0] DELAY = 4'b0001;
    reg [3:0] WAIT =  4'b1000;
    
    always @(posedge clk)
    begin
        if (rst)
        begin
            addr <= 0;
            count <= 0;
        end
        else
        begin
            case (op_code)
                NO_OP:
                begin
                    addr <= addr+1;
                end
                DELAY:
                begin
                    if (count >= delay)
                    begin
                        count <= 0;
                        addr <= addr + 1;
                    end
                    
                    else
                    begin
                        count <= count + 1;
                    end
                end                
                default:
                begin
                    addr <= addr+1;
                end
            endcase
        end
        
    
    end
    
endmodule
