`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:36:36 05/05/2016 
// Design Name: 
// Module Name:    clkdiv 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clkdiv(
	input wire clk50,
	input wire rst,
	output reg clk
    );


	always @ (posedge clk50 or posedge rst) begin
		if (rst) begin
			clk <= 1'b0;
		end
		else begin
			clk <= ~clk;
		end
	end

endmodule
