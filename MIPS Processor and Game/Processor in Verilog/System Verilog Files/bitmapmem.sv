`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2018 03:25:35 PM
// Design Name: 
// Module Name: bitmapmem
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


module bitmapmem #(
    parameter Nloc = 1024,
    parameter Dbits = 12,
    parameter initfile = "bmem_screentest.mem"
)(
    input wire [$clog2(Nloc)-1 : 0] bitmapaddr, 	
    
    output logic [Dbits-1 : 0] colorvalue
    );
    
    logic [Dbits-1 : 0] bmem [Nloc-1 : 0];      // The actual registers where data is stored
    
    initial $readmemh(initfile, bmem, 0, Nloc-1);
    
    assign colorvalue = bmem[bitmapaddr];

endmodule
