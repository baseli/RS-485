module tx(
    input wire clk,
    input wire rst,
    input wire tx_vld,
    input wire [7:0] tx_data,

    output reg tx,
    output wire txrdy,
	 output reg is_busy
);

// 同样的这里还是9600Hz的频率
reg [13:0] rx_cnt;
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        rx_cnt <= 0;
    end
    else if (rx_cnt == 14'd2603) begin
        rx_cnt <= 0;
    end
    else begin
        rx_cnt <= rx_cnt + 1'b1;
    end
end

// 由于时序的原因，这里需要对tx_vld延时一个时钟
reg txvld_ok;
always @ (posedge clk) begin
	txvld_ok <= tx_vld;
end

// 如果tx_vld有效，将数据存放到一个寄存器中
reg [7:0] tx_rdy_data;
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        tx_rdy_data <= 8'b0;
    end
    else if (txvld_ok) begin
        tx_rdy_data <= tx_data;
    end
end


// 由于计数器计到1302的时候是最佳采样
wire rx_en;
assign rx_en = (rx_cnt == 14'd1301);

// 当tx_vld有效时，进行计数，通过计数的过程进行判断要发送哪一位
reg tran_vld;
reg [3:0] tran_cnt;
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        tran_vld <= 1'b0;
    end
    else if (tran_vld & rx_en & (tran_cnt == 4'd11)) begin
        tran_vld <= 1'b0;
    end
    else if (tx_vld) begin
        tran_vld <= 1'b1;
    end	 
end

reg data_change;
reg start;
always @ (posedge clk or posedge rst) begin
	if (rst) begin
		data_change <= 1'b0;
	end
	else if (~(tx_rdy_data == tx_data)) begin
		data_change <= 1'b1;
	end
	else if (tx_rdy_data == tx_data) begin
		data_change <= 1'b0;
	end
end

always @ (posedge clk or posedge rst) begin
	if (rst) begin
		start = 1'b0;
	end
	else if(data_change == 1'b1) begin
		start = 1'b1;
	end
	else if (tran_cnt == 4'd11) begin
		start = 1'b0;
	end
end

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        tran_cnt <= 4'b0;
    end
    else if (tran_vld & start) begin
        if (rx_en) begin
            tran_cnt <= tran_cnt + 1'b1;
//				if (tran_cnt == 4'd10) begin
//					tran_cnt <= 4'b0;
//				end
        end
    end
    else begin
        tran_cnt <= 4'b0;
    end
end

// 利用上边的计数器，从而确定发送的是数据的第几位
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        tx <= 1'b1;
		  is_busy <= 1'b0;
    end
    else if (tran_vld) begin
        if (rx_en) begin
            is_busy <= 1'b1;
				case (tran_cnt)
            4'd0  : tx <= 1'b1;
            4'd1  : tx <= 1'b0;
            4'd2  : tx <= tx_rdy_data[0];
            4'd3  : tx <= tx_rdy_data[1];
            4'd4  : tx <= tx_rdy_data[2];
            4'd5  : tx <= tx_rdy_data[3];
            4'd6  : tx <= tx_rdy_data[4];
            4'd7  : tx <= tx_rdy_data[5];
            4'd8  : tx <= tx_rdy_data[6];
            4'd9  : tx <= tx_rdy_data[7];
            4'd10 : tx <= ^tx_rdy_data;
				4'd11 : tx <= 1'b1;
            default: tx <= 1'b1;
            endcase
        end
    end
	 else begin
		tx <= 1'b1;
		is_busy <= 1'b0;
	 end
end

assign txrdy = ~tran_vld;

endmodule