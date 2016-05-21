module divclk(
    input wire clk25,
    input wire rst,

    output reg clk
);

    reg [13:0] cnt;

    always @(posedge clk25 or posedge rst) begin
        if (rst) begin
            cnt <= 14'b0;
        end
        else if (cnt == 14'd1302) begin
            cnt <= 14'b0;
        end
        else begin
            cnt <= cnt + 1'b1;
        end
    end

    wire en;
    assign en = (cnt == 14'd651);

    always @(posedge clk25 or posedge rst) begin
        if (rst) begin
            clk <= 1'b0;
        end
        else if (en) begin
            clk <= ~clk;
        end
    end

endmodule