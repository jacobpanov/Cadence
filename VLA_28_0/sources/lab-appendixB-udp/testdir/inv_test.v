`timescale  1ns /  10ps

module inv_test;

  reg  A ;
  wire Y ;

  inv inv(A, Y);

  task expect(input yx);
    begin
      $display ("time %t: A=%b Y=%b", $time, A, Y);
      if (Y !== yx) begin
          $display ("TEST FAILED");
          $display ("Y should be %b", yx);
          $finish;
        end
    end
  endtask

  initial begin
      $timeformat (-9,0,"",2);
      A = 1'b0; #10 expect (1'b1);
      A = 1'b1; #10 expect (1'b0);
      $display ("TEST PASSED");
      $finish;
    end

endmodule
