//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 10/19/2017 
//
// Malik Jabati
// 4/2/2018
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

// These are non-R-type.  OPCODES defined here:

`define LW     6'b100011
`define SW     6'b101011

`define ADDI   6'b001000
`define ADDIU  6'b001001			// NOTE:  addiu *does* sign-extend the imm
`define SLTI   6'b001010
`define SLTIU  6'b001011
`define ORI    6'b001101
`define LUI    6'b001111
`define ANDI   6'b001100
`define XORI   6'b001110

`define BEQ    6'b000100
`define BNE    6'b000101
`define J      6'b000010
`define JAL    6'b000011


// These are all R-type, i.e., OPCODE=0.  FUNC field defined here:

`define ADD    6'b100000
`define ADDU   6'b100001
`define SUB    6'b100010
`define AND    6'b100100
`define OR     6'b100101
`define XOR    6'b100110
`define NOR    6'b100111
`define SLT    6'b101010
`define SLTU   6'b101011
`define SLL    6'b000000
`define SLLV   6'b000100
`define SRL    6'b000010
`define SRA    6'b000011
`define JR     6'b001000  


module controller(
   input  wire enable,
   input  wire [5:0] op, 
   input  wire [5:0] func,
   input  wire Z,
   output wire [1:0] pcsel,
   output wire [1:0] wasel, 
   output wire sext,
   output wire bsel,
   output wire [1:0] wdsel, 
   output logic [4:0] alufn, 			// will become wire because updated in always_comb
   output wire wr,
   output wire werf, 
   output wire [1:0] asel
   ); 

  assign pcsel = ((op == 6'b0) & (func == `JR)) ? 2'b11                 // controls 4-way multiplexer
               : ((op == `J) | (op == `JAL)) ? 2'b10
               : (((op == `BEQ) & Z) | ((op == `BNE) & ~Z)) ? 2'b01     // for beq/bne check Z flag!
               : 2'b00;

  logic [9:0] controls;
  wire _werf_, _wr_;
  assign werf = _werf_ & enable;       // turn off register writes when processor is disabled
  assign wr = _wr_ & enable;           // turn off memory writes when processor is disabled
 
  assign {_werf_, wdsel[1:0], wasel[1:0], asel[1:0], bsel, sext, _wr_} = controls[9:0];

  always_comb
     case(op)                                     // non-R-type instructions
        `LW: controls <= 10'b1_10_01_00_1_1_0;      // LW
        `SW: controls <= 10'b0_10_01_00_1_1_1;      // SW
      `ADDI,                                        // ADDI
     `ADDIU,                                        // ADDIU
      `SLTI,                                        // SLTI
     `SLTIU: controls <= 10'b1_01_01_00_1_1_0;      // SLTIU
       `ORI,                                        // ORI
      `ANDI,                                        // ANDI
      `XORI: controls <= 10'b1_01_01_00_1_0_0;      // XORI
       `LUI: controls <= 10'b1_01_01_10_1_0_0;      // LUI
       `BEQ,                                        // BEQ
       `BNE: controls <= 10'b0_00_00_00_0_1_0;      // BNE
         `J: controls <= 10'b0_00_00_00_0_0_0;      // J
       `JAL: controls <= 10'b1_00_10_00_0_0_0;      // JAL
      6'b000000:                                    
         case(func)                              // R-type
             `ADD,                                      // ADD
            `ADDU,                                      // ADDU
             `SUB,                                      // SUB
             `AND,                                      // AND
              `OR,                                      // OR
             `XOR,                                      // XOR
             `NOR,                                      // NOR
             `SLT,                                      // SLT
            `SLTU: controls <= 10'b1_01_00_00_0_x_0;    // SLTU
             `SLL,                                      // SLL
             `SRL,                                      // SRL
             `SRA: controls <= 10'b1_01_00_01_0_x_0;    // SRA
            `SLLV: controls <= 10'b1_01_00_00_0_x_0;    // SLLV
              `JR: controls <= 10'b0_00_00_00_0_0_0;    // JR
            default:   controls <= 10'b0_xx_xx_xx_x_x_0; // unknown instruction, turn off register and memory writes
         endcase
      default: controls <= 10'b0_xx_xx_xx_x_x_0;         // unknown instruction, turn off register and memory writes
    endcase
    

  always_comb
    case(op)                        // non-R-type instructions
        `LW,                            // LW
        `SW,                            // SW
      `ADDI,                            // ADDI
     `ADDIU: alufn <= 5'b0xx01;         // ADDIU
      `SLTI: alufn <= 5'b1x011;         // SLTI
     `SLTIU: alufn <= 5'b1x111;         // SLTIU
       `ORI: alufn <= 5'bx0100;         // ORI
       `LUI: alufn <= 5'bx0010;         // LUI
      `ANDI: alufn <= 5'bx0000;         // ANDI
      `XORI: alufn <= 5'bx1000;
       `BEQ,                            // BEQ
       `BNE: alufn <= 5'b1xx01;         // BNE
         `J,                            // J
       `JAL: alufn <= 5'bxxxxx;         // JAL
      6'b000000:                      
         case(func)                 // R-type
             `ADD,                      // ADD
            `ADDU: alufn <= 5'b0xx01;   // ADDU
             `SUB: alufn <= 5'b1xx01;   // SUB
             `AND: alufn <= 5'b00000;   // AND
              `OR: alufn <= 5'bx0100;   // OR
             `XOR: alufn <= 5'bx1000;   // XOR
             `NOR: alufn <= 5'bx1100;   // NOR
             `SLT: alufn <= 5'b1x011;   // SLT
            `SLTU: alufn <= 5'b1x111;   // SLTU
             `SLL,                      // SLL
            `SLLV: alufn <= 5'bx0010;   // SLLV
             `SRL: alufn <= 5'b11010;   // SRL
             `SRA: alufn <= 5'b11110;   // SRA
              `JR: alufn <= 5'bxxxxx;   // JR
            default:   alufn <= 5'bxxxxx; // unknown func
         endcase
      default: alufn <= 5'bxxxxx;         // J, JAL etc.
    endcase
    
endmodule