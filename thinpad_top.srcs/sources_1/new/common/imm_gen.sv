`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2022 11:22:12 PM
// Design Name: 
// Module Name: imm_gen
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


module imm_gen(
  input wire [CPU_DATA_WIDTH-1:0] instr,
  output reg [CPU_DATA_WIDTH-1:0] imm
);
  logic [CPU_DATA_WIDTH-1:0] imm_type_i;
  logic [CPU_DATA_WIDTH-1:0] imm_type_s;
  logic [CPU_DATA_WIDTH-1:0] imm_type_b;
  logic [CPU_DATA_WIDTH-1:0] imm_type_u;
  logic [CPU_DATA_WIDTH-1:0] imm_type_j;

  assign imm_type_i = {{20{instr[31]}}, instr[31:20]};
  assign imm_type_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
  assign imm_type_b = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
  assign imm_type_u = {instr[31:12], 12'b0};
  assign imm_type_j = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
  

  always_comb begin
    case(instr[6:0])
      7'b0000011: imm = imm_type_i;
      7'b0010011: imm = imm_type_i;
      7'b1100011: imm = imm_type_b;
      7'b0110111: imm = imm_type_u;
      7'b0100011: imm = imm_type_s;
      default: imm = 32'b0;
    endcase
  end
endmodule
