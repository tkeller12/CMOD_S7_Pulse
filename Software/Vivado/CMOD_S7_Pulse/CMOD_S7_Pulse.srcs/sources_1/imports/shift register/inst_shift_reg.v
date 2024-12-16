`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2024 07:23:25 PM
// Design Name: 
// Module Name: multi_shift_reg
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

// Instruction shift register for pulse programmer
module inst_shift_reg #(parameter BITS = 8, parameter WORDS = 2)(
    input clk,
    input [BITS-1:0] data,
    input i_DV,
    input rst,
    output [(BITS*WORDS)-1:0] shift_reg_data,
    output o_DV
    );
    
    reg [(BITS*WORDS)-1:0] r_shift_reg_data = 0;
    reg [$clog2(WORDS):0] r_word_count = 0;
    reg r_o_DV = 0;
    
    always @(posedge clk)
    begin
        if (rst)
        begin
            r_shift_reg_data <= 0;
            r_word_count <= 0;
            r_o_DV <= 0;
        end
        
        else
        begin
                     
            if (i_DV)
            begin
                r_shift_reg_data <= {r_shift_reg_data[BITS*WORDS - BITS-1:0], data};
                if (r_word_count == (WORDS-1))
                begin
                    r_o_DV <= 1;
                    r_word_count <= 0;
                end
                else
                begin
                    r_o_DV <= 0;
                    r_word_count <= r_word_count + 1;
                end
            end
            else
                r_o_DV <= 0;
            begin
            
            end          
               
        end
        
    end
    
    assign shift_reg_data = r_shift_reg_data;
    assign o_DV = r_o_DV;
    
endmodule
