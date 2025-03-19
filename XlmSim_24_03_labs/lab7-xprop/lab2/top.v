module top();

  reg clk, rst, d;
  reg q;
  dut dut(rst, clk, d, q);

  initial begin
    #10 rst = 1'b0;
    #10 rst = 1'b0; clk = 1'b0; d = 1'b1;
    #10 rst = 1'b1; clk = 1'bx;
    #10 rst = 1'b1; clk = 1'b0;
    #10 rst = 1'b1; clk = 1'b1;
    #10 rst = 1'b1; clk = 1'b0;
    #10 rst = 1'b0; clk = 1'bx;
    #10 rst = 1'b1; clk = 1'b0;
    #10 rst = 1'b1; clk = 1'b1;
    #10 rst = 1'b1; clk = 1'b0; d = 1'b0;
    #10 rst = 1'b1; clk = 1'b1;
    #10 rst = 1'bx; clk = 1'b1;
    #10 rst = 1'b0; clk = 1'b1;
    #10 rst = 1'b1; clk = 1'b0; d = 1'b1;
    #10 rst = 1'bx; clk = 1'b1;
    #10 rst = 1'b0; clk = 1'b1;
    #10 $finish;

  end

  initial
    $monitor($time, " :: rst = %b, clk = %b, d = %b, q = %b", rst, clk, d, q);
endmodule
