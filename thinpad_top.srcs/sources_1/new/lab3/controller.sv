`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/22 11:33:15
// Design Name: 
// Module Name: controller
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


module controller (
    input wire clk,
    input wire reset,

    // 连接寄存器堆模块的信号
    output reg  [4:0]  rf_raddr_a,
    input  wire [15:0] rf_rdata_a,
    output reg  [4:0]  rf_raddr_b,
    input  wire [15:0] rf_rdata_b,
    output reg  [4:0]  rf_waddr,
    output reg  [15:0] rf_wdata,
    output reg  rf_wen,

    // 连接 ALU 模块的信号
    output reg  [15:0] alu_a,
    output reg  [15:0] alu_b,
    output reg  [ 3:0] alu_op,
    input  wire [15:0] alu_y,

    // 控制信号
    input  wire        step,    // 用户按键状态脉冲
    input  wire [31:0] dip_sw,  // 32 位拨码开关状态
    output reg  [15:0] leds
);

  logic [31:0] inst_reg;  // 指令寄存器

  // 组合逻辑，解析指令中的常用部分，依赖于有效的 inst_reg 值
  logic is_rtype, is_itype, is_peek, is_poke;
  logic [15:0] imm;
  logic [4:0] rd, rs1, rs2;
  logic [3:0] opcode;

  always_comb begin
    is_rtype = (inst_reg[2:0] == 3'b001);
    is_itype = (inst_reg[2:0] == 3'b010);
    is_peek = is_itype && (inst_reg[6:3] == 4'b0010);
    is_poke = is_itype && (inst_reg[6:3] == 4'b0001);

    imm = inst_reg[31:16];
    rd = inst_reg[11:7];
    rs1 = inst_reg[19:15];
    rs2 = inst_reg[24:20];
    opcode = inst_reg[6:3];
  end

  // 使用枚举定义状态列表，数据类型为 logic [3:0]
  typedef enum logic [3:0] {
    ST_INIT,
    ST_DECODE,
    ST_CALC,
    ST_READ_REG,
    ST_WRITE_REG
  } state_t;

  // 状态机当前状态寄存器
  state_t cur_state;
  state_t next_state;

  // 状态机逻辑
  always_ff @(posedge clk) begin
    if (reset) begin
      cur_state <= ST_INIT;
    end else begin
      cur_state <= next_state;
    end
  end

  always_comb begin
    next_state = ST_INIT;
    case (cur_state)
      ST_INIT: begin
        if (step) begin
          next_state = ST_DECODE;
        end else begin
          next_state = ST_INIT;
        end
      end

      ST_DECODE: begin
        if (is_rtype) begin
          next_state = ST_CALC;
        end else if (is_peek) begin
          next_state = ST_READ_REG;
        end else if (is_poke) begin
          next_state = ST_WRITE_REG;
        end else begin
          next_state = ST_INIT;
        end
      end

      ST_CALC: begin
        next_state = ST_WRITE_REG;
      end

      ST_WRITE_REG: begin
        next_state = ST_INIT;
      end

      ST_READ_REG: begin
        next_state = ST_INIT;
      end

      default: begin
        next_state = ST_INIT;
      end

    endcase
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      inst_reg <= 32'b0;
      leds <= 32'b0;
      rf_wen <= 1'b0;
    end else begin
      case (cur_state)
        ST_INIT: begin
          if (step) begin
            inst_reg <= dip_sw;
            rf_wen <= 1'b0;
          end
        end

        ST_DECODE: begin
          if (is_rtype) begin
            rf_raddr_a <= rs1;
            rf_raddr_b <= rs2;
            rf_wen <= 1'b0;
          end else if (is_peek) begin
            rf_raddr_a <= rd;
            rf_wen <= 1'b0;
          end else if (is_poke) begin
            rf_waddr <= rd;
            rf_wdata <= imm;
            rf_wen <= 1'b1;
          end
        end

        ST_CALC: begin
          // TODO: 将数据交给 ALU，并从 ALU 获取结果
          alu_a <= rf_rdata_a;
          alu_b <= rf_rdata_b;
          alu_op <= opcode;
        end

        ST_WRITE_REG: begin
          // TODO: 将结果存入寄存器
          rf_wen <= 1'b1;
          rf_waddr <= rd;
          if (is_rtype) begin
            rf_wdata <= alu_y;
          end else begin
            rf_wdata <= imm;
          end
        end

        ST_READ_REG: begin
          // TODO: 将数据从寄存器中读出，存入 leds
          rf_wen <= 1'b0;
          leds <= rf_rdata_a;
        end

        default: begin
          rf_wen <= 1'b0;
          leds <= 32'b0;
        end 
      endcase
    end
  end
endmodule