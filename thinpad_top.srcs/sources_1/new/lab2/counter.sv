module counter(
    // 时钟与复位信号，每个时序模块都必须包含
    input wire clk,
    input wire reset,
    // 计数触发信号
    input wire trigger,
    // 当前计数值
    output wire [3:0] count
    );
    
    reg [3:0] count_reg;
    always_ff @ (posedge clk or posedge reset) begin
        if (reset) begin
            count_reg <= 4'd0;
        end else begin
            if (trigger && count_reg != 4'hf)   // 增加此处
                count_reg <= count_reg + 4'd1;  // 暂时忽略计数溢出
        end
    end
    assign count = count_reg;

endmodule
