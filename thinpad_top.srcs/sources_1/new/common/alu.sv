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


module alu(
    input   reg  [15:0] a,
    input   reg  [15:0] b,
    input   reg  [ 3:0] op,
    output  wire [15:0] y
);

  reg [15:0] result;

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
      default: result = 16'b0;
    endcase
  end

  assign y = result;

endmodule
