`timescale 1ns/1ps

module insertzero(
    input wire clk,
    input wire rst,
    input wire [39:0]data_in,

    output reg [47:0]out_data
);

integer i;
reg [2:0]flag;
reg [47:0]data;

always @(posedge clk or posedge rst)
begin
    if (rst) begin
        // reset
        out_data <= 48'd0;
    end
    else begin
        out_data <= data;
    end
end

always @(data_in) begin
    flag = 3'd0;
    data = 48'd0;
    for(i = 39; i >= 0; i = i-1) begin
        if (data_in[i] == 1) begin
            flag = flag + 1;
            if (flag == 3'd5) begin
                data = {data, 2'b10};
                flag = 3'd0;
            end
            else begin
                data = {data, data_in[i]};
            end
        end
        else begin
            flag = 3'd0;
            data = {data, data_in[i]};
        end
    end
end

endmodule
