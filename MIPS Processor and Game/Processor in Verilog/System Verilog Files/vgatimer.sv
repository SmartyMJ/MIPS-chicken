`timescale 1ns / 1ps
`default_nettype none
`include "display640x480.vh"
//////////////////////////////////////////////////////////////////////////////////
// 
// Malik Jabati
// 2/9/2018
// 
//////////////////////////////////////////////////////////////////////////////////


module vgatimer(
    input wire clk,
    output wire hsync, vsync, activevideo,
    output wire [`xbits-1:0] x,
    output wire [`ybits-1:0] y
    );
    
    // These lines below allow you to count every 2nd clock tick and 4th clock tick
    // This is because, depending onthe display mode, we may need to count at 50MHz or 25MHz.
    
    logic [1:0] clk_count=0;
    always_ff @(posedge clk)
        clk_count <= clk_count + 2'b01;
        
    wire Every2ndTick = (clk_count[0] == 1'b1);
    wire Every4thTick = (clk_count[1:0] == 2'b11);
    
    // This part instantiates an xy-counter using the appropriate clock tick counter
    // xycounter #(`WholeLine, `WholeFrame) xy(clk, Every2ndTick, x, y);  // Count at 50 MHz
    
    xycounter #(`WholeLine, `WholeFrame) xy(clk, Every4thTick, x, y);  // Count at 25 MHz
    
    // Generate the monitor sync signals
    assign hsync = ((x >= `hSyncStart) & (x <= `hSyncEnd)) ? ~`hSyncPolarity : `hSyncPolarity; // equals 0 if true, 1 if not
    assign vsync = ((y >= `vSyncStart) & (y <= `vSyncEnd)) ? ~`vSyncPolarity : `vSyncPolarity; // equals 0 if true, 1 if not
    assign activevideo = ((x < `hVisible) & (y < `vVisible)) ? 1 : 0;
    
endmodule
