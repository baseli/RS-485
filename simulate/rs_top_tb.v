`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:44:46 05/20/2016
// Design Name:   rs_top
// Module Name:   F:/bishe/ise/fuck_rs/rs_top_tb.v
// Project Name:  fuck_rs
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: rs_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module rs_top_tb;

	// Inputs
	reg clk50;
	reg rst;
	reg rx;

	// Outputs
	wire tx;
	wire data_error;
	wire crc_error;

	// Instantiate the Unit Under Test (UUT)
	rs_top uut (
		.clk50(clk50), 
		.rst(rst), 
		.rx(rx), 
		.tx(tx), 
		.data_error(data_error), 
		.crc_error(crc_error)
	);

	task rx_send;
		input [7:0] b;
		integer i;
		begin
			rx = 1'b0;
			for (i = 0; i < 8; i = i+1) begin
				 #104167 rx = b[i];
			end
			#104167 rx = ^b;
			#104167 rx = 1'b1;
			#104167 rx = 1'b1;
		end
	endtask

	initial begin
		// Initialize Inputs
		clk50 = 0;
		rst = 1;
		rx = 0;

		// Wait 100 ns for global reset to finish
		#100;
			
		// Add stimulus here
		rst = 0;
		rx_send(8'ha5);
		#1000000;
		rx_send(8'h5a);
	end
   always #10 clk50 = ~clk50;   
endmodule

