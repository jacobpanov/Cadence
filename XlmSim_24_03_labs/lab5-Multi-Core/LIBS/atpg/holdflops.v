
`timescale 1ns/10ps
`celldefine
module HOLD_SDFFQX1 (CK, D, E, Q, SE, SI);
input  CK ;
input  D ;
input  E ;
input  SE ;
input  SI ;
output Q ;
reg NOTIFIER ;

   udp_mux2 (Int_D1, Int_D0, SI, SE);
   udp_mux2 (Int_D, Int_D1, D, E);
   udp_dff (N30, Int_D, CK, 1'B0, 1'B0, NOTIFIER);
   not (QBINT, N30);
   not (Q, QBINT);
   not (Int_D0, QBINT);

endmodule
`endcelldefine

