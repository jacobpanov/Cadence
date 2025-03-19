// Jacob Panov
// VeriRISC controller

module controller
(input wire zero,
 input wire [2:0] opcode, phase,
 output reg sel, rd, ld_ir, halt, inc_pc, ld_ac, wr, ld_pc, data_e
 );
 
 always @* begin
 		case (phase)
 			0: begin 
 				sel=1;
 				rd=0;
 				ld_ir=0;
 				halt=0;
 				inc_pc=0;
 				ld_ac=0;
 				ld_pc=0;
 				wr=0;
 				data_e=0;
 			end
 			1: begin 
 				sel=1;
 				rd=1;
 				ld_ir=0;
 				halt=0;
 				inc_pc=0;
 				ld_ac=0;
 				ld_pc=0;
 				wr=0;
 				data_e=0;
 			end
 			2: begin 
 				sel=1;
 				rd=1;
 				ld_ir=1;
 				halt=0;
 				inc_pc=0;
 				ld_ac=0;
 				ld_pc=0;
 				wr=0;
 				data_e=0;
 			end
 			3: begin 
 				sel=1;
 				rd=1;
 				ld_ir=1;
 				halt=0;
 				inc_pc=0;
 				ld_ac=0;
 				ld_pc=0;
 				wr=0;
 				data_e=0;
 			end
 			4: begin 
 				sel=0;
 				rd=0;
 				ld_ir=0;
 				halt= (opcode == 0);
 				inc_pc=1;
 				ld_ac=0;
 				ld_pc=0;
 				wr=0;
 				data_e=0;
 			end
 			5: begin 
 				sel=0;
 				rd= (opcode == 2 || opcode == 3 || opcode == 4 || opcode == 5);
 				ld_ir=0;
 				halt=0;
 				inc_pc=0;
 				ld_ac=0;
 				ld_pc=0;
 				wr=0;
 				data_e=0;
 			end
 			6: begin 
 				sel=0;
 				rd= (opcode == 2 || opcode == 3 || opcode == 4 || opcode == 5);
 				ld_ir=0;
 				halt=0;
 				inc_pc= (opcode == 1 && zero);
 				ld_ac=0;
 				ld_pc= (opcode == 7);
 				wr=0;
 				data_e= (opcode == 6);
 			end
 			7: begin 
 				sel=0;
 				rd= (opcode == 2 || opcode == 3 || opcode == 4 || opcode == 5);
 				ld_ir=0;
 				halt=0;
 				inc_pc=0;
 				ld_ac= (opcode == 2 || opcode == 3 || opcode == 4 || opcode == 5);
 				ld_pc= (opcode == 7);
 				wr= (opcode == 6);
 				data_e= (opcode == 6);
 			end
 		endcase
 	end
 	
 endmodule
 			
