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
    reg [2:0]  stack_ptr = 0;                     // 0 = empty


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
    reg execute = 1'b0;
    reg stall_load = 1'b0;

    localparam [3:0] NO_OP      = 4'b0000;
    localparam [3:0] DELAY      = 4'b0001;
    localparam [3:0] LOOP_START = 4'b0100;
    localparam [3:0] LOOP_END   = 4'b0101;
    localparam [3:0] HALT       = 4'b0111;
    localparam [3:0] JUMP       = 4'b0011;
    localparam [3:0] WAIT       = 4'b1000;

    always @(posedge clk) begin
        if (stall_load) stall_load <= 1'b0; // set back to zero if stalling load for single clock cycle
                
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
            execute              <= 1'b0;
            pulse_out            <= 8'b0;
            stack_ptr            <= 4'b0;
            stall_load           <= 1'b0;
//            init                 <= 1'b0;
            
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
                addr                 <= 12'd1; // important, set address to 1, so that next data is ready in time
                count                <= 32'd0;
                execute              <= 1'b0; // important
                stack_ptr            <= 4'b0;
                stall_load           <= 1'b0; // important
                current_op    <= op_code;
                current_delay <= delay;
                current_data  <= data;
                // pulse_out keeps its last value until a DELAY/WAIT loads a new one
            end
            else if (!running_reg) begin
                // Halted: do nothing, keep last pulse_out and addr
                //pulse_out <= safe_pulse_out; // Put into the safe state, for testing we set AA, change later to safe outputs
                addr <= 0; // reset address to 0
                current_op    <= op_code;
                current_delay <= delay;
                current_data  <= data;
            end
            else begin
                // === Normal running state ===
                if (!execute && !stall_load) begin // Load Next op_code, delay, data; stall load if jumping addresses
                    // === LOAD PHASE ===
                    current_op    <= op_code;
                    current_delay <= delay;
                    current_data  <= data;

                    // Only update pulse_out for instructions that should drive outputs
                    if (op_code == DELAY) begin // Only update output when OP_CODE is DELAY
                        pulse_out <= pulse;
                    end
                    execute <= 1'b1;
                    
                end
                
                else if (execute) begin
                    // === EXECUTE PHASE ===
                    case (current_op)
                        NO_OP: begin
                            addr <= addr + 1;
                            count <= 0;
                            execute <= 1'b0;
                        end

                        DELAY: begin
                            if (count >= current_delay) begin
                                count <= 0;
                                addr <= addr + 1;
                                execute <= 1'b0;
                            end else begin
                                count <= count + 1;
                            end
                        end

                        WAIT: begin
                            if (trig_sync) begin
                                addr <= addr + 1;
                                count <= 0;
                                execute <= 1'b0;
                            end
                        end

                        JUMP: begin
                            addr <= current_data[11:0];
                            count <= 0;
                            execute <= 1'b0;
                            stall_load <= 1'b1; // Bubble after JUMP, required when changing address
                        end

                        HALT: begin
                            running_reg <= 1'b0;
                            addr <= 0;                    // address reset to 0
                            execute <= 1'b0;    // prevent loading next instruction
                            count <= 0;
                            stack_ptr <= 0;
                        end
                        
                        LOOP_START: begin
                            if (stack_ptr < STACK_DEPTH) begin
                                // Push current address (next instruction after this LOOP_START)
                                addr_stack[stack_ptr]     <= addr + 1;           // or addr if you want to include the start instr
                                count_stack[stack_ptr] <= current_data[15:0]; // loop count from data field
                                
                                stack_ptr <= stack_ptr + 1;
                
                                // Continue to next instruction (loop body starts here)
                                addr <= addr + 1;
                                count <= 0;
                                execute <= 1'b0;
                                //stall_load <= 1'b1;
                            end else begin
                                // Stack overflow - treat as HALT or error (you can add a flag later)
                                running_reg <= 1'b0;
                            end
                        end
            
                        LOOP_END: begin
                            if (stack_ptr > 0) begin
                                if (count_stack[stack_ptr-1] > 16'd1) begin
                                    stall_load <= 1'b1;   // ALWAYS bubble after LOOP_END                                
                                    // More iterations: decrement and jump back
                                    count_stack[stack_ptr-1] <= count_stack[stack_ptr-1] - 16'd1;
                                    addr                     <= addr_stack[stack_ptr-1];
                                    count                    <= 0;
                                    execute     <= 1'b0;
                                end else begin
                                    // Final iteration: pop stack and continue to next instruction
                                    stack_ptr                <= stack_ptr - 1;
                                    addr                     <= addr + 1;
                                    count                    <= 0;
                                    execute     <= 1'b0;
                                end
                            end else begin
                                addr <= addr + 1;
                                count <= 0;
                                execute <= 1'b0;
                            end
                        end

                        default: begin
                            addr <= addr + 1;
                            count <= 0;
                            execute <= 1'b0;
                        end
                    endcase
                end
            end
        end
    end

endmodule