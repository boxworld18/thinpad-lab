module lab5_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input wire clk_i,
    input wire rst_i,

    // TODO: 添加需要的控制信号，例如按键开关？

    // wishbone master
    output reg wb_cyc_o,
    output reg wb_stb_o,
    input wire wb_ack_i,
    output reg [ADDR_WIDTH-1:0] wb_adr_o,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH/8-1:0] wb_sel_o,
    output reg wb_we_o
);

  // TODO: 实现实验 5 的内存+串口 Master
  typedef enum logic [3:0] {
    ST_IDLE = 0,
    ST_READ_WAIT_ACTION = 1,
    ST_READ_WAIT_CHECK = 2,
    ST_READ_DATA_ACTION = 3,
    ST_READ_DATA_DONE = 4,
    ST_WRITE_SRAM_ACTION = 5,
    ST_WRITE_SRAM_DONE = 6,
    ST_WRITE_WAIT_ACTION = 7,
    ST_WRITE_WAIT_CHECK = 8,
    ST_WRITE_DATA_ACTION = 9,
    ST_WRITE_DATA_DONE = 10
  } state_t;

  state_t state, state_n;

  // reset and state change
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      state <= ST_IDLE;
    end else begin
      state <= state_n;
    end
  end

  // states
  // always_comb begin
  //   state_n = state;
  //   case (state)
  //     ST_IDLE: begin
  //       if (wb_stb_o && wb_cyc_o) begin
  //         if (wb_we_i) begin
  //           state_n = ST_WRITE;
  //         end else begin
  //           state_n = ST_READ;
  //         end
  //       end
  //     end

  //     ST_READ: begin
  //       state_n = ST_READ_2;
  //     end

  //     ST_READ_2: begin
  //       state_n = ST_DONE;
  //     end

  //     ST_WRITE: begin
  //       state_n = ST_WRITE_2;
  //     end

  //     ST_WRITE_2: begin
  //       state_n = ST_WRITE_3;
  //     end

  //     ST_WRITE_3: begin
  //       state_n = ST_DONE;
  //     end

  //     ST_DONE: begin
  //       state_n = ST_IDLE;
  //     end

  //     default: begin
  //       state_n = ST_IDLE;
  //     end
  //   endcase
  // end

endmodule
 