`timescale  1ns /  10ps

module dffs_test;

  reg  D  ;
  reg  CK ;
  reg  SN ;
  wire Q  ;
  wire QN ;

  dffs dffs (D, CK, SN, Q, QN);

  task expect(input qx, qnx);
    begin
      $display ("time %t: D=%b SN=%b Q=%b QN=%b", $time, D, SN, Q, QN);
      if (Q !== qx || QN !== qnx) begin
          $display ("TEST FAILED");
          $display ("Q should be %b, QN should be %b", qx, qnx);
          $finish;
        end
    end
  endtask

  initial repeat (4) begin CK=1; #5; CK=0; #5; end

  initial @(negedge CK) begin
      $timeformat (-9,0,"",2);
      D=1'b1; SN=1'b1; @(negedge CK) expect (1'b1, 1'b0);
      D=1'b0; SN=1'b1; @(negedge CK) expect (1'b0, 1'b1);
      D=1'b1; SN=1'b0; @(negedge CK) expect (1'b1, 1'b0);
      $display ("TEST PASSED");
      $finish;
    end

endmodule
