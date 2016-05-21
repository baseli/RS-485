`timescale 1ns/1ps

module deletezero(
    // input
    input wire clk,
    input wire rst,
    input wire [47:0]data_in,
    // output
    output reg [39:0]out_data
);

integer i;
reg [2:0]flag;
reg [39:0]data;


always @(posedge clk or posedge rst) begin
    if (rst) begin
        // reset
        out_data <= 40'd0;
    end
    else begin
        out_data <= data;
    end
end

always @(data_in) begin
    data = 40'd0;
    flag = 3'd0;
     
    for(i = 47; i >= 0; i = i-1) begin
        if (data_in[i] == 1) begin
            flag = flag + 1'b1;
            data = {data, data_in[i]};
        end
        else begin
            if (flag == 3'd5) begin
                flag = 3'd0;
            end
            else begin
                flag = 3'd0;
                data = {data, data_in[i]};
            end
        end
    end
end

endmodule