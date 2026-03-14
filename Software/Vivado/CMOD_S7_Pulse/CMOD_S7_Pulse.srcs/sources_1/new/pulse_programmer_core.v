`timescale 1ns / 1ps

module pulse_programmer_core (
    input  rst,
    input  clk,
    output reg [11:0] addr = 0,
    input  [3:0]  op_code,
    input  [31:0] delay,
    input  [19:0] data,
    input  trig
);
    
    reg [31:0] count = 0;
    reg        startup = 1'b1;          // ← only new signal

    localparam [3:0] NO_OP = 4'b0000;
    localparam [3:0] DELAY = 4'b0001;
    localparam [3:0] WAIT  = 4'b1000;

    always @(posedge clk) begin
        if (rst) begin
            addr    <= 8'd0;
            count   <= 32'd0;
            startup <= 1'b1;
        end 
        else if (startup) begin
            startup <= 1'b0;
            // We sit here for exactly ONE clock so the BRAM has time
            // to output the correct data for addr = 0.
            // addr and count are held steady.
        end 
        else begin
            // ────── NORMAL OPERATION ──────
            // At this point op_code/delay/data are guaranteed to be BRAM[addr]
            case (op_code)
                NO_OP: begin
                    addr <= addr + 1;
                end

                DELAY: begin
                    if (count >= delay) begin
                        count <= 0;
                        addr  <= addr + 1;
                    end else begin
                        count <= count + 1;
                    end
                end

                WAIT: begin
                    if (trig) begin
                        addr <= addr + 1;
                    end
                    // else stay here waiting for trigger
                end

                default: begin
                    addr <= addr + 1;
                end
            endcase
        end
    end

endmodule
