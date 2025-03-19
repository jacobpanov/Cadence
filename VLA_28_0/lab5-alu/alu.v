// Jacob Panov
// VeriRISC alu

module alu
#(parameter WIDTH = 8)
 (input wire [WIDTH-1:0] in_a, in_b,
  input wire [2:0			 ] opcode,
  output reg [WIDTH-1:0] alu_out,
  output reg             a_is_zero
 );
 
 always @*
 		begin
 			a_is_zero = (in_a == 0); // Default
 			if (opcode == 2) alu_out = in_a + in_b; // ADD
 			else
 			if (opcode == 3) alu_out = in_a & in_b; // AND
 			else
 			if (opcode == 4) alu_out = in_a ^ in_b; // XOR
 			else
 			if (opcode == 5) alu_out = in_b; // LDA
 			else
 			alu_out = in_a; // HLT, SKZ, STO, JMP
 			
 		end
 		
 endmodule
