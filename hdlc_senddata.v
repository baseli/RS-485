module hdlc_senddata(
    input wire clk,
    input wire rst,
    input wire is_tran,
    input wire [63:0]data,
    output reg tx
);

    // 这里使用的时钟是9600Hz的时钟
    integer i;
    reg [13:0] clk_cnt;
    reg tran_vld;
     
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            tran_vld <= 1'b0;
        end
        else if (data == 64'h7E0001000037307E) begin
            tran_vld <= 1'b0;
        end
        else begin
            tran_vld <= 1'b1;
        end
    end

//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
//            clk_cnt <= 14'b0;
//        end
//        else if (clk_cnt == 14'd2603) begin
//            clk_cnt <= 14'b0;
//        end
//        else if (tran_vld) begin
//            clk_cnt <= clk_cnt + 1'b1;
//        end
//    end
//
//    // 确定采样时间
//    wire tx_en;
//    assign  tx_en= (clk_cnt == 14'd1301);
     
    reg [6:0] send_cnt;
    reg [63:0] tmp;
	 reg flag;
	 
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            send_cnt <= 7'b0;
        end
        else if (send_cnt == 7'd65) begin
            send_cnt <= 7'b0;
        end
        else if (flag) begin
            send_cnt = send_cnt + 1'b1;
        end
    end

    // 这里检测is_tran的值，如果为1，把data给tmp
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tmp <= 64'hffffffffffffffff;
				flag <= 1'b0;
        end
        else if (is_tran) begin
            tmp <= data;
				flag <= 1'b1;
        end
        else if (send_cnt == 7'd65) begin
            tmp <= 64'h7E0001000037307E;
				flag <= 1'b0;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            tx <= 1'b1;
        end
        else begin
            if (flag) begin
                case(send_cnt)
                    7'd64: tx <= tmp[0];
                    7'd63: tx <= tmp[1];
                    7'd62: tx <= tmp[2];
                    7'd61: tx <= tmp[3];
                    7'd60: tx <= tmp[4];
                    7'd59: tx <= tmp[5];
                    7'd58: tx <= tmp[6];
                    7'd57: tx <= tmp[7];
                    7'd56: tx <= tmp[8];
                    7'd55: tx <= tmp[9];
                    7'd54: tx <= tmp[10];
                    7'd53: tx <= tmp[11];
                    7'd52: tx <= tmp[12];
                    7'd51: tx <= tmp[13];
                    7'd50: tx <= tmp[14];
                    7'd49: tx <= tmp[15];
                    7'd48: tx <= tmp[16];
                    7'd47: tx <= tmp[17];
                    7'd46: tx <= tmp[18];
                    7'd45: tx <= tmp[19];
                    7'd44: tx <= tmp[20];
                    7'd43: tx <= tmp[21];
                    7'd42: tx <= tmp[22];
                    7'd41: tx <= tmp[23];
                    7'd40: tx <= tmp[24];
                    7'd39: tx <= tmp[25];
                    7'd38: tx <= tmp[26];
                    7'd37: tx <= tmp[27];
                    7'd36: tx <= tmp[28];
                    7'd35: tx <= tmp[29];
                    7'd34: tx <= tmp[30];
                    7'd33: tx <= tmp[31];
                    7'd32: tx <= tmp[32];
                    7'd31: tx <= tmp[33];
                    7'd30: tx <= tmp[34];
                    7'd29: tx <= tmp[35];
                    7'd28: tx <= tmp[36];
                    7'd27: tx <= tmp[37];
                    7'd26: tx <= tmp[38];
                    7'd25: tx <= tmp[39];
                    7'd24: tx <= tmp[40];
                    7'd23: tx <= tmp[41];
                    7'd22: tx <= tmp[42];
                    7'd21: tx <= tmp[43];
                    7'd20: tx <= tmp[44];
                    7'd19: tx <= tmp[45];
                    7'd18: tx <= tmp[46];
                    7'd17: tx <= tmp[47];
                    7'd16: tx <= tmp[48];
                    7'd15: tx <= tmp[49];
                    7'd14: tx <= tmp[50];
                    7'd13: tx <= tmp[51];
                    7'd12: tx <= tmp[52];
                    7'd11: tx <= tmp[53];
                    7'd10: tx <= tmp[54];
                    7'd9: tx <= tmp[55];
                    7'd8: tx <= tmp[56];
                    7'd7: tx <= tmp[57];
                    7'd6: tx <= tmp[58];
                    7'd5: tx <= tmp[59];
                    7'd4: tx <= tmp[60];
                    7'd3: tx <= tmp[61];
                    7'd2: tx <= tmp[62];
                    7'd1: tx <= tmp[63];
                    7'd0: tx <= 1'b1;
                    default: tx <= 1'b1;
                endcase
            end
        end
    end

endmodule