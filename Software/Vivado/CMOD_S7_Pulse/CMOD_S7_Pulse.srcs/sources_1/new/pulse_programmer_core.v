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

    parameter STACK_DEPTH = 8;                    // supports 8 nested loops
    reg [11:0] addr_stack [0:STACK_DEPTH-1];
    reg [15:0] count_stack [0:STACK_DEPTH-1];     // iteration counter
    reg [3:0]  stack_ptr = 0;                     // 0 = empty


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
    reg control_flow_change = 1'b0;

    localparam [3:0] NO_OP      = 4'b0000;
    localparam [3:0] DELAY      = 4'b0001;
    localparam [3:0] LOOP_START = 4'b0100;
    localparam [3:0] LOOP_END   = 4'b0101;
    localparam [3:0] HALT       = 4'b0111;
    localparam [3:0] JUMP       = 4'b0011;
    localparam [3:0] WAIT       = 4'b1000;

    always @(posedge clk) begin
        if (control_flow_change) control_flow_change <= 1'b0;
        
        if (rst) begin
            addr                 <= 12'd0;
            count                <= 32'd0;
            running_reg          <= 1'b0;
            trig_meta            <= 1'b0;
            trig_sync            <= 1'b0;
            start_meta           <= 1'b0;
            start_sync           <= 1'b0;
            stop_meta            <= 1'b0;
            stop_sync            <= 1'b0;
            instr_valid_internal <= 1'b0;
            pulse_out            <= 8'b0;
            stack_ptr            <= 4'b0;
            control_flow_change  <= 1'b0;
        end
        else begin
            // Metastability synchronizers
            start_meta <= start;
            start_sync <= start_meta;
            stop_meta  <= stop;
            stop_sync  <= stop_meta;
            trig_meta <= trig;
            trig_sync <= trig_meta;
            
            // Priority: stop > start > normal operation
            if (stop_sync) begin
                running_reg <= 1'b0;
                addr <= 0;
                stack_ptr <= 0;
                count <= 0;
            end
            else if (start_sync) begin
                running_reg          <= 1'b1;
                addr                 <= 12'd0;
                count                <= 32'd0;
                instr_valid_internal <= 1'b0;
                stack_ptr            <= 4'b0;
                // pulse_out keeps its last value until a DELAY/WAIT loads a new one
            end
            else if (!running_reg) begin
                // Halted: do nothing, keep last pulse_out and addr
            end
            else begin
                // === Normal running state ===


                if (!instr_valid_internal && !control_flow_change) begin
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
                else if (instr_valid_internal) begin
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
                            control_flow_change <= 1'b1; // added
                            addr <= current_data[11:0];
                            count <= 0;
                            instr_valid_internal <= 1'b0;
                        end

                        HALT: begin
                            running_reg <= 1'b0;
                            addr <= 0;                    // address reset to 0
                            instr_valid_internal <= 1'b0;    // prevent loading next instruction
                            count <= 0;
                        end
                        
                        LOOP_START: begin
                            if (stack_ptr < STACK_DEPTH) begin
                                // Push current address (next instruction after this LOOP_START)
                                addr_stack[stack_ptr]     <= addr + 1;           // or addr if you want to include the start instr
                                count_stack[stack_ptr] <= current_data[15:0]; // loop count from data field
                                //count_stack[stack_ptr] <= 16'd5; // loop count from data field
                                
                                stack_ptr <= stack_ptr + 1;
                
                                // Continue to next instruction (loop body starts here)
                                addr <= addr + 1;
                                count <= 0;
                                instr_valid_internal <= 1'b0;
                            end else begin
                                // Stack overflow - treat as HALT or error (you can add a flag later)
                                running_reg <= 1'b0;
                            end
                        end
            
                        LOOP_END: begin
                            control_flow_change <= 1'b1;   // ALWAYS bubble after LOOP_END
                            if (stack_ptr > 0) begin
                                if (count_stack[stack_ptr-1] > 16'd1) begin
                                    // More iterations: decrement and jump back
                                    count_stack[stack_ptr-1] <= count_stack[stack_ptr-1] - 16'd1;
                                    addr                     <= addr_stack[stack_ptr-1];
                                    count                    <= 0;
                                    instr_valid_internal     <= 1'b0;
                                end else begin
                                    // Final iteration: pop stack and continue to next instruction
                                    stack_ptr                <= stack_ptr - 1;
                                    addr                     <= addr + 1;
                                    count                    <= 0;
                                    instr_valid_internal     <= 1'b0;
                                end
                            end else begin
                                addr <= addr + 1;
                                count <= 0;
                                instr_valid_internal <= 1'b0;
                            end
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