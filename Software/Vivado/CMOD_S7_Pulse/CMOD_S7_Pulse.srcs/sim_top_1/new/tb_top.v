`timescale 1ns / 1ps

module tb_top;

    // Testbench signals
    reg         clk_12MHz;
    reg         uart_rx_pin;
    reg  [1:0]  btn;
    
    // Make internal DUT signals visible
    wire        clk;           // 125 MHz clock
    wire [11:0] addr;          // BRAM Address
    
    // DUT outputs
    wire [7:0]  ja;
    wire [3:0]  led;

    // Instantiate the top module
    top DUT (
        .clk_12MHz   (clk_12MHz),
        .uart_rx_pin (uart_rx_pin),
        .btn         (btn),
        .ja          (ja),
        .led         (led)
    );
    
    // Connect internal clk to testbench wire
    assign clk = DUT.clk;    
    assign addr = DUT.addr;
    
    // ------------------------------------------------------------------
    // 12 MHz clock generation (external input to PLL)
    // ------------------------------------------------------------------
    initial begin
        clk_12MHz = 1'b0;
        forever #41.6667 clk_12MHz = ~clk_12MHz;   // 12 MHz period = 83.333 ns
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
    // Test sequence
    // ------------------------------------------------------------------
    initial begin
        // Initial conditions
        uart_rx_pin = 1'b1;   // UART idle
        btn         = 2'b00;

        // Wait for FPGA initialization (RAM zeroing + PLL lock)
        // ~4096 cycles @ 125 MHz ≈ 33 µs, plus PLL lock margin
        #200_000;   // 200 µs (safe)

        $display("[%0t] INFO: Initialization complete. Starting test sequence...", $time);

        // 1. STOP the pulse programmer (pp_rst = 1)
        send_stop_command();
        #200_000;   // Give UART receiver and shift reg time to process
        $display("[%0t] INFO: STOP command sent (pp_rst asserted)", $time);

        // 2. Write a single instruction to RAM address 0:
        //    pulse = 8'hAA (visible on ja)
        //    op_code = DELAY (4'b0001)
        //    delay = 10_000 clocks @ 125 MHz ≈ 80 µs high pulse
        //    data = 20'h0 (not used for DELAY)
        send_write_command(
            12'd0,
            {8'hAA, 20'h00000, 4'b0001, 32'd10000}
        );
        #300_000;   // Wait for write to be processed
        $display("[%0t] INFO: WRITE to addr=0 completed (DELAY 10k cycles, pulse=0xAA)", $time);

        // 3. START the pulse programmer (pp_rst = 0)
        send_start_command();
        #100_000;
        $display("[%0t] INFO: START command sent - execution begins at addr=0", $time);

        // Optional: pulse the external trigger (btn[0]) - not needed for DELAY but shown for completeness
        #50_000;
        btn[0] = 1'b1;
        #20_000;
        btn[0] = 1'b0;

        // Run long enough to see the pulse and the transition to addr=1 (which is still 0x00)
        #500_000;   // 500 µs - enough for the 80 µs pulse + extra NO_OP cycles

        // End simulation
        $display("[%0t] INFO: Test completed. Check waveform for ja[7:0] pulsing 0xAA for ~80 µs.", $time);
        $finish;
    end

    // ------------------------------------------------------------------
    // Optional monitoring (uncomment if you want console output)
    // ------------------------------------------------------------------
    // initial begin
    //     $monitor("[%0t] ja = 0x%h  led = 0x%h  btn = %b", $time, ja, led, btn);
    // end

endmodule
