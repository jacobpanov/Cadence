// Jacob Panov
// VeriRISC register

module register
#(parameter WIDTH = 8)
 (input wire [WIDTH-1:0] data_in,
  input wire load, clk, rst,
  output reg [WIDTH-1:0] data_out
  );
  
  always @(posedge clk)
  	if (rst) data_out <= 0;
  	else
  	if (load) data_out <= data_in;
  	else
  	data_out <= data_out;
  	
 endmodule
