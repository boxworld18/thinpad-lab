module sram_controller #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,

    parameter SRAM_ADDR_WIDTH = 20,
    parameter SRAM_DATA_WIDTH = 32,

    localparam SRAM_BYTES = SRAM_DATA_WIDTH / 8,
    localparam SRAM_BYTE_WIDTH = $clog2(SRAM_BYTES)
) (
    // clk and reset
    input wire clk_i,
    input wire rst_i,

    // wishbone slave interface
    input wire wb_cyc_i,
    input wire wb_stb_i,
    output reg wb_ack_o,
    input wire [ADDR_WIDTH-1:0] wb_adr_i,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH/8-1:0] wb_sel_i,
    input wire wb_we_i,

    // sram interface
    output reg [SRAM_ADDR_WIDTH-1:0] sram_addr,
    inout wire [SRAM_DATA_WIDTH-1:0] sram_data,
    output reg sram_ce_n,
    output reg sram_oe_n,
    output reg sram_we_n,
    output reg [SRAM_BYTES-1:0] sram_be_n
);

  // SRAM 控制器
  typedef enum logic [2:0] {
    ST_IDLE = 0,
    ST_READ = 1,
    ST_READ_2 = 2,
    ST_WRITE = 3,
    ST_WRITE_2 = 4,
    ST_WRITE_3 = 5,
    ST_DONE = 6
  } state_t;

  state_t state;
  reg [SRAM_DATA_WIDTH-1:0] data;

  // reset and state change
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      state <= ST_IDLE;
      wb_ack_o <= 0;
      sram_we_n <= 1;
      sram_oe_n <= 1;
      sram_ce_n <= 1;
      sram_be_n <= '0;
      data <= '0;
    end else begin
      case (state)
      ST_IDLE: begin
        wb_ack_o <= 0;
        sram_addr <= wb_adr_i[21: 2];
        if (wb_stb_i && wb_cyc_i) begin
          sram_ce_n <= 0;
          if (wb_we_i) begin
            state <= ST_WRITE;
            sram_be_n <= ~wb_sel_i;
          end else begin
            state <= ST_READ;
            sram_oe_n <= 0;
          end
        end
      end

      ST_READ: begin
        state <= ST_READ_2;
      end

      ST_READ_2: begin
        state <= ST_DONE;
        wb_ack_o <= 1;
        sram_oe_n <= 1;
        sram_ce_n <= 1;
        data <= wb_dat_i;
        wb_dat_o <= sram_data;
      end

      ST_WRITE: begin
        state <= ST_WRITE_2;
        sram_we_n <= 0;
      end

      ST_WRITE_2: begin
        state <= ST_WRITE_3;
        sram_we_n <= 1;
      end

      ST_WRITE_3: begin
        state <= ST_DONE;
        wb_ack_o <= 1;
        sram_ce_n <= 1;
        sram_be_n <= '0;
      end

      ST_DONE: begin
        state <= ST_IDLE;
        wb_ack_o <= 0;
      end

      default: begin
        state = ST_IDLE;
      end
    endcase
    end
  end

  // data processing
  assign sram_data = sram_we_n ? 32'bz : wb_dat_i;
  // assign wb_dat_o = sram_data;

endmodule
