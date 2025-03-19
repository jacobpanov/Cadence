// Jacob Panov
// VeriRISC counter

module counter
#(parameter integer WIDTH = 5)
 (input wire [WIDTH-1:0] cnt_in,
 	input wire enab, load, clk, rst,
 	output reg [WIDTH-1:0] cnt_out
 );
 
 reg [WIDTH-1:0] cnt_temp;
 
 always @*
 		if (rst) cnt_temp = 0;
 		else
 		if (load) cnt_temp = cnt_in;
 		else 
 		if (enab) cnt_temp = cnt_out + 1;
 		else
 		cnt_temp = cnt_out;
 		
 always @(posedge clk)
 		cnt_out <= cnt_temp;
 		
endmodule
