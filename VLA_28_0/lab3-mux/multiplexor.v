// Jacob Panov
// VeriRISC multiplexor

module multiplexor
#(parameter integer WIDTH = 5)
 (input wire [WIDTH-1:0] in0, in1,
  input wire						 sel,
  output reg [WIDTH-1:0] mux_out
  );
  
  always @*
  	if (sel)
  		mux_out = in1;
  	else
  		mux_out = in0;
  		
 endmodule
	 
