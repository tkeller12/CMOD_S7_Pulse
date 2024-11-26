`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Timothy Keller
// 
// Create Date: 11/15/2024 09:16:59 PM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx #(parameter TICKS_PER_BIT = 104) (
    clk, // input clock
    data, // input data byte to transmit
    tx_data_ready, // Only pull high for single clock cycle when data is ready
    uart_tx_pin, // Output TX data pin
    uart_tx_done // Pull high for 1 clock cycle when transmission complete
    );
    
    input clk; // Clock, 12 MHz
    input [7:0] data; // Input data for transfer
    reg [7:0] r_data; // Register to store data for transfer
    input tx_data_ready; // Pull high to start transmission
    
    // 12 000 000 / 115200 = 104.16 ~ 104
    //parameter [11:0] ticks_per_bit = 104; // number of clock ticks to wait during transfer    
    reg [$clog2(TICKS_PER_BIT)-1:0] tick_count = 0;

    
    output wire uart_tx_pin; // TX data output
    output wire uart_tx_done; // TX transmission complete signal
    reg r_uart_tx_pin = 1; // Register to store TX bit
    reg r_uart_tx_done = 0; // Register to store TX finished bit
    
    reg [1:0] MODE = 0;
    reg [1:0] TX_IDLE = 0;
    reg [1:0] TX_START = 1;
    reg [1:0] TX_DATA = 2;
    reg [1:0] TX_STOP = 3;
    
    reg [3:0] index = 0; // Index of data to transmit
    
    reg [11:0] tick_count = 0; 
    
    always @(posedge clk) begin
        if (tx_data_ready) begin
            r_data <= data;
            MODE <= TX_START;
        end
    end
    
    always @(posedge clk) begin
        if (r_uart_tx_done == 1) begin
            r_uart_tx_done <= 0;
        end
    end
    
    always @(posedge clk) begin
        case (MODE)
        
            TX_IDLE: begin
                tick_count <= 0;
                index <= 0;
                r_uart_tx_pin <= 1; // HIGH for IDLE
                
            end
            
            TX_START: begin
                index <= 0;
                r_uart_tx_pin <= 0; // Pull low for start bit low
                if (tick_count >= TICKS_PER_BIT) begin
                    MODE <= TX_DATA;
                    tick_count <= 0;
                    index <= 0;
                end
                
                else begin
                    tick_count <= tick_count + 1;
                end
            
            end
            
            TX_DATA: begin
                
                if ((tick_count >= TICKS_PER_BIT) & (index >= 7)) begin
                    MODE <= TX_STOP;
                    tick_count = 0;
                    end
                else if (tick_count >= TICKS_PER_BIT) begin 
                    index <= index + 1;
                    tick_count <= 0;
                    end
                    
                else
                    r_uart_tx_pin <= r_data[index];
                    tick_count = tick_count + 1;
                end

            
            TX_STOP: begin
                r_uart_tx_pin <= 1;
                if (tick_count >= TICKS_PER_BIT) begin
                    MODE <= TX_IDLE;
                    tick_count <= 0;
                    r_uart_tx_done <= 1;
                    end
                else
                    tick_count <= tick_count + 1;
            end
            
            default: begin
                tick_count <= 0;
                MODE <= TX_IDLE;

            end
        endcase
    end
    
    assign uart_tx_pin = r_uart_tx_pin;
    assign uart_tx_done = r_uart_tx_done;
    
endmodule
