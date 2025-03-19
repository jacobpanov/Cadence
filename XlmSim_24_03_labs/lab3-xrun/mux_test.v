module mux_test;

  wire y  ;
  reg  s  ;
  reg  i1 ;
  reg  i0 ;

  mux mux_i
  (
    .y  ( y  ) ,
    .s  ( s  ) ,
    .i1 ( i1 ) ,
    .i0 ( i0 )  
  ) ;

  task expect ( input y_e ) ;
    begin
      $display ( "time=%0d ns s=%b i1=%b i0=%b y=%b", $time, s, i1, i0, y ) ;
      if ( y !== y_e ) begin
        $display ( "WANT:                   y=%b", y_e ) ;
        $display ( "TEST FAILED" ) ;
        $finish;
      end
    end
  endtask

  initial
    begin
      s = 1'b0 ; i1 = 1'b0 ; i0 = 1'b1 ; #1 ; expect ( 1'b1 ) ;
      s = 1'b0 ; i1 = 1'b1 ; i0 = 1'b0 ; #1 ; expect ( 1'b0 ) ;
      s = 1'b1 ; i1 = 1'b0 ; i0 = 1'b1 ; #1 ; expect ( 1'b0 ) ;
      s = 1'b1 ; i1 = 1'b1 ; i0 = 1'b0 ; #1 ; expect ( 1'b1 ) ;
      #1 ;
      $display ( "TEST PASSED" ) ;
    end

endmodule
