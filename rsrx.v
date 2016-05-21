module rsrx(
    input wire clk,
    input wire rst,
    input wire rx,
    input wire is_tran,

    output wire tx
);

    // ���ȴӴ��ڽ�������
    wire [7:0] serial_data;
    wire rx_vld;
    rx rxdemo(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_vld(rx_vld),
        .rx_data(serial_data)
    );

    // ��װ��ַ�Ϳ�����
	 wire [23:0] package_data;
    assign package_data = {8'b00000001, 8'b00000000, serial_data};

    // �����ݽ���CRCУ��
    wire [39:0] crc_data;
    crccheck crc(
        .clk(clk),
        .rst(rst),
        .data_in(package_data),
        .out_data(crc_data)
    );

    // �����ݽ��в���"0"�����
    wire [47:0] izero_data;
    insertzero izero(
        .clk(clk),
        .rst(rst),
        .data_in(crc_data),
        .out_data(izero_data)
    );



    // ����ʱ������⣬��Ҫ��rx_vld�ź���ʱ2��ʱ��
    reg rxvld, rxvld_tmp, rxvld_ok;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rxvld <= 1'b0;
            rxvld_tmp <= 1'b0;
				rxvld_ok <= 1'b0;
        end
        else begin
            rxvld_tmp <= rx_vld;
            rxvld <= rxvld_tmp;
				rxvld_ok <= rxvld;
        end
    end
	 
	 wire tran_vld;
	 assign tran_vld = rxvld_ok & is_tran;
	 
    // ��װ���ݵ�֡ͷ��֡β
    wire [63:0] result_data;
	 assign result_data = {8'h7E, izero_data, 8'h7E};

    // ���ݴ�ŵ�mem��

    // ��������
    hdlc_senddata sendtx(
        .clk(clk),
        .rst(rst),
        .is_tran(tran_vld),
        .data(result_data),
        .tx(tx)
    );
endmodule