`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/22 13:52:54
// Design Name: 
// Module Name: alu
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

module alu(
    input wire [CPU_DATA_WIDTH-1:0] a,
    input wire [CPU_DATA_WIDTH-1:0] b,
    input wire [ALU_CTRL_WIDTH-1:0] op,
    output reg [CPU_DATA_WIDTH-1:0] y,
    output reg zero
);

  reg [CPU_DATA_WIDTH-1:0] result;

  always_comb begin
    case (op)
      4'b0001: result = a + b;
      4'b0010: result = a - b;
      4'b0011: result = a & b;
      4'b0100: result = a | b;
      4'b0101: result = a ^ b;
      4'b0110: result = ~a;
      4'b0111: result = a << (b & 15);
      4'b1000: result = a >> (b & 15);
      4'b1001: result = $signed(a) >>> (b & 15);
      4'b1010: result = (a << (b & 15)) + (a >> (16 - (b & 15)));
      default: result = 32'b0;
    endcase
  end

  assign y = result;
  assign zero = (result == 32'b0);

endmodule
