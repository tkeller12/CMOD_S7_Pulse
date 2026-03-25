`timescale 1ns / 1ps

module pulse_programmer_core (
    input rst,
    input clk,
    input start,         // one-cycle pulse to (re)start the sequence
    input stop,          // one-cycle pulse to halt immediately
    output reg [11:0] addr = 0,
    input [3:0] op_code,
    input [31:0] delay,
    input [19:0] data,
    input [7:0] pulse,
    input trig,
    output reg [7:0] pulse_out = 8'b0,
    output wire running
);

    reg running_reg = 1'b0;
    
    assign running = running_reg;

    reg [31:0] count = 0;
    reg trig_meta, trig_sync;
    reg start_meta, start_sync;
    reg stop_meta, stop_sync;

    // Instruction pipeline registers
    reg [3:0]  current_op;
    reg [31:0] current_delay;
    reg [19:0] current_data;
    reg instr_valid_internal = 1'b0;

    localparam [3:0] NO_OP  = 4'b0000;
    localparam [3:0] DELAY  = 4'b0001;
    localparam [3:0] HALT   = 4'b0111;
    localparam [3:0] JUMP   = 4'b0011;
    localparam [3:0] WAIT   = 4'b1000;

    always @(posedge clk) begin
        if (rst) begin
            addr                 <= 12'd0;
            count                <= 32'd0;
            running_reg          <= 1'b1; // setting to 1 for testing
            trig_meta            <= 1'b0;
            trig_sync            <= 1'b0;
            start_meta           <= 1'b0;
            start_sync           <= 1'b0;
            stop_meta            <= 1'b0;
            stop_sync            <= 1'b0;
            instr_valid_internal <= 1'b0;
            pulse_out            <= 8'b0;
        end
        else begin
            // Metastability synchronizers
            start_meta <= start;
            start_sync <= start_meta;
            stop_meta  <= stop;
            stop_sync  <= stop_meta;

            // Priority: stop > start > normal operation
            if (stop_sync) begin
                running_reg <= 1'b0;
            end
            else if (start_sync) begin
                running_reg          <= 1'b1;
                addr                 <= 12'd0;
                count                <= 32'd0;
                instr_valid_internal <= 1'b0;
                // pulse_out keeps its last value until a DELAY/WAIT loads a new one
            end
            else if (!running_reg) begin
                // Halted: do nothing, keep last pulse_out and addr
            end
            else begin
                // === Normal running state ===
                trig_meta <= trig;
                trig_sync <= trig_meta;

                if (!instr_valid_internal) begin
                    // === LOAD PHASE ===
                    current_op    <= op_code;
                    current_delay <= delay;
                    current_data  <= data;

                    // Only update pulse_out for instructions that should drive outputs
                    if (op_code == DELAY || op_code == WAIT) begin
                        pulse_out <= pulse;
                    end
                    // JUMP, NO_OP, HALT do NOT change pulse_out

                    instr_valid_internal <= 1'b1;
                end
                else begin
                    // === EXECUTE PHASE ===
                    case (current_op)
                        NO_OP: begin
                            addr <= addr + 1;
                            count <= 0;
                            instr_valid_internal <= 1'b0;
                        end

                        DELAY: begin
                            if (count >= current_delay) begin
                                count <= 0;
                                addr <= addr + 1;
                                instr_valid_internal <= 1'b0;
                            end else begin
                                count <= count + 1;
                            end
                        end

                        WAIT: begin
                            if (trig_sync) begin
                                addr <= addr + 1;
                                count <= 0;
                                instr_valid_internal <= 1'b0;
                            end
                        end

                        JUMP: begin
                            addr <= current_data[11:0];
                            count <= 0;
                            instr_valid_internal <= 1'b0;
                        end

                        HALT: begin
                            running_reg <= 1'b0;        // soft halt
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
    end

endmodule