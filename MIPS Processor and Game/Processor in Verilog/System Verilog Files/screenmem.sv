`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2018 03:24:10 PM
// Design Name: 
// Module Name: screenmem
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


module screenmem #(
   parameter Nloc = 1200,                       // Number of memory locations
   parameter Dbits = 4,                         // Number of bits in data
   parameter initfile = "smem_screentest.mem"   // Name of file with initial values
)(
    input wire clock,
    
    //For memory mapper
    input wire smem_wr,
    input wire [$clog2(Nloc)-1 : 0] cpu_addr,
    output wire [Dbits-1:0] smem_readdata,
    input wire [Dbits-1:0] cpu_writedata,
    
    //For VGA Display Driver
    input wire [$clog2(Nloc)-1 : 0] vga_addr,        
    output wire [Dbits-1 : 0] vga_readdata
    );
    
    //ram_module #(Nloc, Dbits, initfile) myram(clock, 0, smem_addr, 0, charactercode);
    
    
    logic [Dbits-1 : 0] rf [Nloc-1 : 0];      // The actual registers where data is stored
        
    initial $readmemh(initfile, rf, 0, Nloc-1);
    
    always_ff @(posedge clock)                               // Memory write: only when wr==1, and only at posedge clock
              if(smem_wr)
                 rf[cpu_addr] <= cpu_writedata;
        
    assign smem_readdata = rf[cpu_addr];
    assign vga_readdata = rf[vga_addr];
    
endmodule
