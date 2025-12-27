`timescale 1ns / 1ps

module alu (
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire [3:0]  op,
    output reg  [15:0] y,
    output reg         carry,
    output reg         zero
);

    // ---------------------------------------
    // Internal signals
    // ---------------------------------------
    reg  [15:0] dummy_toggle;   // redundant logic for regression demo
    wire [15:0] addsub_sum;
    wire        addsub_cout;

    // ---------------------------------------
    // 16-bit CLA Adder/Subtractor
    // sub = 0 → ADD
    // sub = 1 → SUB
    // ---------------------------------------
    cla16_addsub u_addsub (
        .a    (a),
        .b    (b),
        .sub  (op[0]),
        .sum  (addsub_sum),
        .cout (addsub_cout)
    );

    // ---------------------------------------
    // ALU Operation Decode + Dummy Toggle
    // ---------------------------------------
    always @(*) begin
        carry = 1'b0;

        // 🔥 Redundant logic (does NOT affect outputs)
        // dummy_toggle = a ^ b;

        case (op)
            4'b0000: begin // ADD
                y     = addsub_sum;
                carry = addsub_cout;
            end

            4'b0001: begin // SUB
                y     = addsub_sum;
                carry = addsub_cout;
            end

            4'b0010: y = a & b;        // AND
            4'b0011: y = a | b;        // OR
            4'b0100: y = a ^ b;        // XOR
            4'b0101: y = ~a;           // NOT A
            4'b0110: y = a << 1;       // Shift left
            4'b0111: y = a >> 1;       // Shift right

            default: y = 16'h0000;
        endcase
    end

    // ---------------------------------------
    // Zero flag
    // ---------------------------------------
    always @(*) begin
        zero = (y == 16'h0000);
    end

endmodule
