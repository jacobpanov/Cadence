`timescale  1ns /  10ps

module oa211_test;

  reg  A ;
  reg  B ;
  reg  C ;
  reg  D ;
  wire Y ;

  oa211 oa211 (A, B, C, D, Y);

  task expect(input yx);
    begin
      $display ("time %t: A=%b B=%b C=%b D=%b Y=%b", $time, A, B, C, D, Y);
      if (Y !== yx) begin
          $display ("TEST FAILED");
          $display ("Y should be %b", yx);
          $finish;
        end
    end
  endtask

  initial begin
      $timeformat (-9,0,"",2);
      A = 1'b1; B = 1'b0; C = 1'b1; D = 1'b1; #10 expect (1'b0);
      A = 1'b0; B = 1'b1; C = 1'b1; D = 1'b1; #10 expect (1'b0);
      A = 1'b0; B = 1'b0; C = 1'b1; D = 1'b1; #10 expect (1'b1);
      A = 1'b1; B = 1'b1; C = 1'b0; D = 1'b1; #10 expect (1'b1);
      A = 1'b1; B = 1'b1; C = 1'b1; D = 1'b0; #10 expect (1'b1);
      $display ("TEST PASSED");
      $finish;
    end

endmodule
