`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/25/2018 05:14:00 PM
// Design Name: 
// Module Name: adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adder #(parameter N=32) (
    input wire [N-1:0] A, B,
    input wire Cin,
    output wire [N-1:0] Sum,
    output wire FlagN, FlagC, FlagV
    );
    
    wire [N:0] carry;
    assign carry[0]=Cin;
    
    assign FlagN = Sum[N-1];
    assign FlagC = carry[N];
    assign FlagV = carry[N] ^ carry[N-1];
    
    fulladder a[N-1:0] (A, B, carry[N-1:0], Sum, carry[N:1]);
    
endmodule
