`timescale 1ns/1ps

module insertzero_tb();
// input
reg clk, rst;
reg [39:0]data_in;
// output
wire [47:0]out_data;

insertzero insertzerotb(
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .out_data(out_data)
);

initial begin
    clk = 0;
    rst = 1;
    data_in = 0;
    #100;
    rst = 0;
    data_in = 40'hFFFFFFFFFF;
    #100;
    data_in = 40'hFA4A52A53F;
end

always #50 clk = ~clk;

endmodule