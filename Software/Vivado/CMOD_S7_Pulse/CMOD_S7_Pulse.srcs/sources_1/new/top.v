`timescale 1ns / 1ps

module top(
    input clk_12MHz,
    input wire uart_rx_pin,
    input [1:0] btn,
    output wire [7:0] ja,
    output wire [3:0] led
    );
    
    wire clk; // 125 MHz Clock
    wire trig;
    wire pll_locked;
    wire pll_locked_ext;
    wire use_external_clk;
    
    assign reset = 0;
    
    assign trig = btn[0];
    
    //clock_wizard_wrapper u_clock_wizard_wrapper_int
    clk_wiz_0_new u_clock_wizard_wrapper_int
   (
    .clk_in1(clk_12MHz),
    .clk_out1(clk),
    .locked(pll_locked),
    .reset(reset)
    );

    //reg [7:0] r_ja = 0;       
    
    parameter TICKS_PER_BIT = 2170; // 250 000 000 / 115 200 = 2170.1388 ~ 2170
    
    //parameter TICKS_PER_BIT = 1085; // 125 000 000 / 115 200 = 1085.07 ~ 1085
    parameter UART_BITS = 8;
    parameter UART_WORDS = 10;
    
    //reg uart_rx_pin;
    wire [7:0] uart_data;
    wire uart_rx_done;
    wire uart_rx_busy;
    
    reg rst = 0;
    wire [(UART_BITS*UART_WORDS)-1:0] shift_reg_data;
    wire o_DV;
        
    
    uart_rx #(.TICKS_PER_BIT(TICKS_PER_BIT)) u_uart_rx (
    .clk(clk), // input clock
    .uart_rx_pin(uart_rx_pin), // Input RX data pin    
    .data(uart_data), // output data
    .uart_rx_done(uart_rx_done), // Pull high for 1 clock cycle when transmission complete
    .busy(uart_rx_busy) // high while receiving
    );
    
    inst_shift_reg #(.BITS(UART_BITS), .WORDS(UART_WORDS)) u_inst_shift_reg(
    .clk(clk),
    .data(uart_data),
    .i_DV(uart_rx_done),
    .rst(rst),
    .shift_reg_data(shift_reg_data),
    .o_DV(o_DV)
    );
    
    reg [11:0] wr_addr = 0;
    wire [11:0] addr;
    reg i_Wr_DV = 0;
    reg [63:0] i_Wr_Data = 0;
    reg i_Rd_En = 1;
    
    wire o_Rd_DV;
    wire [63:0] o_Rd_Data;
    wire [7:0] pulse;
    wire [19:0] data;
    wire [3:0] op_code;
    wire [31:0] delay;

    reg [11:0] addr_reg;
    always @(posedge clk) begin
        addr_reg <= addr;
    end
    
    
    assign pulse = o_Rd_Data[63:56];
    assign data = o_Rd_Data[55:36];
    assign op_code = o_Rd_Data[35:32];
    assign delay = o_Rd_Data[31:0];   
    
        
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
    
    
    reg pp_rst = 1;
    
    pulse_programmer_core u_ppc (
     .rst(pp_rst),
     .clk(clk),
     .addr(addr),     
     .op_code(op_code),
     .delay(delay),
     .data(data),
     .pulse(pulse),
     .trig(trig),
     .pulse_out(ja)
    );
    
    reg init = 1; // high when initializing

    wire [3:0] COMMAND;
    
    reg [3:0] READ = 4'b0000;
    reg [3:0] WRITE = 4'b0001;
    reg [3:0] START = 4'b0010;
    reg [3:0] STOP = 4'b0011;
    
    assign COMMAND = shift_reg_data[79:76];
    
    reg start = 1'b1;
    
    always @(posedge clk)
    begin
        if (init)  // initialize memory
        begin
            if (~start) begin
            wr_addr <= wr_addr + 1;
            end
            else begin
            start <= 0;
            end
            
            
            if (wr_addr == 4095)
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
            wr_addr <= shift_reg_data[75:64];
            case (COMMAND)
                WRITE: 
//            if (shift_reg_data[76] == 1) // write operation
                begin
                    i_Wr_Data <= shift_reg_data[63:0];
                    i_Wr_DV <= 1;
                end
                
                START:
                begin
                    pp_rst <= 0;
                end
                STOP:
                begin
                    pp_rst <= 1;
                end
                default:
            //else // read operation
                begin
                    i_Wr_DV <= 0;
                end
            endcase

        end
        else
        begin
            //i_Rd_En <= 0;
            i_Wr_DV <= 0;
        end
    end
    
    
    //assign ja = pulse;
    assign led[0] = pll_locked;
    assign led[1] = ~pp_rst;
    assign led[2] = uart_rx_busy;
    assign led[3] = ~pll_locked;
    //assign led[3:0] = addr[3:0];
//    assign led[3:0] = delay[3:0]; 
//    assign led[3:0] = op_code[3:0];
    
endmodule
