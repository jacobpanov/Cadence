
module dut(
a,
b,
sel,
q
);

input a;
input b;
input sel;
output q;

wire   a;
wire   b;
wire   sel;
reg   q;



  always @(sel or a or b) begin
    if((sel == 1'b 1)) begin
      q <= a;
    end
    else begin
      q <= b;
    end
  end


endmodule
