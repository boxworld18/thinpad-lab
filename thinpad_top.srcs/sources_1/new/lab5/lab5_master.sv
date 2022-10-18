module lab5_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input wire clk_i,
    input wire rst_i,

    // TODO: 添加需要的控制信号，例如按键开关？
    input wire [31:0] dip_sw, 

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
  localparam REG_DATA = 32'h1000_0000;
  localparam REG_STATUS = 32'h1000_0005;

  reg [31:0] addr;
  reg [31:0] sign;
  reg [31:0] data;
  reg [3:0] cnt = '0;

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

  always_comb begin
    case (state) 
      ST_IDLE: begin
        state_n = ST_READ_WAIT_ACTION;
      end

      ST_READ_WAIT_ACTION: begin
        if (wb_ack_i == 1) begin
          state_n = ST_READ_WAIT_CHECK;
        end else begin
          state_n = ST_READ_WAIT_ACTION;
        end
      end

      ST_READ_WAIT_CHECK: begin
        if (sign[0]) begin
          state_n = ST_READ_DATA_ACTION;
        end else begin
          state_n = ST_READ_WAIT_ACTION;
        end
      end

      ST_READ_DATA_ACTION: begin
        if (wb_ack_i == 1) begin
          state_n = ST_READ_DATA_DONE;
        end else begin
          state_n = ST_READ_DATA_ACTION;
        end
      end

      ST_READ_DATA_DONE: begin
        state_n = ST_WRITE_SRAM_ACTION;
      end

      ST_WRITE_SRAM_ACTION: begin
        if (wb_ack_i == 1) begin
          state_n = ST_WRITE_SRAM_DONE;
        end else begin
          state_n = ST_WRITE_SRAM_ACTION;
        end
      end

      ST_WRITE_SRAM_DONE: begin
        state_n = ST_WRITE_WAIT_ACTION;
      end

      ST_WRITE_WAIT_ACTION: begin
        if (wb_ack_i == 1) begin
          state_n = ST_WRITE_WAIT_CHECK;
        end else begin
          state_n = ST_WRITE_WAIT_ACTION;
        end
      end

      ST_WRITE_WAIT_CHECK: begin
        if (sign[5]) begin
          state_n = ST_WRITE_DATA_ACTION;
        end else begin
          state_n = ST_WRITE_WAIT_ACTION;
        end
      end

      ST_WRITE_DATA_ACTION: begin
        if (wb_ack_i == 1) begin
          state_n = ST_WRITE_DATA_DONE;
        end else begin
          state_n = ST_WRITE_DATA_ACTION;
        end
      end

      ST_WRITE_DATA_DONE: begin
        if (cnt < 4'd9) begin
          state_n = ST_IDLE;
        end else begin
          state_n = ST_WRITE_DATA_DONE;
        end
      end

      default: begin
        state_n = ST_IDLE;
      end
    endcase
  end

  always_comb begin
    case (state)
      ST_READ_WAIT_ACTION, ST_READ_DATA_ACTION, ST_WRITE_SRAM_ACTION, ST_WRITE_WAIT_ACTION, ST_WRITE_DATA_ACTION: begin
        if (wb_ack_i) begin
          wb_cyc_o = 0;
        end else begin
          wb_cyc_o = 1;
        end
      end
      default: begin
        wb_cyc_o = 0;
      end
    endcase
  end

  assign wb_we_o = (state == ST_WRITE_SRAM_ACTION) || (state == ST_WRITE_SRAM_DONE) || 
                   (state == ST_WRITE_DATA_ACTION) || (state == ST_WRITE_DATA_DONE);
  assign wb_stb_o = wb_cyc_o;
  assign wb_sel_o = 4'b0001;

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      addr <= dip_sw;
      cnt <= '0;
      sign <= '0;
      data <= '0;
    end else begin
      case (state)
        ST_IDLE: begin
          wb_adr_o <= REG_STATUS;
        end

        ST_READ_WAIT_ACTION: begin
          wb_adr_o <= REG_STATUS;
          sign <= wb_dat_i;
        end

        ST_READ_WAIT_CHECK: begin
          if (sign[0]) begin
            wb_adr_o <= REG_DATA;
          end else begin
            wb_adr_o <= REG_STATUS;
          end
        end

        ST_READ_DATA_ACTION: begin
          wb_adr_o <= REG_DATA;
          data <= wb_dat_i;
        end

        ST_READ_DATA_DONE: begin
          wb_adr_o <= addr;
          wb_dat_o <= data;
        end

        ST_WRITE_SRAM_ACTION: begin
          wb_adr_o <= addr;
          wb_dat_o <= data;
        end

        ST_WRITE_SRAM_DONE: begin
          wb_adr_o <= REG_STATUS;
        end

        ST_WRITE_WAIT_ACTION: begin
          wb_adr_o <= REG_STATUS;
          sign <= wb_dat_i;
        end

        ST_WRITE_WAIT_CHECK: begin
          if (sign[5]) begin
            wb_adr_o <= REG_DATA;
            wb_dat_o <= data;
          end else begin
            wb_adr_o <= REG_STATUS;
          end
        end

        ST_WRITE_DATA_ACTION: begin
          wb_adr_o <= REG_DATA;
          wb_dat_o <= data;
        end

        ST_WRITE_DATA_DONE: begin
          wb_adr_o <= REG_STATUS;
          if (cnt < 4'd9) begin
            cnt <= cnt + 1;
            addr <= addr + 4;
          end
        end

        default: begin
          wb_adr_o <= REG_STATUS;
          wb_dat_o <= '0;
        end
      endcase
    end
  end

endmodule
 