//////////////////////////////////////////////////////////////////////////////////
//
// Malik Jabati
// 4/11/2018 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none


module memIO # (
    parameter Nloc = 64,
    parameter Dbits = 32,
    parameter dmem_init = "...",
    parameter smem_init = "..."
) (
    input wire clock,
    input wire [31:0] cpu_addr,
    input wire [Dbits-1:0] cpu_writedata,
    input wire cpu_wr,
    output wire [Dbits-1:0] cpu_readdata,
    input wire [10:0] vga_addr, //screen_addr
    output wire [3:0] vga_readdata, //character code
    
    //Keyboard
    input wire [31:0] keyb_char,
    
    //Accel
    input wire [8:0] accelX,
    input wire [8:0] accelY,
    
    //Sound
    output wire audEn,
    output wire [31:0] period,
    
    //LED
    output wire [15:0] LED
    );
    
    
    //Data Memory
    wire [Dbits-1:0] dmem_readdata;
    dmem #(.Nloc(Nloc), .Dbits(Dbits), .initfile(dmem_init)) dmem(.clock(clock), .wr(dmem_wr), .addr(cpu_addr[31:2]),
                                                            .din(cpu_writedata), .dout(dmem_readdata));
    
    //Screen Memory
    wire [3:0] smem_readdata;
    screenmem #(.Nloc(1200), .Dbits(4), .initfile(smem_init)) smem(.clock(clock), .smem_wr(smem_wr), .cpu_addr(cpu_addr[31:2]),
                                                                    .smem_readdata(smem_readdata), .cpu_writedata(cpu_writedata),
                                                                    .vga_addr(vga_addr), .vga_readdata(vga_readdata));
    
    
    
    //LED Register
    logic [15:0] LED_reg;
    always_ff @(posedge clock)                               
          if(lights_wr) 
            LED_reg <= cpu_writedata;
     assign LED = LED_reg; 
    //LED_reg led_reg(.clock(clock), .lights_wr(lights_wr), .lights_val(cpu_readdata), .LED(LED));
    
    //Sound Register
    assign audEn = 1'b1;
    logic [31:0] sound_reg;
    always_ff @(posedge clock)
        if(sound_wr)
            sound_reg <= cpu_writedata;
     assign period = sound_reg;  
    //sound_reg sound_reg(.clock(clock), .sound_wr(sound_wr), .sound_val(cpu_readdata), .audEn(audEn), .period(period));

    
    
    //Memory Mapper CHECK THIS FOR SOUND???
    assign cpu_readdata = (cpu_addr[17:16] == 2'b01) ? dmem_readdata :
                            (cpu_addr[17:16] == 2'b10) ? {28'b0, smem_readdata} :
                            (cpu_addr[17:16] == 2'b11) ? ((cpu_addr[3:2] == 2'b00) ? keyb_char : {23'b0,accelX}) : 32'b0;
                            
//                             {7'b0,accelX,7'b0,accelY}
    
                                
    wire dmem_wr, smem_wr, sound_wr, lights_wr;
    assign dmem_wr = (cpu_addr[17:16] == 2'b01 && cpu_wr) ? 1'b1 : 1'b0;
    assign smem_wr = (cpu_addr[17:16] == 2'b10 && cpu_wr) ? 1'b1 : 1'b0;
    assign sound_wr = (cpu_addr[17:16] == 2'b11 && cpu_addr[3:2] == 2'b10 && cpu_wr) ? 1'b1 : 1'b0;
    assign lights_wr = (cpu_addr[17:16] == 2'b11 && cpu_addr[3:2] == 2'b11 && cpu_wr) ? 1'b1 : 1'b0;
    
endmodule
