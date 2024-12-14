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
    output reg [7:0] addr = 0,
    input [3:0] op_code,
    input [31:0] delay,
    input [19:0] data,
    input trig
    );
    
    
    //reg [31:0] delay = 0;
    
    reg [31:0] count = 0;
    reg [19:0] long_count = 0;
    
    reg [3:0] OP_CODE = 0;
    
    reg [3:0] NO_OP = 4'b0000;
    reg [3:0] DELAY = 4'b0001;
    reg [3:0] LONG_DELAY = 4'b0010;    
    //reg [3:0] GOTO  =  4'b0010;
    //reg [3:0] JSR =   4'b
    reg [3:0] WAIT =  4'b1000;
    //reg [3:0] SETUP = 4'b1111;

    //reg [63:0] instruction = 0;
    
    always @(posedge clk)
    begin
        //instruction <= next_instruction;
        if (rst)
        begin
            addr <= 0;
            count <= 0;
            long_count <= 0;
            //OP_CODE <= NO_OP;
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
                    if (count == delay)
                    begin
                        count <= 0;
                        addr <= addr + 1;
                    end
                    
                    else
                    begin
                        count <= count + 1;
                    end
                end
                LONG_DELAY:
                begin
                    if (count == delay)
                    begin
                        long_count <= long_count + 1;
                        count <= 0;
                        //if long_count == data
                    end
                end
                
                default:
                begin
                    addr <= addr+1;
                end
            endcase
        end
        
    
    end
    
    assign pulse = instruction[7:0];
    
endmodule
