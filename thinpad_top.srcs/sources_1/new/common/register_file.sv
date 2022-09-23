`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/22 13:53:38
// Design Name: 
// Module Name: register_file
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


module register_file(
    input wire clk,
    input wire reset,

    // 连接寄存器堆模块的信号
    input  reg  [ 4:0] raddr_a,
    output wire [15:0] rdata_a,
    input  reg  [ 4:0] raddr_b,
    output wire [15:0] rdata_b,
    input  reg  [ 4:0] waddr,
    input  reg  [15:0] wdata,
    input  reg         wen
);
  logic [15:0] register [31:0];

  always_ff @(posedge clk) begin
    if (reset) begin
      register <= '{default:0};
    end else begin
      if (wen) begin
        register[waddr] <= wdata;
      end
    end
  end

  assign rdata_a = register[raddr_a];
  assign rdata_b = register[raddr_b];

endmodule
