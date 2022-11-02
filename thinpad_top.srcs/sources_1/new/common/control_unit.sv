`timescale 1ns / 1ps

`include "param.svh"

// Ref: Graph 4-15
module control_unit (
  input wire [CPU_DATA_WIDTH-1:0] instr,
  input wire pipe_stall,
  output reg [ALU_OP_WIDTH-1:0] alu_op, // 00 add, 01 sub, 10 decided by funct3,7
  output reg alu_src, // 0: reg, 1: imm
  output reg branch, // 0: no, 1: yes
  output reg mem_read, // 0: no, 1: yes
  output reg mem_write, // 0: no, 1: yes
  output reg [CPU_DATA_WIDTH/8-1:0] mem_sel,
  output reg mem_to_reg, // 0: alu, 1: mem
  output reg reg_write // 0: no, 1: yes
);
  logic [6:0] opcode;
  assign opcode = instr[6:0] & {7{~pipe_stall}};

  always_comb begin
    case (opcode)
      7'b0: begin
        alu_op = 2'b00;
        alu_src = 1'b0;
        branch = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;
        reg_write = 1'b0;
      end
      // type R
      7'b0110011: begin
        alu_op = 2'b10;
        alu_src = 1'b0;
        branch = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;
        reg_write = 1'b1;
      end
      // type I
      7'b0010011: begin
        alu_op = 2'b10;
        alu_src = 1'b1;
        branch = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;
        reg_write = 1'b1;
      end
      // type I - Load
      7'b0000011: begin
        alu_op = 2'b00;
        alu_src = 1'b1;
        branch = 1'b0;
        mem_read = 1'b1;
        mem_write = 1'b0;
        mem_to_reg = 1'b1;
        reg_write = 1'b1;
      end
      // type S - Store
      7'b0100011: begin
        alu_op = 2'b00;
        alu_src = 1'b1;
        branch = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b1;
        mem_to_reg = 1'b0;
        reg_write = 1'b0;
      end
      // type U
      7'b0110111: begin
        alu_op = 2'b00;
        alu_src = 1'b1;
        branch = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;
        reg_write = 1'b1;
      end
      // type B
      7'b1100011: begin
        alu_op = 2'b01;
        alu_src = 1'b0;
        branch = 1'b1;
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;
        reg_write = 1'b0;
      end
    endcase
  end

  always_comb begin
    case (instr[14:12])
      3'b000: mem_sel = 4'b0001;
      3'b001: mem_sel = 4'b0011;
      3'b010: mem_sel = 4'b1111;
      default: mem_sel = 4'b0000;
    endcase
  end
  
endmodule