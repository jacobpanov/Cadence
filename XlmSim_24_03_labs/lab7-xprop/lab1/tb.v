
module tb();
reg a, b, sel;
wire q;

dut dut_inst(.a(a),.b(b),.sel(sel),.q(q));

initial begin
#10 a<=1'b0 ; b<=1'b0; sel<=1'b0;
#10 a<=1'b0 ; b<=1'b1; sel<=1'b0;
#10 a<=1'b1 ; b<=1'b0; sel<=1'b0;
#10 a<=1'b0 ; b<=1'b1; sel<=1'b0;
#10 a<=1'b0 ; b<=1'b0; sel<=1'b1;
#10 a<=1'b0 ; b<=1'b1; sel<=1'b1;
#10 a<=1'b1 ; b<=1'b0; sel<=1'b1;
#10 a<=1'b1 ; b<=1'b1; sel<=1'b1;
#10 a<=1'b0 ; b<=1'b0; sel<=1'bx;
#10 a<=1'b0 ; b<=1'b1; sel<=1'bx;
#10 a<=1'b1 ; b<=1'b1; sel<=1'bx;
#10 a<=1'b1 ; b<=1'b0; sel<=1'bx;
#10 a<=1'b0 ; b<=1'b0; sel<=1'b0;
#10 $finish;

end

endmodule

