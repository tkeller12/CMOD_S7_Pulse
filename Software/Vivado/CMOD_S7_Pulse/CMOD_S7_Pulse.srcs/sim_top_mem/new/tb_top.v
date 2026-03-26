`timescale 1ns / 1ps

module tb_top;

    // Testbench signals
    reg clk_12MHz;
    reg [1:0] btn;

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
    
    wire stack_ptr;
    //wire [15:0] count_stack [0:7];

    // Instantiate top (uart_rx_pin is left unconnected - it's ok for simulation)
    top DUT (
        .clk_12MHz   (clk_12MHz),
        .uart_rx_pin (1'b1),     // idle high
        .btn         (btn),
        .ja          (ja),
        .led         (led)
    );

    // Connect internal signals
    assign clk       = DUT.clk;
    assign addr      = DUT.addr;
    assign o_Rd_Data = DUT.o_Rd_Data;
    assign pulse     = DUT.pulse;
    assign data      = DUT.data;
    assign op_code   = DUT.op_code;
    assign delay     = DUT.delay;
    assign o_Rd_DV   = DUT.o_Rd_DV;
    
    assign stack_ptr = DUT.u_ppc.stack_ptr;
    //assign count_stack = DUT.u_ppc.count_stack;

    // ------------------------------------------------------------------
    // 12 MHz clock
    // ------------------------------------------------------------------
    initial begin
        clk_12MHz = 0;
        forever #41.6667 clk_12MHz = ~clk_12MHz;
    end

    // ------------------------------------------------------------------
    // Load BRAM from .mem file
    // ------------------------------------------------------------------
    initial begin
        #50_000;   // wait for PLL lock + initial reset

        $display("[%0t] INFO: Loading pulse_program.mem into BRAM...", $time);

        $readmemh("pulse_program.mem", DUT.u_RAM_2Port.r_Mem);

        $display("[%0t] INFO: BRAM load command executed.", $time);
    end

    // ------------------------------------------------------------------
    // Test sequence
    // ------------------------------------------------------------------
    initial begin
        btn = 2'b00;

        // Wait until BRAM is loaded and init phase in top.v is done
        #100_000;

        $display("[%0t] INFO: Starting pulse programmer test...", $time);

        // btn[1] can be used as STOP if you want, but we keep pp_rst low after init
        //btn[0] = 1'b1;   // trigger / start
        //#20_000;
//        btn[0] = 1'b0;

        $display("[%0t] INFO: Trigger asserted - program should now run", $time);

        // Run long enough to see your pulses on ja
        #100_000;   // 2 ms - increase if your program is longer

        $display("[%0t] INFO: Simulation finished. Check waveform on ja[7:0].", $time);
        $finish;
    end

    // Optional monitoring
    // initial $monitor("[%0t] addr=%0d op=%h pulse=0x%h ja=0x%h", $time, addr, op_code, pulse, ja);

endmodule
