`timescale 1ns / 1ps

module pulse_programmer_core (
    input  rst,
    input  clk,
    output reg [11:0] addr = 0,           // 12 bits (0-4095)
    input  [3:0]  op_code,
    input  [31:0] delay,
    input  [19:0] data,
    input  trig
);

    reg [31:0] count   = 0;
    reg        startup = 1'b1;
    reg        trig_meta, trig_sync;

    localparam [3:0] NO_OP = 4'b0000;
    localparam [3:0] DELAY = 4'b0001;
    localparam [3:0] WAIT  = 4'b1000;
    localparam [3:0] JUMP  = 4'b0011;

    always @(posedge clk) begin
        if (rst) begin
            addr      <= 12'd0;
            count     <= 32'd0;
            startup   <= 1'b1;
            trig_meta <= 1'b0;
            trig_sync <= 1'b0;
        end
        else begin
            // Synchronizer for external trigger (recommended)
            trig_meta <= trig;
            trig_sync <= trig_meta;

            if (startup) begin
                // One-cycle delay to let BRAM output correct value for addr=0
                startup <= 1'b0;
            end
            else begin
                case (op_code)
                    NO_OP: begin
                        addr <= addr + 1;
                    end

                    DELAY: begin
                        if (count >= delay) begin
                            count <= 0;
                            addr  <= addr + 1;
                        end
                        else begin
                            count <= count + 1;
                        end
                    end

                    WAIT: begin
                        if (trig_sync) begin
                            addr <= addr + 1;
                        end
                        // else stay here
                    end

                    JUMP: begin
                        addr  <= data[11:0];     // target address from lower 12 bits of data field
                        count <= 0;              // reset delay counter on control-flow change
                    end

                    default: begin
                        addr <= addr + 1;
                    end
                endcase
            end
        end
    end

endmodule
