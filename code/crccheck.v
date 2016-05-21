`timescale 1ns/1ps

module crccheck(
    // input
    input wire clk,
    input wire rst,
    input wire [23:0] data_in,
    // output
    output reg [39:0] out_data
);

integer i;
reg feedback;
reg [15:0] checkout;

always @(posedge clk or posedge rst) begin
    if (rst) begin
            out_data <= 56'd0;        
    end
    else begin
            out_data <= {data_in, checkout};
    end
end

always @(data_in) begin
    checkout = 16'h0000;
    for(i = 23; i >= 0; i = i-1) begin
        feedback    = checkout[15] ^ data_in[i];
        checkout[15]  = checkout[14];
        checkout[14]  = checkout[13];
        checkout[13]  = checkout[12];
        checkout[12]  = checkout[11] ^ feedback;
        checkout[11]  = checkout[10] ;
        checkout[10]  = checkout[9];
        checkout[9]   = checkout[8];
        checkout[8]   = checkout[7];
        checkout[7]   = checkout[6];
        checkout[6]   = checkout[5];
        checkout[5]   = checkout[4] ^ feedback;
        checkout[4]   = checkout[3];
        checkout[3]   = checkout[2];
        checkout[2]   = checkout[1];
        checkout[1]   = checkout[0];
        checkout[0]   = feedback;
    end
end

endmodule