`timescale 1ns/1ps;

module hdlc_recivedata_tb();

    reg clk, rst, rx;
    wire is_recive;
    wire [63:0] out_data;

    task rx_send;
    input [63:0] b;
    integer i;
    begin
        rx = 1'b0;
        for (i = 63; i >= 0; i = i-1) begin
            #100 rx = b[i];
        end
        #100 rx = 1;
    end
    endtask

    hdlc_recivedata hdlc_recivedata_tb(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .is_recive(is_recive),
        .out_data(out_data)
    );

    initial begin
        clk = 0;
        rst = 1;
        rx = 1;
        #100;
        rst = 0;
        rx_send(64'h7E0100101100107E);
	#1000;
	rx_send(64'h7E0100110100107E);
    end

    always #50 clk = ~clk;

endmodule