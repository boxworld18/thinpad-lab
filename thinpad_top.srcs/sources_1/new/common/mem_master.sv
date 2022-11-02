`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2022 02:15:06 AM
// Design Name: 
// Module Name: mem_master
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

module mem_master(
  input wire clk_i,
  input wire rst_i,

  input wire cpu_mem_read,
  input wire cpu_mem_write,
  input wire [ADDR_WIDTH-1:0] cpu_adr_i,
  input wire [CPU_DATA_WIDTH/8-1:0] cpu_sel_i,
  input wire [ADDR_WIDTH-1:0] cpu_dat_i,
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
  reg [CPU_DATA_WIDTH-1:0] data_o;
  reg [CPU_DATA_WIDTH-1:0] data_i;
  reg [5:0] bias;
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
      wb_adr_o <= '0;
      wb_dat_o <= '0;
      pipe_stall <= '0;
    end else begin
      case (state)
        ST_IDLE: begin
          if (can_action && (cpu_mem_read || cpu_mem_write)) begin
            data_o <= '0;
            wb_stb_o <= '1; 
            wb_adr_o <= cpu_adr_i;
            wb_sel_o <= (cpu_sel_i << (cpu_adr_i[1:0]));
            bias <= cpu_adr_i[1:0] << 3;
            pipe_stall <= 1;
            if (cpu_mem_read) begin
              state <= ST_READ_ACTION;
              wb_we_o <= '0;
            end else if (cpu_mem_write) begin
              state <= ST_WRITE_ACTION;
              wb_we_o <= '1;
              wb_dat_o <= cpu_dat_i;
            end
          end
        end
        ST_READ_ACTION: begin
          if (wb_ack_i) begin
            state <= ST_IDLE;
            wb_stb_o <= '0;
            pipe_stall <= 0;
            data_o <= data_i >> bias;
          end
        end
        ST_WRITE_ACTION: begin
          if (wb_ack_i) begin
            state <= ST_IDLE;
            wb_stb_o <= '0;
            pipe_stall <= 0;
          end
        end
      endcase
    end
  end

  assign data_i[7:0] = (wb_sel_o[0]) ? wb_dat_i[7:0] : 8'b0;
  assign data_i[15:8] = (wb_sel_o[1]) ? wb_dat_i[15:8] : 8'b0;
  assign data_i[23:16] = (wb_sel_o[2]) ? wb_dat_i[23:16] : 8'b0;
  assign data_i[31:24] = (wb_sel_o[3]) ? wb_dat_i[31:24] : 8'b0;

  assign can_action = ~cpu_pipe_stall;
  assign wb_cyc_o = wb_stb_o;
  assign cpu_dat_o = data_o;

endmodule
