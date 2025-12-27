`timescale 1ns / 1ps
// 16-bit Carry Lookahead Adder/Subtractor
module cla16_addsub (
    input  [15:0] a,
    input  [15:0] b,
    input         sub,      // 0: add, 1: subtract (a - b)
    output [15:0] sum,
    output        cout
);
    wire [15:0] b_xor;
    wire c0, c4, c8, c12, c16;
    wire [3:0] P, G;

    assign b_xor = b ^ {16{sub}}; // if sub=1 => invert b
    assign c0    = sub;           // add 1 for subtraction

    // 4-bit blocks
    cla4 u0 (.a(a[3:0]),   .b(b_xor[3:0]),   .cin(c0),
             .sum(sum[3:0]),   .cout(), .P(P[0]), .G(G[0]));

    assign c4 = G[0] | (P[0] & c0);

    cla4 u1 (.a(a[7:4]),   .b(b_xor[7:4]),   .cin(c4),
             .sum(sum[7:4]),   .cout(), .P(P[1]), .G(G[1]));

    assign c8 = G[1] | (P[1] & c4);

    cla4 u2 (.a(a[11:8]),  .b(b_xor[11:8]),  .cin(c8),
             .sum(sum[11:8]),  .cout(), .P(P[2]), .G(G[2]));

    assign c12 = G[2] | (P[2] & c8);

    cla4 u3 (.a(a[15:12]), .b(b_xor[15:12]), .cin(c12),
             .sum(sum[15:12]), .cout(), .P(P[3]), .G(G[3]));

    assign c16 = G[3] | (P[3] & c12);

    assign cout = c16;
endmodule
