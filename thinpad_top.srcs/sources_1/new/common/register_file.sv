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

`include "param.svh"

module register_file(
  input wire clk_i,
  input wire rst_i,

  // 连接寄存器堆模块的信号
  input wire [REG_ADDR_WIDTH-1:0] raddr_a,
  input wire [REG_ADDR_WIDTH-1:0] raddr_b,
  output reg [CPU_DATA_WIDTH-1:0] rdata_a,
  output reg [CPU_DATA_WIDTH-1:0] rdata_b,
  input wire [REG_ADDR_WIDTH-1:0] waddr,
  input wire [CPU_DATA_WIDTH-1:0] wdata,
  input wire wen
);
  logic [CPU_DATA_WIDTH-1:0] register [REG_FILE_DEPTH-1:0];

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      register <= '{default:0};
    end else begin
      if (wen && waddr != 0) begin
        register[waddr] <= wdata;
      end
    end
  end

  assign rdata_a = register[raddr_a];
  assign rdata_b = register[raddr_b];

endmodule
