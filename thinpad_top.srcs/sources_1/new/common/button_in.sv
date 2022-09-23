module button_in (
    // 时钟与复位信号，每个时序模块都必须包含
    input wire clk,
    input wire reset,
    // 按键信号
    input wire push_btn,
    // 计数触发信号
    output wire trigger
    );
    
    reg last_stat_reg;
    reg trigger_reg;

    always_ff @ (posedge clk or posedge reset) begin
        if (reset) begin
            trigger_reg <= 1'b0;
            last_stat_reg <= 1'b0;
        end else begin
            if (push_btn) begin
                if (!last_stat_reg) begin
                    trigger_reg <= 1'b1;
                    last_stat_reg <= 1'b1;
                end else
                    trigger_reg <= 1'b0;
            end else begin
                last_stat_reg <= 1'b0;
                trigger_reg <= 1'b0;
            end
        end
    end

    assign trigger = trigger_reg;

endmodule
