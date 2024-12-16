`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2024 09:53:58 AM
// Design Name: 
// Module Name: ppc_tb
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


module ppc_tb;

    reg rst = 1;
    reg clk = 0;
    wire [63:0] instruction;
    wire [7:0] addr;
    wire [7:0] pulse;
    wire [3:0] op_code;
    wire [19:0] data;
    wire [31:0] delay;

    

    pulse_programmer_core u_ppc (
        .rst(rst),
        .clk(clk),
        .addr(addr),
        .op_code(op_code),
        .delay(delay),
        .data(data)
        );


    reg [7:0] wr_addr = 0;
    reg wr_DV = 1; 
    reg [63:0] wr_instruction = 64'b0;  
    reg rd_en = 1; 
        
    PP_RAM_2Port #(.WIDTH(64), .DEPTH(256)) u_PP_RAM_2Port
      (// Write Signals
       .i_Wr_Clk(clk),
       .i_Wr_Addr(wr_addr),
       .i_Wr_DV(wr_DV),
       .i_Wr_Data(wr_instruction),
       // Read Signals
       .i_Rd_Clk(clk),
       .i_Rd_Addr(addr),
       .i_Rd_En(rd_en),
       .o_Rd_DV(rd_DV),
       .o_Rd_Data(instruction),
       .pulse(pulse),
       .data(data),
       .op_code(op_code),
       .delay(delay)
       );
    
    always
    begin
        #4 clk <= ~clk;
    end
    
    reg init = 1;
    reg [7:0] wr_pulse = 8'haa;
    reg [19:0] wr_data = 20'b0;
    reg [3:0] wr_op_code = 4'b0001;
    reg [31:0] wr_delay = 32'b0;
    
    always @(posedge clk)
    begin
        if (init)
        begin      
            wr_addr <= wr_addr+1;
//            wr_data <= {wr_addr+1,56'b0};
            wr_instruction <= {wr_pulse, wr_data, wr_op_code, wr_delay};
            wr_pulse <= ~wr_pulse;        
            if (wr_addr == 255)
            begin
                init <= 0;
                rst <= 0;
                wr_DV <= 0;
            end
        end
    
    end



endmodule
