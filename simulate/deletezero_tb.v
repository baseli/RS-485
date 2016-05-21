`timescale 1ns/1ps

module deletezero_tb();
// input
reg clk, rst;
reg [47:0]data_in;
// output
wire [39:0]out_data;

deletezero deletezero_tb(
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
    data_in = 48'hfbefbefbefbe;
    #100;
    data_in = 48'h03e494a54a7d;
end

always #50 clk = ~clk;

endmodule