`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2022 02:15:06 AM
// Design Name: 
// Module Name: if_master
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

module if_master(
  input wire clk_i,
  input wire rst_i,
  input wire [ADDR_WIDTH-1:0] cpu_adr_i,
  input wire [CPU_DATA_WIDTH/8-1:0] cpu_sel_i,
  output reg [ADDR_WIDTH-1:0] cpu_dat_o,
  output reg pipe_stall,
  input wire cpu_pipe_stall,

  output reg wb_cyc_o,
  output reg wb_stb_o,
  input wire wb_ack_i,
  output reg [ADDR_WIDTH-1:0] wb_adr_o,
  output reg [CPU_DATA_WIDTH-1:0] wb_dat_o,
  input wire [CPU_DATA_WIDTH-1:0] wb_dat_i,
  output reg [CPU_DATA_WIDTH/8-1:0] wb_sel_o,
  output reg wb_we_o
);
  reg [CPU_DATA_WIDTH-1:0] data;
  logic can_action;

  typedef enum logic[1:0] {
    ST_IDLE = 0,
    ST_READ_ACTION = 1,
    ST_WRITE_ACTION = 2
  } state_t;

  state_t state;

  // reset and state change
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      state <= ST_IDLE;
      wb_stb_o <= '0;
      wb_we_o <= '0;
      wb_sel_o <= '0;
      // wb_adr_o <= '0;
      // pipe_stall <= '0;
      pipe_stall <= '1;
    end else begin
      case (state)
        ST_IDLE: begin
          if (can_action) begin
            state <= ST_READ_ACTION;
            wb_stb_o <= '1;
            wb_we_o <= '0;
            // wb_adr_o <= cpu_adr_i;
            wb_sel_o <= cpu_sel_i;
            pipe_stall <= 1;
          end
        end
        ST_READ_ACTION: begin
          if (wb_ack_i) begin
            state <= ST_IDLE;
            wb_stb_o <= '0;
            data <= wb_dat_i;
            pipe_stall <= 0;
          end
        end
      endcase
    end
  end

  assign can_action = (~|((cpu_adr_i ^ RAM_ADR) & RAM_MSK)) & ~cpu_pipe_stall;
  assign wb_cyc_o = wb_stb_o;
  assign wb_dat_o = '0;
  assign cpu_dat_o = data;
  assign wb_adr_o = cpu_adr_i;

endmodule
