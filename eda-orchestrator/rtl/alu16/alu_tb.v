`timescale 1ns / 1ps

module alu_tb;

    // -------------------------
    // DUT signals
    // -------------------------
    reg  [15:0] a;
    reg  [15:0] b;
    reg  [3:0]  op;
    wire [15:0] y;
    wire        carry;
    wire        zero;

    integer i;
    integer fh;

    // -------------------------
    // DUT : SINGLE TOP ALU
    // -------------------------
    alu dut (
        .a     (a),
        .b     (b),
        .op    (op),
        .y     (y),
        .carry (carry),
        .zero  (zero)
    );

    // -------------------------
    // VCD dump (MANDATORY)
    // -------------------------
    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);
    end

    // -------------------------
    // Test + CSV logging
    // -------------------------
    initial begin
        fh = $fopen("alu_results.csv", "w");
        if (fh == 0) begin
            $finish;
        end

        // CSV header (FIXED FORMAT)
        $fwrite(fh, "cycle,a,b,op,y,carry,zero\n");

        // deterministic init
        a  = 16'd0;
        b  = 16'd0;
        op = 4'd0;

        #5;

        // Deterministic stimulus loop
        for (i = 0; i < 256; i = i + 1) begin
            a  = i;
            b  = 16'd255 - i;
            op = i % 8;   // valid ALU ops only

            #1;

            $fwrite(
                fh,
                "%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",
                i, a, b, op, y, carry, zero
            );
        end

        $fclose(fh);
        #10;
        $finish;
    end

endmodule
