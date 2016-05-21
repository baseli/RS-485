module hdlc_recivedata(
    input wire clk,
    input wire rst,
    input wire rx,
    input wire is_send,

    output reg [63:0] out_data,
    output reg is_recive
);

    reg rx_d1;
    reg rx_d2;
    reg rx_d3;
    reg rx_d4;
    reg rx_d5;
    reg rx_d6;
    reg rx_d7;
    reg rx_d8;

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            rx_d1 <= 1'b0;
        end
        else begin
            rx_d1 <= rx;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            rx_d2 <= 1'b0;
        end
        else begin
            rx_d2 <= rx_d1;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            rx_d3 <= 1'b0;
        end
        else begin
            rx_d3 <= rx_d2;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            rx_d4 <= 1'b0;
        end
        else begin
            rx_d4 <= rx_d3;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            rx_d5 <= 1'b0;
        end
        else begin
            rx_d5 <= rx_d4;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            rx_d6 <= 1'b0;
        end
        else begin
            rx_d6 <= rx_d5;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            rx_d7 <= 1'b0;
        end
        else begin
            rx_d7 <= rx_d6;
        end
    end    

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            rx_d8 <= 1'b0;
        end
        else begin
            rx_d8 <= rx_d7;
        end
    end

    reg [2:0] state, next_state;
    parameter s_count = 3'd0;
    parameter s0 = 3'd1;
    parameter s1 = 3'd2;
    parameter s2 = 3'd3;
    parameter s3 = 3'd4;
    parameter s4 = 3'd5;
    parameter s5 = 3'd6;
    parameter s6 = 3'd7;    

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            state <= s_count;
        end
        else begin
            state <= next_state;
        end
    end

    always @ (state or rx) begin
        case(state)
            s_count: begin
                if(rx == 1'b0) begin
                    next_state = s0;
                end
                else begin
                    next_state = s_count;
                end
            end
            s0: begin
                if (rx == 1'b1) begin
                    next_state = s1;
                end
                else begin
                    next_state = s0;
                end
            end

            s1: begin
                if (rx == 1'b1) begin
                    next_state = s2;
                end
                else begin
                    next_state = s0;
                end
            end

            s2: begin
                if (rx == 1'b1) begin
                    next_state = s3;
                end
                else begin
                    next_state = s0;
                end
            end

            s3: begin
                if (rx == 1'b1) begin
                    next_state = s4;
                end
                else begin
                    next_state = s0;
                end
            end

            s4: begin
                if (rx == 1'b1) begin
                    next_state = s5;
                end
                else begin
                    next_state = s0;
                end
            end

            s5: begin
                if (rx == 1'b1) begin
                    next_state = s6;
                end
                else begin
                    next_state = s0;
                end
            end

            s6: begin
                next_state = s_count;
            end
        endcase
    end

    reg receive;
    always @ (state or rx) begin
        if (state == s6 && rx == 1'b0) begin
            receive <= 1'b1;
        end
        else begin
            receive <= 1'b0;
        end
    end

    reg [55:0]data;
    reg [6:0]count;
    reg [1:0]flag;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            flag <= 2'b0;
        end
        else if (flag == 2'd2) begin
            flag <= 2'b0;
        end
        else if (receive) begin
            flag <= flag + 1'b1;
        end
        else if (count == 7'd55) begin
            flag <= 2'b0;
		  end
    end

    reg is_finish_recive;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 7'b0;
            is_recive = 1'b0;
            is_finish_recive = 1'b0;
        end
        else if (count == 7'd55) begin
            count <= 7'b0;
            is_recive = 1'b0;
            is_finish_recive = 1'b1;
        end
        else if (flag == 2'd1) begin
            is_recive = 1'b1;
            is_finish_recive = 1'b0;
            count <= count + 1'b1;
        end
        else if (flag == 2'b0) begin
            is_finish_recive = 1'b0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data <= 56'b0;
        end
        else if (flag[0]) begin
            data <= {data, rx};
        end
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            out_data <= 64'b0;
        end
        else if (is_finish_recive & (count == 7'd0)) begin
            out_data <= {8'h7E, data};
        end
    end
endmodule