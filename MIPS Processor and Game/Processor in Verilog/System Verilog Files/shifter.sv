`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Malik Jabati
// 
// Create Date: 01/25/2018 07:41:22 PM
// Design Name: 
// Module Name: shifter
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


module shifter #(parameter N=32) (
    input wire signed [N-1:0] IN,
    input wire [$clog2(N)-1:0] shamt, // ceiling log base 2
    input wire left, logical,
    output wire [N-1:0] OUT
    );
    
    assign OUT = left ? (IN << shamt) :
                    (logical ? IN >> shamt : IN >>> shamt);
endmodule
