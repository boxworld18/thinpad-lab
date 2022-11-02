`timescale 1ns / 1ps

`include "param.svh"
module hazard_detection_unit (
  input wire id_ex_mem_read,
  input wire [REG_ADDR_WIDTH-1:0] id_ex_rd,
  input wire [REG_ADDR_WIDTH-1:0] if_id_rs1,
  input wire [REG_ADDR_WIDTH-1:0] if_id_rs2,
  output reg pipe_stall, // 1 stall, 0 continue
  output reg pc_write,
  output reg if_d_write
);
  
  assign pipe_stall = id_ex_mem_read && (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2);
  assign pc_write = ~pipe_stall;
  assign if_d_write = ~pipe_stall;

endmodule