`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2024 07:32:04 PM
// Design Name: 
// Module Name: uart_rx
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


module uart_rx #(parameter TICKS_PER_BIT = 104) (
    input clk, // input clock
    input uart_rx_pin, // Input RX data pin    
    output [7:0] data, // output data
    output uart_rx_done, // Pull high for 1 clock cycle when transmission complete
    output busy // high while receiving
    );
    
    // TICKS_PER_BIT = clk / baud_rate
    // 12 000 000 / 115 200 = 104.16 ~ 104
    
    reg [7:0] r_data = 0; // Register to store data for transfer
    
    reg [$clog2(TICKS_PER_BIT):0] tick_count = 0;

    reg r_uart_rx_done = 0; // Register to store TX finished bit
    
    reg [1:0] MODE = 2'b00;
    reg [1:0] RX_IDLE = 2'b00;
    reg [1:0] RX_START = 2'b01;
    reg [1:0] RX_DATA = 2'b10;
    reg [1:0] RX_STOP = 2'b11;
    
    reg [3:0] index = 0; // Index of data to transmit
    
    
    always @(posedge clk) 
    begin
        case (MODE)
            RX_IDLE:
            begin
                r_uart_rx_done <= 0;             
                tick_count <= 0;
                index <= 0;
           
                if (uart_rx_pin == 0) // if rx pin goes low, Start bit detected
                begin
                    MODE <= RX_START;                
                    r_data <= 0; // Reset data to 0;
                end                
            end
            
            RX_START: 
            begin
                r_uart_rx_done <= 0; 
                index <= 0;
                if (tick_count >= TICKS_PER_BIT/2)  // Wait 0.5 cycles
                begin
                    MODE <= RX_DATA;
                    tick_count <= 0;
                end
                
                else 
                begin
                    tick_count <= tick_count + 1;
                end
            
            end
            
            RX_DATA: 
            begin
                r_uart_rx_done <= 0;                 
                if ((tick_count >= TICKS_PER_BIT) & (index == 7)) 
                begin
                    MODE <= RX_STOP;
                    tick_count <= 0;
                    index <= 0;
                    r_data[7:0] <= {uart_rx_pin, r_data[7:1]};
                end
                
                else if (tick_count >= TICKS_PER_BIT)
                begin 
                    MODE <= RX_DATA;
                    index <= index + 1;
                    tick_count <= 0;
                    r_data[7:0] <= {uart_rx_pin, r_data[7:1]};
                end
                                
                else
                begin
                    MODE <= RX_DATA;                
                    tick_count <= tick_count + 1;
                end
            end
            
            RX_STOP:
            begin
                
                index <= 0;
                if (tick_count >= TICKS_PER_BIT) 
                begin
                    MODE <= RX_IDLE;
                    tick_count <= 0;
                    r_uart_rx_done <= 1;
                end
                
                else 
                begin
                    tick_count <= tick_count + 1;
                    MODE <= RX_STOP;
                    r_uart_rx_done <= 0; 
                end
            end
            
            default: begin
                tick_count <= 0;
                index <= 0;
                MODE <= RX_IDLE;
                r_uart_rx_done <= 0;
            end
        endcase
    end
    
    assign uart_rx_done = r_uart_rx_done;
    assign busy = MODE != 0;
    assign data = r_data;
    
endmodule
