`timescale 1ns/1ps

module hdlc_senddata_tb();

    reg clk, rst, is_tran;
    reg [63:0] data;

    wire tx;

    hdlc_senddata hdlc_senddata_tb(
        .clk(clk),
        .rst(rst),
        .is_tran(is_tran),
        .data(data),
        .tx(tx)
    );

    initial begin
        clk = 0;
        rst = 1;
        is_tran = 0;
        data = 64'b0;
        #100;
        rst = 0;
        is_tran = 1;
        data = 64'h7E0001001110107E;
    end

    always #20 clk = ~clk;

endmodule