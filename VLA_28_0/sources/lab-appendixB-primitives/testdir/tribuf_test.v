`timescale  1ns /  10ps

module tribuf_test;

  reg  A ;
  reg  E ;
  wire Y ;

  tribuf tribuf (A, E, Y);

  task expect(input yx);
    begin
      $display ("time %t: A=%b E=%b Y=%b", $time, A, E, Y);
      if (Y !== yx) begin
          $display ("TEST FAILED");
          $display ("Y should be %b", yx);
          $finish;
        end
    end
  endtask

  initial begin
      $timeformat (-9,0,"",2);
      A = 1'b0; E = 1'b0; #10 expect (1'bz);
      A = 1'b0; E = 1'b1; #10 expect (1'b0);
      A = 1'b1; E = 1'b0; #10 expect (1'bz);
      A = 1'b1; E = 1'b1; #10 expect (1'b1);
      $display ("TEST PASSED");
      $finish;
    end

endmodule
