`ifndef _PARAM_SVH_
`define _PARAM_SVH_

localparam ADDR_WIDTH = 32;
localparam CPU_DATA_WIDTH = 32;

// register file
localparam REG_ADDR_WIDTH = 5;
localparam REG_FILE_DEPTH = 32;

// instruction memory
localparam RAM_ADR = 32'h8000_0000;
localparam RAM_MSK = 32'hff00_0000;

// alu control
localparam ALU_CTRL_WIDTH = 4;
localparam FUNCT3_WIDTH = 3;
localparam FUNCT7_WIDTH = 7;

// alu
localparam ALU_NOP = 4'b0000;
localparam ALU_ADD = 4'b0001;
localparam ALU_SUB = 4'b0010;
localparam ALU_AND = 4'b0011;
localparam ALU_OR  = 4'b0100;
localparam ALU_XOR = 4'b0101;
localparam ALU_NOT = 4'b0110;
localparam ALU_SLL = 4'b0111;
localparam ALU_SRL = 4'b1000;
localparam ALU_SRA = 4'b1001;
localparam ALU_SLT = 4'b1010;

// control unit
localparam ALU_OP_WIDTH = 2;

// forward unit
localparam FORWARD_SEL_WIDTH = 2;

`endif
