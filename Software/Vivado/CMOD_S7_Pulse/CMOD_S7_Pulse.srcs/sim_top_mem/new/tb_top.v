`timescale 1ns / 1ps

module tb_top;

    // Testbench signals
    reg clk_12MHz;
    reg uart_rx_pin = 1'b1;
    reg [1:0] btn = 2'b0;

    // Internal signals for monitoring
    wire clk;
    wire [11:0] addr;
    wire [63:0] o_Rd_Data;
    wire [7:0]  pulse;
    wire [19:0] data;
    wire [3:0]  op_code;
    wire [31:0] delay;
    wire        o_Rd_DV;
    wire [7:0]  ja;
    wire [3:0]  led;
    wire [3:0] current_op;
    wire [31:0] current_delay;
    wire [19:0] current_data;
    
    wire execute;
    wire stall_load;
    
    wire pp_running;
    
    //wire init;
    
    wire [2:0] stack_ptr;
    //wire [15:0] count_stack [0:7];
    
    wire pp_start;
//    wire pp_stop;

    // Instantiate top (uart_rx_pin is left unconnected - it's ok for simulation)
    top DUT (
        .clk_12MHz   (clk_12MHz),
        .uart_rx_pin (uart_rx_pin),     // idle high
        .btn         (btn),
        .ja          (ja),
        .led         (led)
    );

    // Connect internal signals
    assign clk       = DUT.clk;
//    assign init      = DUT.init;
    assign addr      = DUT.addr;
    assign o_Rd_Data = DUT.o_Rd_Data;
    assign pulse     = DUT.pulse;
    assign data      = DUT.data;
    assign op_code   = DUT.op_code;
    assign delay     = DUT.delay;
    assign o_Rd_DV   = DUT.o_Rd_DV;
    

    
    assign stack_ptr = DUT.u_ppc.stack_ptr;
    //assign count_stack = DUT.u_ppc.count_stack;
    
    assign pp_start = DUT.pp_start;
    
    assign current_op = DUT.u_ppc.current_op;
    assign current_delay = DUT.u_ppc.current_delay;
    assign current_data = DUT.u_ppc.current_data;
    
    assign pp_running = DUT.pp_running;
    
    assign execute = DUT.u_ppc.execute;
    assign stall_load = DUT.u_ppc.stall_load;

    // ------------------------------------------------------------------
    // 12 MHz clock
    // ------------------------------------------------------------------
    initial begin
        clk_12MHz = 0;
        forever #41.6667 clk_12MHz = ~clk_12MHz;
    end
    
    // ------------------------------------------------------------------
    // UART parameters (115200 baud)
    // ------------------------------------------------------------------
    localparam real BIT_TIME = 1_000_000_000.0 / 115_200.0;  // ≈ 8680.555 ns

    // ------------------------------------------------------------------
    // Task: Send one UART byte (start bit + 8 data LSB-first + stop bit)
    // ------------------------------------------------------------------
    task send_uart_byte(input [7:0] data);
        integer i;
        begin
            // Start bit (low)
            uart_rx_pin = 1'b0;
            #(BIT_TIME);
            
            // 8 data bits, LSB first
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx_pin = data[i];
                #(BIT_TIME);
            end
            
            // Stop bit (high)
            uart_rx_pin = 1'b1;
            #(BIT_TIME);
        end
    endtask

    // ------------------------------------------------------------------
    // Task: Send a WRITE command (10 UART bytes)
    //   Byte 0: {COMMAND=4'b0001, addr[11:8]}
    //   Byte 1: addr[7:0]
    //   Bytes 2-9: 64-bit RAM data (MSB first)
    // ------------------------------------------------------------------
    task send_write_command(input [11:0] addr, input [63:0] ram_data);
        reg [7:0] byte0;
        begin
            byte0 = {4'b0001, addr[11:8]};
            
            send_uart_byte(byte0);               // Byte 0
            send_uart_byte(addr[7:0]);           // Byte 1
            send_uart_byte(ram_data[63:56]);     // Byte 2
            send_uart_byte(ram_data[55:48]);     // Byte 3
            send_uart_byte(ram_data[47:40]);     // Byte 4
            send_uart_byte(ram_data[39:32]);     // Byte 5
            send_uart_byte(ram_data[31:24]);     // Byte 6
            send_uart_byte(ram_data[23:16]);     // Byte 7
            send_uart_byte(ram_data[15:8]);      // Byte 8
            send_uart_byte(ram_data[7:0]);       // Byte 9
        end
    endtask

    // ------------------------------------------------------------------
    // Task: Send START command (COMMAND = 4'b0010)
    // ------------------------------------------------------------------
    task send_start_command;
        begin
            send_uart_byte(8'h20);  // {4'b0010, 4'h0}
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
        end
    endtask

    // ------------------------------------------------------------------
    // Task: Send STOP command (COMMAND = 4'b0011)
    // ------------------------------------------------------------------
    task send_stop_command;
        begin
            send_uart_byte(8'h30);  // {4'b0011, 4'h0}
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
            send_uart_byte(8'h00);
        end
    endtask
    
    
    

    // ------------------------------------------------------------------
    // Load BRAM from .mem file
    // ------------------------------------------------------------------
    initial begin
        #100_000;   // wait for PLL lock + initial reset

        $display("[%0t] INFO: Loading pulse_program.mem into BRAM...", $time);

        $readmemh("pulse_program.mem", DUT.u_RAM_2Port.r_Mem);

        $display("[%0t] INFO: BRAM load command executed.", $time);
    end

    // ------------------------------------------------------------------
    // Test sequence
    // ------------------------------------------------------------------
    initial begin
        // btn = 2'b00;

        // Wait until BRAM is loaded and init phase in top.v is done
        #100_000;

        $display("[%0t] INFO: Starting pulse programmer test...", $time);

        // btn[1] can be used as STOP if you want, but we keep pp_rst low after init
        //btn[0] = 1'b1;   // trigger / start
        #50_000;
        send_start_command();
        #50_000;
        send_start_command();
        #50_000;
        send_start_command();
        #50_000;
        send_start_command();
//        btn[0] = 1'b0;

        $display("[%0t] INFO: Trigger asserted - program should now run", $time);

        // Run long enough to see your pulses on ja
        #100_000;   //  increase if your program is longer

        $display("[%0t] INFO: Simulation finished. Check waveform on ja[7:0].", $time);
        $finish;
    end

    // Optional monitoring
    // initial $monitor("[%0t] addr=%0d op=%h pulse=0x%h ja=0x%h", $time, addr, op_code, pulse, ja);

endmodule
