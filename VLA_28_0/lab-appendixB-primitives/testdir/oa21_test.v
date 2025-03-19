`timescale  1ns /  10ps

module oa21_test;

  reg  A ;
  reg  B ;
  reg  C ;
  wire Y ;

  oa21 oa21 (A, B, C, Y);

  task expect(input yx);
    begin
      $display ("time %t: A=%b B=%b C=%b Y=%b", $time, A, B, C, Y);
      if (Y !== yx) begin
          $display ("TEST FAILED");
          $display ("Y should be %b", yx);
          $finish;
        end
    end
  endtask

  initial begin
      $timeformat (-9,0,"",2);
      A = 1'b1; B = 1'b0; C = 1'b1; #10 expect (1'b0);
      A = 1'b0; B = 1'b1; C = 1'b1; #10 expect (1'b0);
      A = 1'b0; B = 1'b0; C = 1'b1; #10 expect (1'b1);
      A = 1'b1; B = 1'b1; C = 1'b0; #10 expect (1'b1);
      $display ("TEST PASSED");
      $finish;
    end

endmodule
