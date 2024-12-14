`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2024 08:40:29 PM
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
    input clk_12MHz,
    input wire uart_rx_pin,
    output wire [7:0] ja,
    output wire [3:0] led
    );
    
    wire clk;
    clock_wizard_wrapper u_clock_wizard_wrapper
   (
    .clk_in1(clk_12MHz),
    .clk_out1(clk)
    //.locked(locked)
    //.reset()
    );
    
    reg [3:0] r_led = 0;
    
    // 250 000 000 / 115 200 = 2170.1388 ~ 2170
    parameter TICKS_PER_BIT = 2170;
    parameter UART_BITS = 8;
    parameter UART_WORDS = 2;
    
    //reg uart_rx_pin;
    wire [7:0] data;
    wire uart_rx_done;
    wire busy;
    
    reg rst = 0;
    wire [(UART_BITS*UART_WORDS)-1:0] shift_reg_data;
    wire o_DV;
        
    
    uart_rx #(.TICKS_PER_BIT(TICKS_PER_BIT)) u_uart_rx (
    .clk(clk), // input clock
    .uart_rx_pin(uart_rx_pin), // Input RX data pin    
    .data(data), // output data
    .uart_rx_done(uart_rx_done), // Pull high for 1 clock cycle when transmission complete
    .busy(busy) // high while receiving
    );
    
    inst_shift_reg #(.BITS(UART_BITS), .WORDS(UART_WORDS)) u_inst_shift_reg(
    .clk(clk),
    .data(data),
    .i_DV(uart_rx_done),
    .rst(rst),
    .shift_reg_data(shift_reg_data),
    .o_DV(o_DV)
    );
    
    
    reg [6:0] addr = 0;
    reg i_Wr_DV = 0;
    reg [7:0] i_Wr_Data = 0;
    reg i_Rd_En = 0;
    
    wire o_Rd_DV;
    wire [7:0] o_Rd_Data;
        
    RAM_1Port #(.WIDTH(8), .DEPTH(128)) u_RAM_1Port (
    .i_Clk(clk),
    // Shared address for writes and reads
    .i_Addr(addr),
    // Write Interface
    .i_Wr_DV(i_Wr_DV),
    .i_Wr_Data(i_Wr_Data),
    // Read Interface
    .i_Rd_En(i_Rd_En),
    .o_Rd_DV(o_Rd_DV),
    .o_Rd_Data(o_Rd_Data)
    );
    
    reg [7:0] r_ja = 0;

    always @(posedge clk)
    begin
        if (o_DV)
        begin
            addr <= shift_reg_data[14:8];        
            if (shift_reg_data[15] == 1) // write operation
            begin
                r_led[0] <= 1;
                i_Wr_Data <= shift_reg_data[7:0];
                //i_Wr_Data <= 8'haa; // troubleshooting, this doesn't work
                i_Wr_DV <= 1;
                i_Rd_En <= 0;
            end
            else // read operation
            begin
                r_led[1] <= 1;
                i_Rd_En <= 1;
                i_Wr_DV <= 0;
            end

        end
        else
        begin
            i_Rd_En <= 0;
            i_Wr_DV <= 0;
        end
    end
    
    always @(posedge clk)
    begin
        if (o_Rd_DV)
        begin
            r_ja <= o_Rd_Data; // it does get to this line when writing RX
            r_led[2] <= 1;
        end
    end
    
    
    assign ja = r_ja;
    assign led = r_led;
    
    
endmodule
