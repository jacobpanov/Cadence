`timescale  1ns /  10ps

module dffr_test;

  reg  D  ;
  reg  CK ;
  reg  RN ;
  wire Q  ;

  dffr dffr (D, CK, RN, Q);

  task expect(input qx);
    begin
      $display ("time %t: D=%b RN=%b Q=%b", $time, D, RN, Q);
      if (Q !== qx) begin
          $display ("TEST FAILED");
          $display ("Q should be %b", qx);
          $finish;
        end
    end
  endtask

  initial repeat (4) begin CK=1; #5; CK=0; #5; end

  initial @(negedge CK) begin
      $timeformat (-9,0,"",2);
      D=1'b0; RN=1'b1; @(negedge CK) expect (1'b0);
      D=1'b1; RN=1'b1; @(negedge CK) expect (1'b1);
      D=1'b1; RN=1'b0; @(negedge CK) expect (1'b0);
      $display ("TEST PASSED");
      $finish;
    end

endmodule
