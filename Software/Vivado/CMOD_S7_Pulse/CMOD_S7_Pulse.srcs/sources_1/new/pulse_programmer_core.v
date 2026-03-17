`timescale 1ns / 1ps

module pulse_programmer_core (
    input  rst,
    input  clk,
    output reg [11:0] addr = 0,
    input  [3:0]  op_code,      // direct from BRAM
    input  [31:0] delay,
    input  [19:0] data,
    input  [7:0]  pulse,        // ← NEW: pulse field from BRAM
    input  trig,
    output reg [7:0] pulse_out = 8'b0  // ← NEW: latched pulse drives ja
);

    reg [31:0] count = 0;
    reg        startup = 1'b1;
    reg        trig_meta, trig_sync;

    // === Instruction storage (unchanged) ===
    reg [3:0]  current_op;
    reg [31:0] current_delay;
    reg [19:0] current_data;
    reg        instr_valid_internal = 1'b0;

    localparam [3:0] NO_OP = 4'b0000;
    localparam [3:0] DELAY = 4'b0001;
    localparam [3:0] WAIT  = 4'b1000;
    localparam [3:0] JUMP  = 4'b0011;

    always @(posedge clk) begin
        if (rst) begin
            addr                <= 12'd0;
            count               <= 32'd0;
            startup             <= 1'b1;
            trig_meta           <= 1'b0;
            trig_sync           <= 1'b0;
            instr_valid_internal <= 1'b0;
            pulse_out           <= 8'b0;
        end
        else begin
            trig_meta <= trig;
            trig_sync <= trig_meta;

            if (startup) begin
                startup <= 1'b0;
            end
            else if (!instr_valid_internal) begin
                // === LOAD PHASE (absorbs BRAM latency) ===
                current_op    <= op_code;
                current_delay <= delay;
                current_data  <= data;
                pulse_out     <= pulse;          // ← LATCHED HERE
                instr_valid_internal <= 1'b1;
            end
            else begin
                // === EXECUTE PHASE (use saved values) ===
                case (current_op)
                    NO_OP: begin
                        addr <= addr + 1;
                        count <= 0;
                        instr_valid_internal <= 1'b0;
                    end

                    DELAY: begin
                        if (count >= current_delay) begin
                            count <= 0;
                            addr  <= addr + 1;
                            instr_valid_internal <= 1'b0;
                        end
                        else begin
                            count <= count + 1;
                            // pulse_out stays exactly the same (latched)
                        end
                    end

                    WAIT: begin
                        if (trig_sync) begin
                            addr <= addr + 1;
                            count <= 0;
                            instr_valid_internal <= 1'b0;
                        end
                        // pulse_out stays latched
                    end

                    JUMP: begin
                        addr <= current_data[11:0];
                        count <= 0;
                        instr_valid_internal <= 1'b0;
                    end

                    default: begin
                        addr <= addr + 1;
                        count <= 0;
                        instr_valid_internal <= 1'b0;
                    end
                endcase
            end
        end
    end

endmodule