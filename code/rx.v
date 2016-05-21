module rx(
    input wire clk,
    input wire rst,
    input wire rx,

    output reg rx_vld,
    output reg [7:0] rx_data
);

// 为了消除异步传送的不确定性
reg rx1, rx2, rx3, rxx;
always @ (posedge clk) begin
    rx1 <= rx;
    rx2 <= rx1;
    rx3 <= rx2;
    rxx <= rx3;
end

// 检测rxx是否发生了变化
reg rx_dly;
always @ (posedge clk)
    rx_dly <= rxx;

wire rx_change;
assign rx_change = (rxx != rx_dly);


// 由于这里串口通信时选择的频率是9600Hz，所以使用2604为计数周期
reg [13:0] rx_cnt;
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        rx_cnt <= 0;
    end
    else if (rx_change | rx_cnt == 14'd2603) begin
        rx_cnt <= 0;
    end
    else begin
        rx_cnt <= rx_cnt + 1'b1;
    end
end

// 由于计数器计到1302的时候是最佳采样
wire rx_en;
assign rx_en = (rx_cnt == 14'd1301);

// 如果在rx_en等于1的时候，检测到了rxx等于0，就知道要开始传送数据了
// 这个传送过来的数据应该是10bit的，8bit的数据，1bit的奇偶校验，1bit的停止位
// 所以就需要一个新的计数器来计数，完成这个字节数据的接受

reg data_vld;
reg [3:0]data_cnt;
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        data_vld <= 1'b0;
    end
    else if (rx_en & ~rxx & ~data_vld) begin
        data_vld <= 1'b1;
    end
    else if (data_vld & (data_cnt == 4'h9) & rx_en) begin
        data_vld <= 1'b0;
    end
end

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        data_cnt <= 4'b0;
    end
    else if (data_vld) begin
        if (rx_en) begin
            data_cnt <= data_cnt + 1'b1;
        end
    end
    else begin
        data_cnt <= 4'b0;
    end
end

// 前边已经开始传送数据的时候接受数据并计数，这里开始处理数据，接受rxx的数据，并向右移位完成
reg [7:0] rx_data_tmp;
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        rx_data_tmp <= 8'b0;
    end
    else if (data_vld & rx_en & ~data_cnt[3]) begin
        rx_data_tmp <= {rxx, rx_data_tmp[7:1]};
    end
end

// 如果数据接收完毕，设置rx_vld有效
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        rx_vld <= 1'b0;
    end
    else begin
        rx_vld <= data_vld & rx_en & (data_cnt == 4'h9);
    end
end

// 判断并输出rx_data
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        rx_data <= 8'b0;
    end
    else if (rx_vld) begin
        rx_data <= rx_data_tmp;
    end
end

endmodule