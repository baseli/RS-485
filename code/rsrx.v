module rsrx(
    input wire clk,
    input wire rst,
    input wire rx,
    input wire is_tran,

    output wire tx
);

    // 首先从串口接收数据
    wire [7:0] serial_data;
    wire rx_vld;
    rx rxdemo(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_vld(rx_vld),
        .rx_data(serial_data)
    );

    // 封装地址和控制码
	 wire [23:0] package_data;
    assign package_data = {8'b00000001, 8'b00000000, serial_data};

    // 对数据进行CRC校验
    wire [39:0] crc_data;
    crccheck crc(
        .clk(clk),
        .rst(rst),
        .data_in(package_data),
        .out_data(crc_data)
    );

    // 对数据进行插入"0"码操作
    wire [47:0] izero_data;
    insertzero izero(
        .clk(clk),
        .rst(rst),
        .data_in(crc_data),
        .out_data(izero_data)
    );



    // 由于时序的问题，需要对rx_vld信号延时2个时钟
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
	 
    // 封装数据的帧头和帧尾
    wire [63:0] result_data;
	 assign result_data = {8'h7E, izero_data, 8'h7E};

    // 数据存放到mem中

    // 发送数据
    hdlc_senddata sendtx(
        .clk(clk),
        .rst(rst),
        .is_tran(tran_vld),
        .data(result_data),
        .tx(tx)
    );
endmodule