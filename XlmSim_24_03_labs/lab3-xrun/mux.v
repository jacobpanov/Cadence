module mux
(
  output reg   y  ,
  input  wire  s  ,
  input  wire  i1 ,
  input  wire  i0 
) ;

  always @ ( s or i1 or i0 )
    if ( s == 1 )
      y = i1 ;
    else
      y = i0 ;

endmodule
