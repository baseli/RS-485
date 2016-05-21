module rs_top(
    input wire clk50,
    input wire rst,
    input wire rx,

    output tx,
    output data_error,
    output crc_error
);
    wire clk;

    clkdiv clk25(
        .clk50(clk50),
        .rst(rst),
        .clk(clk)
    );

    wire is_tran;
    wire hdlcrx;
    assign is_tran = 1'b1;

    rsrx rxdemo (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .is_tran(is_tran),
        .tx(hdlcrx)
    );

    wire is_send;
    assign is_send = 1'b0;

    rstx txdemo(
        .clk(clk),
        .rst(rst),
        .rx(hdlcrx),
        .is_send(is_send),
        .tx(tx),
        .data_error(data_error),
        .crc_error(crc_error)
    );

endmodule