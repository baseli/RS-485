module rstx(
    input wire clk,
    input wire rst,
    input wire rx,
    input wire is_send,

    output tx,
    output data_error,
    output crc_error
);

    // 由于在hdlc串行发送数据的时候使用的是9600的比特率
    // 所以这里需要进行分频，使用9600Hz的时钟去接收数据
//    wire clk9600;
//    divclk divclk(
//        .clk25(clk),
//        .rst(rst),
//        .clk(clk9600)
//    );


    // hdlc串行接收数据
    wire is_recive;
    wire [63:0] result_data;
    hdlc_recivedata receive(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .is_send(is_send),
        .out_data(result_data),
        .is_recive(is_recive)
    );

    assign data_error = ~(result_data[7:0] == 8'h7E);

    // 提取数据中的有用部分，然后进行删除"0"码操作
    wire [47:0] izero_data;
    wire [39:0] dzero_data;

    assign izero_data = result_data[55:8];

    deletezero dzero(
        .clk(clk),
        .rst(rst),
        .data_in(izero_data),
        .out_data(dzero_data)
    );

    // 提取删除"0"码后的数据的高24位，然后进行CRC校验
    wire [23:0] crc_data;
    wire [39:0] crc_result;
    assign crc_data = dzero_data[39:16];
    crccheck crc(
        .clk(clk),
        .rst(rst),
        .data_in(crc_data),
        .out_data(crc_result)
    );

    assign crc_error = ~(crc_result == dzero_data);

    // 判断地址是否是当前基站的地址
    wire is_addr;
    assign is_addr = (crc_result[39:32] == 8'h01);
	 
    // 获取到要传输的数据
    wire [7:0] data;
    assign data = crc_data[7:0];

    // 传输标志
    wire tran_vld;
    assign tran_vld = is_addr & ~(crc_error | data_error);

    wire txrdy, is_busy;

    tx txdemo(
        .clk(clk),
        .rst(rst),
        .tx_vld(tran_vld),
        .tx_data(data),
        .tx(tx),
        .txrdy(txrdy),
        .is_busy(is_busy)
    );

endmodule