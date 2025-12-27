`timescale 1ns / 1ps
// 4-bit Carry Lookahead Block
module cla4 (
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       cout,
    output       P,   // group propagate
    output       G    // group generate
);
    wire [3:0] p, g;
    wire c1, c2, c3, c4;

    assign p = a ^ b;    // propagate
    assign g = a & b;    // generate

    assign c1 = g[0] | (p[0] & cin);
    assign c2 = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin);
    assign c3 = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) |
                          (p[2] & p[1] & p[0] & cin);
    assign c4 = g[3] | (p[3] & g[2]) |
                          (p[3] & p[2] & g[1]) |
                          (p[3] & p[2] & p[1] & g[0]) |
                          (p[3] & p[2] & p[1] & p[0] & cin);

    assign sum[0] = p[0] ^ cin;
    assign sum[1] = p[1] ^ c1;
    assign sum[2] = p[2] ^ c2;
    assign sum[3] = p[3] ^ c3;

    assign cout = c4;

    // Group signals
    assign P = p[3] & p[2] & p[1] & p[0];
    assign G = g[3] | (p[3] & g[2]) |
                        (p[3] & p[2] & g[1]) |
                        (p[3] & p[2] & p[1] & g[0]);
endmodule
