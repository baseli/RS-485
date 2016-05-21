module tx(
    input wire clk,
    input wire rst,
    input wire tx_vld,
    input wire [7:0] tx_data,

    output reg tx,
    output wire txrdy,
	 output reg is_busy
);

// ͬ�������ﻹ��9600Hz��Ƶ��
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

// ����ʱ���ԭ��������Ҫ��tx_vld��ʱһ��ʱ��
reg txvld_ok;
always @ (posedge clk) begin
	txvld_ok <= tx_vld;
end

// ���tx_vld��Ч�������ݴ�ŵ�һ���Ĵ�����
reg [7:0] tx_rdy_data;
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        tx_rdy_data <= 8'b0;
    end
    else if (txvld_ok) begin
        tx_rdy_data <= tx_data;
    end
end


// ���ڼ������Ƶ�1302��ʱ������Ѳ���
wire rx_en;
assign rx_en = (rx_cnt == 14'd1301);

// ��tx_vld��Чʱ�����м�����ͨ�������Ĺ��̽����ж�Ҫ������һλ
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

// �����ϱߵļ��������Ӷ�ȷ�����͵������ݵĵڼ�λ
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