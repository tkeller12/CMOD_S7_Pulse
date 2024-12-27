`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/27/2024 12:54:20 PM
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


    reg pp_rst = 1;
    
    reg clk = 0;
    reg [11:0] wr_addr = 0;
    reg i_Wr_DV = 1;
    reg [63:0] i_Wr_Data = 10;
    //o_Rd_Data[35:32]
    wire [11:0] addr;
    reg trig = 0;
    
    reg i_Rd_En = 1;
    wire o_Rd_DV;
    wire [63:0] o_Rd_Data;
    
    
    RAM_2Port #(.WIDTH(64), .DEPTH(4096)) u_RAM_2Port (
    // Write Interface
    .i_Wr_Clk(clk),    
    .i_Wr_Addr(wr_addr),    
    .i_Wr_DV(i_Wr_DV),
    .i_Wr_Data(i_Wr_Data),
    // Read Interface
    .i_Rd_Clk(clk),
    .i_Rd_Addr(addr),
    .i_Rd_En(i_Rd_En),
    .o_Rd_DV(o_Rd_DV),
    .o_Rd_Data(o_Rd_Data)
    );
    
    wire [7:0] pulse;
    wire [19:0] data;
    wire [3:0] op_code;
    wire [31:0] delay;
    
    pulse_programmer_core u_ppc (
     .rst(pp_rst),
     .clk(clk),
     .addr(addr),     
     .op_code(op_code),
     .delay(delay),
     .data(data),
     .trig(trig)
    );
    
    assign pulse = o_Rd_Data[63:56];
    assign data = o_Rd_Data[55:36];
    assign op_code = o_Rd_Data[35:32];
    assign delay = o_Rd_Data[31:0];  
    
    always
    begin
        #2 clk <= ~clk;
    end
    
    initial
    begin
        i_Wr_Data[35:32] <= 1;
        i_Wr_Data[31:0] <= 10;
    end

    reg rst = 1;
    
    always @(posedge clk)
    begin
        if (rst == 1)
        begin
            wr_addr <= wr_addr + 1;
            if (wr_addr == 4095)
            begin
                rst <= 0;
                pp_rst <= 0;
            end
        end
        
    end
    



endmodule
