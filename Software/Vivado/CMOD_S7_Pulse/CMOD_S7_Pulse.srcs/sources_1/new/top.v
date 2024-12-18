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
    //.locked()
    //.reset()
    );

    reg [7:0] r_ja = 0;    
    //reg [3:0] r_led = 0;
    
    // 250 000 000 / 115 200 = 2170.1388 ~ 2170
    parameter TICKS_PER_BIT = 2170;
    parameter UART_BITS = 8;
    parameter UART_WORDS = 10;
    
    //reg uart_rx_pin;
    wire [7:0] uart_data;
    wire uart_rx_done;
    wire busy;
    
    reg rst = 0;
    wire [(UART_BITS*UART_WORDS)-1:0] shift_reg_data;
    wire o_DV;
        
    
    uart_rx #(.TICKS_PER_BIT(TICKS_PER_BIT)) u_uart_rx (
    .clk(clk), // input clock
    .uart_rx_pin(uart_rx_pin), // Input RX data pin    
    .data(uart_data), // output data
    .uart_rx_done(uart_rx_done), // Pull high for 1 clock cycle when transmission complete
    .busy(busy) // high while receiving
    );
    
    inst_shift_reg #(.BITS(UART_BITS), .WORDS(UART_WORDS)) u_inst_shift_reg(
    .clk(clk),
    .data(uart_data),
    .i_DV(uart_rx_done),
    .rst(rst),
    .shift_reg_data(shift_reg_data),
    .o_DV(o_DV)
    );
    
    reg [7:0] wr_addr = 0;
    wire [7:0] addr;
    reg i_Wr_DV = 0;
    reg [63:0] i_Wr_Data = 0;
    reg i_Rd_En = 1;
    
    wire o_Rd_DV;
    wire [63:0] o_Rd_Data;
    wire [7:0] pulse;
    wire [19:0] data;
    wire [3:0] op_code;
    wire [31:0] delay;
        
    RAM_2Port #(.WIDTH(64), .DEPTH(256)) u_RAM_2Port (
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
    //.pulse(pulse),
    //.data(data),
    //.op_code(op_code),
    //.delay(delay)
    );
    
    // TESTING
    
    assign pulse = o_Rd_Data[63:56];
    assign data = o_Rd_Data[55:36];
    assign op_code = o_Rd_Data[35:32];
    assign delay = o_Rd_Data[31:0];  
    
    reg pp_rst = 1;
    
    pulse_programmer_core u_ppc (
     .rst(pp_rst),
     .clk(clk),
     .addr(addr),     
     .op_code(op_code),
     .delay(delay),
     .data(data)
//     .trig(trig)
    );
    
    reg init = 1; // high when initializing


    always @(posedge clk)
    begin
        if (init)  // initialize memory
        begin
            wr_addr <= wr_addr + 1;            
            if (wr_addr == 255)
            begin
                wr_addr <= 0;
                i_Wr_DV <= 0;
                init <= 0;
                pp_rst <= 0;
            end
            else
            begin
                i_Wr_Data <= 0;

                i_Wr_DV <= 1;
            end
        end
    
        else if (o_DV)
        begin
            wr_addr <= shift_reg_data[71:64];        
            if (shift_reg_data[72] == 1) // write operation
            begin
                //r_led[0] <= 1;
                i_Wr_Data <= shift_reg_data[63:0];
                //i_Wr_Data <= 8'haa; // troubleshooting, this doesn't work
                i_Wr_DV <= 1;
                //i_Rd_En <= 0;
            end
            else // read operation
            begin
                //r_led[1] <= 1;
                //i_Rd_En <= 1;
                i_Wr_DV <= 0;
            end

        end
        else
        begin
            //i_Rd_En <= 0;
            i_Wr_DV <= 0;
        end
    end
    
//    always @(posedge clk)
//    begin
//        if (o_Rd_DV)
//        begin
//            //r_ja <= o_Rd_Data; // it does get to this line when writing RX
//            //r_led[2] <= 1;
//        end
//    end
    
    
    assign ja = pulse;
    assign led[3:0] = addr[3:0];
    
    
endmodule
