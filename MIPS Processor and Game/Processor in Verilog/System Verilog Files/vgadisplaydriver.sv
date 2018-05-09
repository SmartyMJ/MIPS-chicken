//////////////////////////////////////////////////////////////////////////////////
//
// Malik Jabati
// 3/5/2018 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none
`include "display640x480.vh"

module vgadisplaydriver #(
    parameter bmem_init = "bmem_game.mem"
)(
    input wire clock,
    input wire [3:0] charactercode,
    
    output wire [3:0] red, green, blue,
    output wire hsync, vsync,
    output wire [10:0] screenaddr
    );

   wire [`xbits-1:0] x;
   wire [`ybits-1:0] y;
   wire activevideo;
   wire [`xbits-1:0] j = x >> 4;
   wire [`ybits-1:0] k = y >> 4;
   wire [3:0] xOffset = x[3:0];
   wire [3:0] yOffset = y[3:0];
   wire [9:0] bmem_addr;
   wire [11:0] bmem_color;
   
   //wire [5:0] row, col;
   //assign row[5:0] = y[9:4];
   //assign col[5:0] = x[9:4];
   
   //assign screenaddr[10:0] = { (row[5:0]<<5) + (row[5:0]<<3) + col[5:0] };
   
   //assign bitmapaddr[9:0] = { charactercode[1:0], y[3:0], x[3:0] }; // Check placement of x and y
   
   assign screenaddr = ((j) + (40 * k));
   assign bmem_addr = {charactercode, yOffset, xOffset};
   
   vgatimer myvgatimer(clock, hsync, vsync, activevideo, x, y);
   bitmapmem #(.Nloc(1536), .initfile(bmem_init)) mybitmapmem(bmem_addr, bmem_color);
   
   assign red[3:0]   = (activevideo == 1) ? bmem_color[11:8] : 4'b0;
   assign green[3:0] = (activevideo == 1) ? bmem_color[7:4] : 4'b0;
   assign blue[3:0]  = (activevideo == 1) ? bmem_color[3:0] : 4'b0;

endmodule