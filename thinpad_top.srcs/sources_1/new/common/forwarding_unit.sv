`timescale 1ns / 1ps

`include "param.svh"
module forwarding_unit (
  input wire [REG_ADDR_WIDTH-1:0] id_ex_rs1,
  input wire [REG_ADDR_WIDTH-1:0] id_ex_rs2,
  input wire [REG_ADDR_WIDTH-1:0] ex_mem_rd,
  input wire [REG_ADDR_WIDTH-1:0] mem_wb_rd,
  input wire ex_mem_reg_write,
  input wire mem_wb_reg_write,
  output wire [FORWARD_SEL_WIDTH-1:0] forward_a,
  output wire [FORWARD_SEL_WIDTH-1:0] forward_b
);

  assign forward_a = (ex_mem_reg_write && ex_mem_rd != 0 && (id_ex_rs1 == ex_mem_rd)) ? 2'b10 :
                     (mem_wb_reg_write && mem_wb_rd != 0 && (id_ex_rs1 == mem_wb_rd)) ? 2'b01 : 2'b00;

  assign forward_b = (ex_mem_reg_write && ex_mem_rd != 0 && (id_ex_rs2 == ex_mem_rd)) ? 2'b10 :
                     (mem_wb_reg_write && mem_wb_rd != 0 && (id_ex_rs2 == mem_wb_rd)) ? 2'b01 : 2'b00;

endmodule