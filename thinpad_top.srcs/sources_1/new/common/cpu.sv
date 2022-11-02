`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2022 01:03:17 AM
// Design Name: 
// Module Name: cpu
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

module cpu (
  input wire clk_i,
  input wire rst_i,
  
  // IF master
  output reg wbm0_cyc_o,
  output reg wbm0_stb_o,
  input wire wbm0_ack_i,
  output reg [ADDR_WIDTH-1:0] wbm0_adr_o,
  output reg [CPU_DATA_WIDTH-1:0] wbm0_dat_o,
  input wire [CPU_DATA_WIDTH-1:0] wbm0_dat_i,
  output reg [CPU_DATA_WIDTH/8-1:0] wbm0_sel_o,
  output reg wbm0_we_o,

  // MEM master
  output reg wbm1_cyc_o,
  output reg wbm1_stb_o,
  input wire wbm1_ack_i,
  output reg [ADDR_WIDTH-1:0] wbm1_adr_o,
  output reg [CPU_DATA_WIDTH-1:0] wbm1_dat_o,
  input wire [CPU_DATA_WIDTH-1:0] wbm1_dat_i,
  output reg [CPU_DATA_WIDTH/8-1:0] wbm1_sel_o,
  output reg wbm1_we_o
);

  // IF signals
  logic [CPU_DATA_WIDTH-1:0] if_pc;
  logic [CPU_DATA_WIDTH-1:0] if_pc_add4;
  logic [CPU_DATA_WIDTH-1:0] if_pc_next;
  logic [CPU_DATA_WIDTH-1:0] if_instr;
  logic if_pc_write;
  logic if_pc_src;
  logic if_d_write;
  logic if_stall;

  // IF/ID signals
  logic [CPU_DATA_WIDTH-1:0] if_id_pc;
  logic [CPU_DATA_WIDTH-1:0] if_id_instr;
  logic if_id_flush;

  // ID signals
  logic [CPU_DATA_WIDTH-1:0] id_imm;
  logic [REG_ADDR_WIDTH-1:0] id_rs1;
  logic [REG_ADDR_WIDTH-1:0] id_rs2;
  logic [CPU_DATA_WIDTH-1:0] id_rdata_a;
  logic [CPU_DATA_WIDTH-1:0] id_rdata_b;
  logic [REG_ADDR_WIDTH-1:0] id_rd;

  // Control unit signals
  // Ref: Graph 4-47
  logic [ALU_OP_WIDTH-1:0] id_alu_op;
  logic id_alu_src;
  logic id_branch;
  logic id_mem_read;
  logic id_mem_write;
  logic [CPU_DATA_WIDTH/8-1:0] id_mem_sel;
  logic id_mem_to_reg;
  logic id_reg_write;

  // ID/EX signals
  logic [CPU_DATA_WIDTH-1:0] id_ex_pc;
  logic [CPU_DATA_WIDTH-1:0] id_ex_instr;
  logic [REG_ADDR_WIDTH-1:0] id_ex_rs1;
  logic [REG_ADDR_WIDTH-1:0] id_ex_rs2;
  logic [REG_ADDR_WIDTH-1:0] id_ex_rd;
  logic [CPU_DATA_WIDTH-1:0] id_ex_rdata_a;
  logic [CPU_DATA_WIDTH-1:0] id_ex_rdata_b;
  logic [CPU_DATA_WIDTH-1:0] id_ex_imm;
  
  logic [ALU_OP_WIDTH-1:0] id_ex_alu_op;
  logic id_ex_alu_src;
  logic id_ex_branch;
  logic id_ex_mem_read;
  logic id_ex_mem_write;
  logic id_ex_mem_to_reg; // determines whether to write back from memory or from ALU
  logic id_ex_reg_write; // write target data
  logic [CPU_DATA_WIDTH/8-1:0] id_ex_mem_sel;

  // EX signals
  logic [FORWARD_SEL_WIDTH-1:0] ex_forward_a;
  logic [FORWARD_SEL_WIDTH-1:0] ex_forward_b;
  logic [ALU_CTRL_WIDTH-1:0] ex_alu_op4;
  logic [CPU_DATA_WIDTH-1:0] ex_alu_a;
  logic [CPU_DATA_WIDTH-1:0] ex_alu_b;
  logic [CPU_DATA_WIDTH-1:0] ex_sel_b;
  logic [CPU_DATA_WIDTH-1:0] ex_alu_out;
  logic [CPU_DATA_WIDTH-1:0] ex_pc_sum;
  logic ex_alu_zero;
  
  logic ex_mem_alu_zero;
  logic [CPU_DATA_WIDTH-1:0] ex_mem_alu_out;
  logic [CPU_DATA_WIDTH-1:0] ex_mem_rdata;
  logic [REG_ADDR_WIDTH-1:0] ex_mem_rd;
  logic [CPU_DATA_WIDTH-1:0] ex_mem_pc_sum;

  logic ex_mem_branch;
  logic ex_mem_mem_read;
  logic ex_mem_mem_write;
  logic ex_mem_mem_to_reg;
  logic ex_mem_reg_write;
  logic [CPU_DATA_WIDTH/8-1:0] ex_mem_mem_sel; // determines wheter to read/write 1 byte or 4 bytes

  // MEM signals
  logic mem_stall;
  logic [CPU_DATA_WIDTH-1:0] mem_rdata;

  logic [CPU_DATA_WIDTH-1:0] mem_wb_rdata;
  logic [CPU_DATA_WIDTH-1:0] mem_wb_alu_out;
  logic [REG_ADDR_WIDTH-1:0] mem_wb_rd;

  // Control unit signals
  logic mem_wb_mem_to_reg;
  logic mem_wb_reg_write;

  // WB signals
  logic [CPU_DATA_WIDTH-1:0] wb_wdata;

  // [IF] IF Master
  if_master if_mas (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .cpu_adr_i(if_pc),
    .cpu_sel_i(4'b1111),
    .cpu_dat_o(if_instr),
    .cpu_pipe_stall(mem_stall),
    .pipe_stall(if_stall),
    .wb_cyc_o(wbm0_cyc_o),
    .wb_stb_o(wbm0_stb_o),
    .wb_ack_i(wbm0_ack_i),
    .wb_adr_o(wbm0_adr_o),
    .wb_dat_o(wbm0_dat_o),
    .wb_dat_i(wbm0_dat_i),
    .wb_sel_o(wbm0_sel_o),
    .wb_we_o (wbm0_we_o)
  );

  // [ID] Imm Gen unit
  imm_gen ig_unit (
    .instr(if_id_instr),
    .imm(id_imm)
  );

  // [ID] Control unit
  logic pipe_stall;
  control_unit ctrl_unit (
    .instr(if_id_instr),
    .alu_op(id_alu_op),
    .alu_src(id_alu_src),
    .branch(id_branch),
    .mem_read(id_mem_read),
    .mem_write(id_mem_write),
    .mem_sel(id_mem_sel),
    .mem_to_reg(id_mem_to_reg),
    .reg_write(id_reg_write),
    .pipe_stall(pipe_stall)
  );

  // [ID] Hazard detection unit
  hazard_detection_unit haza_unit (
    .id_ex_mem_read(id_ex_mem_read),
    .id_ex_rd(id_ex_rd),
    .if_id_rs1(id_rs1),
    .if_id_rs2(id_rs2),
    .pipe_stall(pipe_stall),
    .pc_write(if_pc_write),
    .if_d_write(if_d_write)
  );

  // [ID] Registers file
  register_file reg_file (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .raddr_a(id_rs1),
    .raddr_b(id_rs2),
    .rdata_a(id_rdata_a),
    .rdata_b(id_rdata_b),
    .waddr(mem_wb_rd),
    .wdata(wb_wdata),
    .wen(mem_wb_reg_write)
  );

  // [EX] ALU control unit
  alu_controller alu_ctrl (
    .funct3(id_ex_instr[14:12]),
    .funct7(id_ex_instr[31:25]),
    .alu_op(id_ex_alu_op),
    .alu_op4(ex_alu_op4)
  );

  // [EX] ALU unit
  alu alu_unit (
    .a(ex_alu_a),
    .b(ex_alu_b),
    .op(ex_alu_op4),
    .zero(ex_alu_zero),
    .y(ex_alu_out)
  );

  // [EX] Forwarding unit
  forwarding_unit forw_unit (
    .id_ex_rs1(id_ex_rs1),
    .id_ex_rs2(id_ex_rs2),
    .ex_mem_rd(ex_mem_rd),
    .mem_wb_rd(mem_wb_rd),
    .ex_mem_reg_write(ex_mem_reg_write),
    .mem_wb_reg_write(mem_wb_reg_write),
    .forward_a(ex_forward_a),
    .forward_b(ex_forward_b)
  );

  // [MEM] MEM Master
  mem_master mem_mas (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .cpu_mem_read(ex_mem_mem_read),
    .cpu_mem_write(ex_mem_mem_write),
    .cpu_adr_i(ex_mem_alu_out),
    .cpu_sel_i(ex_mem_mem_sel),
    .cpu_dat_i(ex_mem_rdata),
    .cpu_dat_o(mem_rdata),
    .cpu_pipe_stall(if_stall),
    .pipe_stall(mem_stall),
    .wb_cyc_o(wbm1_cyc_o),
    .wb_stb_o(wbm1_stb_o),
    .wb_ack_i(wbm1_ack_i),
    .wb_adr_o(wbm1_adr_o),
    .wb_dat_o(wbm1_dat_o),
    .wb_dat_i(wbm1_dat_i),
    .wb_sel_o(wbm1_sel_o),
    .wb_we_o (wbm1_we_o)
  );

  // IF Register change
  always_comb begin
    if_pc_add4 = if_pc + 4;
    if_pc_src = id_ex_branch & ex_alu_zero;
    if_id_flush = ~(id_branch || id_ex_branch);
    if_pc_next = if_pc_src ? ex_pc_sum : if_pc_add4;
  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      if_id_instr <= 32'b0;
      if_id_pc <= 32'b0;
      if_pc <= 32'h8000_0000;
    end else begin
    
      if (!if_stall && !mem_stall && !pipe_stall) begin
        if (if_id_flush && if_d_write) begin
          if_id_instr <= if_instr;
          // if_id_pc <= if_pc_cur;
          if_id_pc <= if_pc;
        end else begin
          if_id_instr <= '0;
          if_id_pc <= '0;
        end
        if ((if_id_flush || if_pc_src) && if_pc_write) begin
          if_pc <= if_pc_next;
          // if_pc_cur <= if_pc;
        end
      end
    end
  end

  // ID Register change
  always_comb begin 
    id_rs1 = if_id_instr[19:15];
    id_rs2 = if_id_instr[24:20];
    id_rd = if_id_instr[11:7];
  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      id_ex_pc <= '0;
      id_ex_instr <= '0;
      id_ex_alu_op <= '0;
      id_ex_alu_src <= '0;
      id_ex_branch <= '0;
      id_ex_mem_read <= '0;
      id_ex_mem_write <= '0;
      id_ex_mem_sel <= '0;
      id_ex_mem_to_reg <= '0;
      id_ex_reg_write <= '0;
      id_ex_imm <= '0;
      id_ex_rs1 <= '0;
      id_ex_rs2 <= '0;
      id_ex_rd <= '0;
      id_ex_rdata_a <= '0;
      id_ex_rdata_b <= '0;
    end else begin
      if (!if_stall && !mem_stall) begin
        id_ex_pc <= if_id_pc;
        id_ex_instr <= if_id_instr;
        id_ex_alu_op <= id_alu_op;
        id_ex_alu_src <= id_alu_src;
        id_ex_branch <= id_branch;
        id_ex_mem_read <= id_mem_read;
        id_ex_mem_write <= id_mem_write;
        id_ex_mem_sel <= id_mem_sel;
        id_ex_mem_to_reg <= id_mem_to_reg;
        id_ex_reg_write <= id_reg_write;
        id_ex_imm <= id_imm;
        id_ex_rs1 <= id_rs1;
        id_ex_rs2 <= id_rs2;
        id_ex_rd <= id_rd;
        id_ex_rdata_a <= id_rdata_a;
        id_ex_rdata_b <= id_rdata_b;
      end
    end
  end

  // EX Register change
  always_comb begin
    ex_alu_a = ((ex_forward_a == 2'b10)? ex_mem_alu_out : 
               ((ex_forward_a == 2'b01)? wb_wdata : id_ex_rdata_a));
    ex_sel_b = ((ex_forward_b == 2'b10)? ex_mem_alu_out : 
               ((ex_forward_b == 2'b01)? wb_wdata : id_ex_rdata_b));
    ex_alu_b = id_ex_alu_src? id_ex_imm : ex_sel_b;
               
    ex_pc_sum = id_ex_pc + id_ex_imm;
  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      ex_mem_branch <= '0;
      ex_mem_mem_read <= '0;
      ex_mem_mem_write <= '0;
      ex_mem_mem_sel <= '0;
      ex_mem_mem_to_reg <= '0;
      ex_mem_reg_write <= '0;
      ex_mem_pc_sum <= '0;
      ex_mem_alu_out <= '0;
      ex_mem_alu_zero <= '0;
      ex_mem_rdata <= '0;
      ex_mem_rd <= '0;
    end else begin
      if (!if_stall && !mem_stall) begin
        ex_mem_branch <= id_ex_branch;
        ex_mem_mem_read <= id_ex_mem_read;
        ex_mem_mem_write <= id_ex_mem_write;
        ex_mem_mem_sel <= id_ex_mem_sel;
        ex_mem_mem_to_reg <= id_ex_mem_to_reg;
        ex_mem_reg_write <= id_ex_reg_write;

        ex_mem_pc_sum <= ex_pc_sum;
        ex_mem_alu_out <= ex_alu_out;
        ex_mem_alu_zero <= ex_alu_zero;
        ex_mem_rdata <= ex_sel_b;
        ex_mem_rd <= id_ex_rd;
      end
    end
  end

  // MEM Register change
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      mem_wb_mem_to_reg <= 1'b0;
      mem_wb_reg_write <= 1'b0;
      mem_wb_rdata <= 32'b0;
      mem_wb_alu_out <= 32'b0;
      mem_wb_rd <= 5'b0;
    end else begin
      if (!if_stall && !mem_stall) begin
        mem_wb_mem_to_reg <= ex_mem_mem_to_reg;
        mem_wb_reg_write <= ex_mem_reg_write;
        mem_wb_rdata <= mem_rdata;
        mem_wb_alu_out <= ex_mem_alu_out;
        mem_wb_rd <= ex_mem_rd;
      end
    end
  end

  // WB Register change
  always_comb begin
    wb_wdata = mem_wb_mem_to_reg ? mem_rdata : mem_wb_alu_out;
  end

endmodule
