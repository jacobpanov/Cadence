`timescale  1ns /  10ps

module dff_neg_test;

  reg  D   ;
  reg  CKN ;
  wire Q   ;

  dff_neg dff_neg (D, CKN, Q);

  task expect(input qx);
    begin
      $display ("time %t: D=%b Q=%b", $time, D, Q);
      if (Q !== qx) begin
          $display ("TEST FAILED");
          $display ("Q should be %b", qx);
          $finish;
        end
    end
  endtask

  initial repeat (3) begin CKN=0; #5; CKN=1; #5; end

  initial @(posedge CKN) begin
      $timeformat (-9,0,"",2);
      D=1'b0; @(posedge CKN) expect (1'b0);
      D=1'b1; @(posedge CKN) expect (1'b1);
      $display ("TEST PASSED");
      $finish;
    end

endmodule
