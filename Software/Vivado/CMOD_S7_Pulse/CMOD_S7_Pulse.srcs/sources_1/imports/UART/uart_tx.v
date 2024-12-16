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
    input clk, // input clock
    input [7:0] data, // input data byte to transmit
    input tx_data_ready, // Only pull high for single clock cycle when data is ready
    output uart_tx_pin, // Output TX data pin
    output uart_tx_done, // Pull high for 1 clock cycle when transmission complete
    output busy // High during transmission
    );
    
    reg [7:0] r_data; // Register to store data for transfer
    
    // 12 000 000 / 115200 = 104.16 ~ 104
    reg [$clog2(TICKS_PER_BIT):0] tick_count = 0;

    reg r_uart_tx_pin = 1; // Register to store TX bit
    reg r_uart_tx_done = 0; // Register to store TX finished bit
    
    reg [1:0] MODE = 2'b00;
    reg [1:0] TX_IDLE = 2'b00;
    reg [1:0] TX_START = 2'b01;
    reg [1:0] TX_DATA = 2'b10;
    reg [1:0] TX_STOP = 2'b11;
    
    reg [3:0] index = 0; // Index of data to transmit
    
    always @(posedge clk) 
    begin
        if (r_uart_tx_done == 1) 
        begin
            r_uart_tx_done <= 0;
        end
    end
    
    always @(posedge clk) 
    begin
        case (MODE)
            TX_IDLE: 
            begin
                tick_count <= 0;
                index <= 0;
                r_uart_tx_pin <= 1; // HIGH for IDLE     
                    
                if (tx_data_ready) 
                begin
                    MODE <= TX_START;                
                    r_data <= data;
                end                
            end
            
            TX_START: 
            begin
                index <= 0;
                r_uart_tx_pin <= 0; // Pull low for start bit low
                if (tick_count >= TICKS_PER_BIT) 
                begin
                    MODE <= TX_DATA;
                    tick_count <= 0;
                end
                
                else 
                begin
                    tick_count <= tick_count + 1;
                end
            
            end
            
            TX_DATA: 
            begin
                r_uart_tx_pin <= r_data[index];                                
                if (tick_count >= TICKS_PER_BIT)
                begin
                tick_count <= 0;
                    if (index == 7)
                    begin
                        MODE <= TX_STOP;
                        index <= 0;                
                    end

                    else
                    begin
                        MODE <= TX_DATA;
                        index <= index + 1;                    
                    end
                
                end                   
                else
                begin
                    MODE <= TX_DATA;                
                    tick_count <= tick_count + 1;
                end
                end
            
            TX_STOP: 
            begin
                r_uart_tx_pin <= 1;
                index <= 0;
                if (tick_count >= TICKS_PER_BIT) 
                begin
                    MODE <= TX_IDLE;
                    tick_count <= 0;
                    r_uart_tx_done <= 1;
                end
                else 
                begin
                    tick_count <= tick_count + 1;
                    MODE <= TX_STOP;
                end
            end
            
            default: begin
                tick_count <= 0;
                index <= 0;
                MODE <= TX_IDLE;
            end
        endcase
    end
    
    assign uart_tx_pin = r_uart_tx_pin;
    assign uart_tx_done = r_uart_tx_done;
    assign busy = MODE != 0;
    
endmodule
