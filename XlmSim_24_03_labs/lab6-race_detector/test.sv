module d_ff(q,d,clk,rst);
 output reg q;
 input d,clk,rst;
 
 always@(posedge clk)
         if(!rst)
             q<=1'b0;
         else
             q<=d;
 
 endmodule
 
 module tb;
 wire q;
 reg d,rst;
 reg clk=1'b0;
 d_ff inst(q,d,clk,rst);
 
 initial
     begin
        rst=0;$monitor("%b",q);
     #5
         rst=1;d=0;
     #2
         d=1;
     #10
         $finish;
     end
 always
 #1 clk=~clk;
 endmodule
