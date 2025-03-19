`timescale  1ns /  10ps

module nd8_test;

  reg  A ;
  reg  B ;
  reg  C ;
  reg  D ;
  reg  E ;
  reg  F ;
  reg  G ;
  reg  H ;
  wire Y ;

  nd8 nd8 (A, B, C, D, E, F, G, H, Y);

  task expect(input yx);
    begin
      $display ("time %t: A=%b B=%b C=%b D=%b E=%b F=%b G=%b H=%b Y=%b",
                $time, A, B, C, D, E, F, G, H, Y);
      if (Y !== yx) begin
          $display ("TEST FAILED");
          $display ("Y should be %b", yx);
          $finish;
        end
    end
  endtask

  initial begin
      $timeformat (-9,0,"",2);
A=1'b1; B=1'b1; C=1'b1; D=1'b1; E=1'b1; F=1'b1; G=1'b1; H=1'b1;#10 expect(1'b0);
A=1'b0; B=1'b1; C=1'b1; D=1'b1; E=1'b1; F=1'b1; G=1'b1; H=1'b1;#10 expect(1'b1);
A=1'b1; B=1'b0; C=1'b1; D=1'b1; E=1'b1; F=1'b1; G=1'b1; H=1'b1;#10 expect(1'b1);
A=1'b1; B=1'b1; C=1'b0; D=1'b1; E=1'b1; F=1'b1; G=1'b1; H=1'b1;#10 expect(1'b1);
A=1'b1; B=1'b1; C=1'b1; D=1'b0; E=1'b1; F=1'b1; G=1'b1; H=1'b1;#10 expect(1'b1);
A=1'b1; B=1'b1; C=1'b1; D=1'b1; E=1'b0; F=1'b1; G=1'b1; H=1'b1;#10 expect(1'b1);
A=1'b1; B=1'b1; C=1'b1; D=1'b1; E=1'b1; F=1'b0; G=1'b1; H=1'b1;#10 expect(1'b1);
A=1'b1; B=1'b1; C=1'b1; D=1'b1; E=1'b1; F=1'b1; G=1'b0; H=1'b1;#10 expect(1'b1);
A=1'b1; B=1'b1; C=1'b1; D=1'b1; E=1'b1; F=1'b1; G=1'b1; H=1'b0;#10 expect(1'b1);
      $display ("TEST PASSED");
      $finish;
    end

endmodule
