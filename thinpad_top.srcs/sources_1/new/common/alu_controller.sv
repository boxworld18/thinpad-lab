`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2022 01:02:34 AM
// Design Name: 
// Module Name: alu_controller
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

`include "param.svh"

module alu_controller(
  input wire [FUNCT3_WIDTH-1:0] funct3,
  input wire [FUNCT7_WIDTH-1:0] funct7,
  input wire [ALU_OP_WIDTH-1:0] alu_op,
  output reg [ALU_CTRL_WIDTH-1:0] alu_op4
);

  always_comb begin
    case (alu_op)
      2'b00: begin
        alu_op4 = ALU_ADD;
      end
      2'b01: begin
        alu_op4 = ALU_SUB;
      end
      2'b10: begin
        case (funct3)
          // ADD
          3'b000: begin
            alu_op4 = ALU_ADD;
          end
          // SUB or SLL
          3'b001: begin
            alu_op4 = funct7[5] ? ALU_SUB: ALU_SLL;
          end
          // XOR
          3'b100: begin
            alu_op4 = ALU_XOR;
          end
          // SRA or SRL
          3'b101: begin
            alu_op4 = funct7[5] ? ALU_SRA : ALU_SRL;
          end
          // OR
          3'b110: begin
            alu_op4 = ALU_OR;
          end
          // AND
          3'b111: begin
            alu_op4 = ALU_AND;
          end
          default: begin
            alu_op4 = ALU_NOP;
          end
        endcase
      end
      default: begin
        alu_op4 = ALU_NOP;
      end
    endcase
  end

endmodule
