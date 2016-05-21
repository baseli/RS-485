module rx(
    input wire clk,
    input wire rst,
    input wire rx,

    output reg rx_vld,
    output reg [7:0] rx_data
);

// Ϊ�������첽���͵Ĳ�ȷ����
reg rx1, rx2, rx3, rxx;
always @ (posedge clk) begin
    rx1 <= rx;
    rx2 <= rx1;
    rx3 <= rx2;
    rxx <= rx3;
end

// ���rxx�Ƿ����˱仯
reg rx_dly;
always @ (posedge clk)
    rx_dly <= rxx;

wire rx_change;
assign rx_change = (rxx != rx_dly);


// �������ﴮ��ͨ��ʱѡ���Ƶ����9600Hz������ʹ��2604Ϊ��������
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

// ���ڼ������Ƶ�1302��ʱ������Ѳ���
wire rx_en;
assign rx_en = (rx_cnt == 14'd1301);

// �����rx_en����1��ʱ�򣬼�⵽��rxx����0����֪��Ҫ��ʼ����������
// ������͹���������Ӧ����10bit�ģ�8bit�����ݣ�1bit����żУ�飬1bit��ֹͣλ
// ���Ծ���Ҫһ���µļ��������������������ֽ����ݵĽ���

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

// ǰ���Ѿ���ʼ�������ݵ�ʱ��������ݲ����������￪ʼ�������ݣ�����rxx�����ݣ���������λ���
reg [7:0] rx_data_tmp;
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        rx_data_tmp <= 8'b0;
    end
    else if (data_vld & rx_en & ~data_cnt[3]) begin
        rx_data_tmp <= {rxx, rx_data_tmp[7:1]};
    end
end

// ������ݽ�����ϣ�����rx_vld��Ч
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        rx_vld <= 1'b0;
    end
    else begin
        rx_vld <= data_vld & rx_en & (data_cnt == 4'h9);
    end
end

// �жϲ����rx_data
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        rx_data <= 8'b0;
    end
    else if (rx_vld) begin
        rx_data <= rx_data_tmp;
    end
end

endmodule