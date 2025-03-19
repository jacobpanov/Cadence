// Jacob Panov
// VeriRISC memory

module memory
#(parameter AWIDTH = 5,
	parameter DWIDTH = 8)
 (input wire [AWIDTH-1:0] addr,
  input wire clk, wr, rd,
  output wire [DWIDTH-1:0] data
 );
 
 reg [DWIDTH-1:0] array [0:2**AWIDTH-1]; // defining width and depth of memory
 
 always @(posedge clk)
 		if (wr) array[addr] = data;
 assign data = rd ? array[addr] : 'bz; 
 
endmodule		
