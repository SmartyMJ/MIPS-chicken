`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2018 04:23:48 PM
// Design Name: 
// Module Name: datapath
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


module datapath#(
      parameter Nloc = 32,
      parameter Dbits = 32
    )(
      input wire clock,
      input wire reset,
      input wire enable,
      output logic [31:0] pc = 32'h0040_0000,
      input wire [31:0] instr,
      input wire [1:0] pcsel,
      input wire [1:0] wasel,
      input wire sext, bsel,
      input wire [1:0] wdsel,
      input wire [4:0] alufn,
      input wire werf,
      input wire [1:0] asel,
      output wire Z,
      output wire [31:0] mem_addr,     // ***Should it be Dbits-1?
      output wire [31:0] mem_writedata,
      input wire [31:0] mem_readdata
      
    );
      logic [$clog2(Nloc)-1:0] ReadAddr1, ReadAddr2, reg_writeaddr, shamt;
      assign ReadAddr1 = instr[25:21];
      assign ReadAddr2 = instr[20:16];
      assign shamt = instr[10:6];
      logic [Dbits-1 : 0] ReadData1, ReadData2, alu_result;
      logic [Dbits-1 : 0] aluA, aluB;
      logic [Dbits-1 : 0] signImm;
      //signImm
      always_comb
        case(sext)
          1'b1: signImm <= {{16{instr[15]}},instr[15:0]};
          1'b0: signImm <= {16'b0,instr[15:0]};
          default: signImm <= {16'b0,instr[15:0]};
        endcase
      //aluA
      always_comb
        case(asel)
          2'b00: aluA <= ReadData1; //Rs
          2'b01: aluA <= shamt;
          2'b10: aluA <= 16; 
          default: aluA <= 0;
        endcase
      //aluB
      always_comb
        case(bsel)
          1'b0: aluB <= ReadData2;
          1'b1: aluB <= signImm;
          default: aluB <= 0;
        endcase
      
      //PC
      logic [31:0] pcPlus4;
      assign pcPlus4 = pc + 4;
      
      //logic [31:0] newPC;
      //assign newPC = (pcsel == 2'b11) ? (ReadData1) //JR
      //              : (pcsel == 2'b10) ? ({pc[31:28],instr[25:0],2'b00}) //J
      //              : (pcsel == 2'b01) ? (pcPlus4 + (signImm << 2)) //BT
      //              : pcPlus4;  // Normal
      
      always_ff @(posedge clock) begin
        if(reset)
           pc <= 32'h0040_0000;
        else if(enable)
            //pc <= newPC;
           case(pcsel)
             2'b00: pc <= pcPlus4; //Normal
             2'b01: pc <= (pcPlus4 + (signImm << 2)); //BT
             2'b10: pc <= ({pc[31:28],instr[25:0],2'b00}); //J
             2'b11: pc <= (ReadData1); //JR
             default: pc <= pcPlus4;
           endcase
      end
      
      logic [Dbits-1:0] reg_writedata;
      //reg_writedata
      always_comb
        case(wdsel)
           2'b00: reg_writedata <= pcPlus4;
           2'b01: reg_writedata <= alu_result;
           2'b10: reg_writedata <= mem_readdata;          
           default: reg_writedata <= pcPlus4;
        endcase
      
       //reg_writeaddr
      always_comb
        case(wasel)
           2'b00: reg_writeaddr <= instr[15:11];
           2'b01: reg_writeaddr <= instr[20:16];
           2'b10: reg_writeaddr <= 31;
           default: reg_writeaddr <= 0;
        endcase
      
      assign mem_writedata = ReadData2;
      assign mem_addr = alu_result;
      register #(Nloc, Dbits, "mem_data.mem") my_register(clock, werf, ReadAddr1, ReadAddr2, reg_writeaddr, reg_writedata, ReadData1, ReadData2);
      ALU #(Dbits) my_alu(aluA, aluB, alufn, alu_result, Z);
      
endmodule