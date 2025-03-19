module top (input clk,input in0,output reg out0);
reg temp1;
always @(posedge clk)
temp1=in0;
always @(posedge clk)
out0<=temp1;
endmodule 

module tb();
reg d,g;
reg clk=1'b0;
always #5 clk=~clk;
initial begin
#5 d=1'b1;
#15 $finish;
end
top t(clk,d,q);
endmodule
