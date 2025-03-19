`timescale  1ns /  10ps

module or2_test;

  reg  A ;
  reg  B ;
  wire Y ;

  or2 or2 (A, B, Y);

  task expect(input yx);
    begin
      $display ("time %t: A=%b B=%b Y=%b", $time, A, B, Y);
      if (Y !== yx) begin
          $display ("TEST FAILED");
          $display ("Y should be %b", yx);
          $finish;
        end
    end
  endtask

  initial begin
      $timeformat (-9,0,"",2);
      A = 1'b0; B = 1'b0; #10 expect (1'b0);
      A = 1'b1; B = 1'b0; #10 expect (1'b1);
      A = 1'b0; B = 1'b1; #10 expect (1'b1);
      $display ("TEST PASSED");
      $finish;
    end

endmodule
