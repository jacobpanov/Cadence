`timescale  1ns / 10ps

`celldefine

/* NOT */

module inv (
  input  wire A ,
  output wire Y );
  not (Y, A);
  specify
    specparam tpA01 = 0.02:0.04:0.07 , tpA10 = 0.01:0.03:0.05 ;
    (A *> Y) = (tpA01, tpA10) ;
  endspecify
endmodule


/* BUFIF1 */

module tribuf (
  input  wire A ,
  input  wire E ,
  output wire Y );
  bufif1 (Y, A, E);
  specify
    specparam tpA01 = 0.07:0.12:0.19 ;
    specparam tpA10 = 0.12:0.18:0.27 ;
    specparam tpE0Z = 0.05:0.08:0.14 ;
    specparam tpEZ1 = 0.08:0.13:0.20 ;
    specparam tpE1Z = 0.03:0.05:0.08 ;
    specparam tpEZ0 = 0.12:0.19:0.29 ;
    (A *> Y) = (tpA01, tpA10);
    (E *> Y) = (tpA01, tpA10, tpE0Z, tpEZ1, tpE1Z, tpEZ0);
  endspecify

endmodule


/* AND */


/* NAND */

module nd2 (
  input  wire A ,
  input  wire B ,
  output wire Y );
  nand (Y, A, B);
  specify
    specparam tpA01 = 0.03:0.05:0.10 , tpA10 = 0.01:0.03:0.07 ;
    specparam tpB01 = 0.03:0.06:0.12 , tpB10 = 0.02:0.04:0.08 ;
    (A *> Y) = (tpA01, tpA10) ;
    (B *> Y) = (tpB01, tpB10) ;
  endspecify
endmodule

module nd3 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output wire Y );
  nand (Y, A, B, C);
  specify
    specparam tpA01 = 0.04:0.09:0.18 , tpA10 = 0.03:0.06:0.12 ;
    specparam tpB01 = 0.05:0.10:0.21 , tpB10 = 0.03:0.07:0.14 ;
    specparam tpC01 = 0.06:0.12:0.23 , tpC10 = 0.03:0.07:0.16 ;
    (A *> Y) = (tpA01, tpA10) ;
    (B *> Y) = (tpB01, tpB10) ;
    (C *> Y) = (tpC01, tpC10) ;
  endspecify
endmodule

module nd8 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  input  wire D ,
  input  wire E ,
  input  wire F ,
  input  wire G ,
  input  wire H ,
  output wire Y );
  nand (Y, A, B, C, D, E, F, G, H);
  specify
    specparam tpA01 = 0.28:0.47:0.79 , tpA10 = 0.15:0.29:0.54 ;
    specparam tpB01 = 0.29:0.49:0.83 , tpB10 = 0.16:0.30:0.57 ;
    specparam tpC01 = 0.30:0.51:0.86 , tpC10 = 0.17:0.31:0.59 ;
    specparam tpD01 = 0.31:0.52:0.88 , tpD10 = 0.17:0.32:0.60 ;
    specparam tpE01 = 0.29:0.49:0.82 , tpE10 = 0.16:0.30:0.56 ;
    specparam tpF01 = 0.30:0.51:0.87 , tpF10 = 0.17:0.32:0.60 ;
    specparam tpG01 = 0.31:0.53:0.90 , tpG10 = 0.17:0.33:0.61 ;
    specparam tpH01 = 0.32:0.54:0.92 , tpH10 = 0.18:0.33:0.63 ;
    (A *> Y) = (tpA01, tpA10) ;
    (B *> Y) = (tpB01, tpB10) ;
    (C *> Y) = (tpC01, tpC10) ;
    (D *> Y) = (tpD01, tpD10) ;
    (E *> Y) = (tpE01, tpE10) ;
    (F *> Y) = (tpF01, tpF10) ;
    (G *> Y) = (tpG01, tpG10) ;
    (H *> Y) = (tpH01, tpH10) ;
  endspecify
endmodule


/* OR */

module or2 (
  input  wire A ,
  input  wire B ,
  output wire Y );
  or (Y, A, B);
  specify
    specparam tpA01 = 0.10:0.14:0.22 , tpA10 = 0.13:0.20:0.32 ;
    specparam tpB01 = 0.11:0.17:0.25 , tpB10 = 0.15:0.24:0.37 ;
    (A *> Y) = (tpA01, tpA10) ;
    (B *> Y) = (tpB01, tpB10) ;
  endspecify
endmodule


/* NOR */

module nr2 (
  input  wire A ,
  input  wire B ,
  output wire Y );
  nor (Y, A, B);
  specify
    specparam tpA01 = 0.04:0.07:0.11 , tpA10 = 0.02:0.04:0.08 ;
    specparam tpB01 = 0.06:0.10:0.17 , tpB10 = 0.03:0.06:0.12 ;
    (A *> Y) = (tpA01, tpA10) ;
    (B *> Y) = (tpB01, tpB10) ;
  endspecify
endmodule

module nr3 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output wire Y );
  nor (Y, A, B, C);
  specify
    specparam tpA01 = 0.06:0.09:0.16 , tpA10 = 0.03:0.06:0.11 ;
    specparam tpB01 = 0.09:0.16:0.26 , tpB10 = 0.05:0.10:0.18 ;
    specparam tpC01 = 0.11:0.19:0.31 , tpC10 = 0.06:0.11:0.21 ;
    (A *> Y) = (tpA01, tpA10) ;
    (B *> Y) = (tpB01, tpB10) ;
    (C *> Y) = (tpC01, tpC10) ;
  endspecify
endmodule


/* AND-OR-INV */

module ao21 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output wire Y );
  and (ab, A, B);
  nor (Y, ab, C);
  specify
    specparam tpA01 = 0.03:0.06:0.10 , tpA10 = 0.02:0.04:0.07 ;
    specparam tpB01 = 0.04:0.08:0.13 , tpB10 = 0.02:0.05:0.09 ;
    specparam tpC01 = 0.08:0.14:0.23 , tpC10 = 0.04:0.08:0.16 ;
    (A *> Y) = (tpA01, tpA10) ;
    (B *> Y) = (tpB01, tpB10) ;
    (C *> Y) = (tpC01, tpC10) ;
  endspecify
endmodule

module ao211 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  input  wire D ,
  output wire Y );
  and (ab, A, B);
  nor (Y, ab, C, D);
  specify
    specparam tpA01 = 0.06:0.10:0.17 , tpA10 = 0.03:0.06:0.11 ;
    specparam tpB01 = 0.10:0.17:0.29 , tpB10 = 0.05:0.10:0.20 ;
    specparam tpC01 = 0.19:0.32:0.55 , tpC10 = 0.11:0.20:0.37 ;
    specparam tpD01 = 0.19:0.32:0.55 , tpD10 = 0.11:0.20:0.37 ;
    (A *> Y) = (tpA01, tpA10) ;
    (B *> Y) = (tpB01, tpB10) ;
    (C *> Y) = (tpC01, tpC10) ;
    (D *> Y) = (tpD01, tpD10) ;
  endspecify
endmodule


/* OR-AND-INV */

module oa21 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output wire Y );
  or (ab, A, B);
  nand (Y, ab, C);
  specify
    specparam tpA01 = 0.03:0.06:0.13 , tpA10 = 0.02:0.04:0.09 ;
    specparam tpB01 = 0.05:0.10:0.20 , tpB10 = 0.03:0.06:0.13 ;
    specparam tpC01 = 0.05:0.10:0.20 , tpC10 = 0.03:0.07:0.14 ;
    (A *> Y) = (tpA01, tpA10) ;
    (B *> Y) = (tpB01, tpB10) ;
    (C *> Y) = (tpC01, tpC10) ;
  endspecify
endmodule

module oa211 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  input  wire D ,
  output wire Y );
  or (ab, A, B);
  nand (Y, ab, C, D);
  specify
    specparam tpA01 = 0.04:0.09:0.18 , tpA10 = 0.03:0.06:0.12 ;
    specparam tpB01 = 0.06:0.13:0.25 , tpB10 = 0.04:0.08:0.17 ;
    specparam tpC01 = 0.08:0.16:0.33 , tpC10 = 0.05:0.10:0.22 ;
    specparam tpD01 = 0.09:0.18:0.36 , tpD10 = 0.05:0.11:0.24 ;
    (A *> Y) = (tpA01, tpA10) ;
    (B *> Y) = (tpB01, tpB10) ;
    (C *> Y) = (tpC01, tpC10) ;
    (D *> Y) = (tpD01, tpD10) ;
  endspecify
endmodule


/* D-TYPE FLIP-FLOPS */

module dff_neg (
  input  wire D   ,
  input  wire CKN ,
  output wire Q   );
  reg nr; // notifier
  supply1 Vdd;
  not (ck, CKN);
  UDP_DFFRS (q, D, ck, Vdd, Vdd, nr);
  buf (Q,  q);
  specify
    specparam tpCQ01 = 0.12:0.24:0.45 , tpCQ10 = 0.28:0.45:0.72 ;
    (negedge CKN => (Q +: D)) = (tpCQ01, tpCQ10) ;
    $setuphold (negedge CKN, D, 0.18, 0.40, nr);
    $width (posedge CKN, 0.92, 0, nr);
    $width (negedge CKN, 0.92, 0, nr);
  endspecify
endmodule

module dffr (
  input  wire D  ,
  input  wire CK ,
  input  wire RN ,
  output wire Q  );
  reg nr; // notifier
  supply1 Vdd;
  UDP_DFFRS (q, D, CK, RN, Vdd, nr);
  buf (Q,  q);
  not (QN, q);
  specify
    specparam tpCQ01 = 0.14:0.29:0.55 , tpCQ10 = 0.28:0.46:0.73 ;
    specparam tpRQ01 = 0.00:0.00:0.00 , tpRQ10 = 0.28:0.46:0.73 ;
    specparam tsD  = 0.34 ; // setup
    specparam thD  = 0.29 ; // hold
    specparam tr   = 0.14 ; // recovery
    specparam tw   = 0.92 ; // width
    (posedge CK => (Q +: D))    = (tpCQ01, tpCQ10) ;
    (negedge RN => (Q +: 1'b0)) = (tpRQ01, tpRQ10) ;
    $recovery (posedge RN, posedge CK, tr, nr);
    $setuphold (posedge CK, D, tsD, thD, nr);
    $width (posedge CK, tw, 0, nr);
    $width (negedge CK, tw, 0, nr);
    $width (negedge RN, tw, 0, nr);
  endspecify
endmodule

module dffs (
  input  wire D  ,
  input  wire CK ,
  input  wire SN ,
  output wire Q  ,
  output wire QN );
  reg nr; // notifier
  supply1 Vdd;
  UDP_DFFRS (q, D, CK, Vdd, SN, nr);
  buf (Q,  q);
  not (QN, q);
  specify
    specparam tpCQ01  = 0.12:0.22:0.43 , tpCQ10  = 0.27:0.43:0.69 ;
    specparam tpSQ01  = 0.12:0.22:0.43 , tpSQ10  = 0.00:0.00:0.00 ;
    specparam tpCQN01 = 0.16:0.30:0.58 , tpCQN10 = 0.36:0.58:0.92 ;
    specparam tpSQN01 = 0.00:0.00:0.00 , tpSQN10 = 0.36:0.58:0.92 ;
    specparam tsD  = 0.34 ; // setup
    specparam thD  = 0.40 ; // hold
    specparam tr   = 0.14 ; // recovery
    specparam tw   = 0.92 ; // width
    (posedge CK => (Q  +: D))    = (tpCQ01, tpCQ10) ;
    (negedge SN => (Q  +: 1'b1)) = (tpSQ01, tpSQ10) ;
    (posedge CK => (QN -: D))    = (tpCQN01, tpCQN10) ;
    (negedge SN => (QN +: 1'b0)) = (tpSQN01, tpSQN10) ;
    $recovery (posedge SN, posedge CK, tr, nr);
    $setuphold (posedge CK, D, tsD, thD, nr);
    $width (posedge CK, tw, 0, nr);
    $width (negedge CK, tw, 0, nr);
    $width (negedge SN, tw, 0, nr);
  endspecify
endmodule

module dffrs (
  input  wire D  ,
  input  wire CK ,
  input  wire RN ,
  input  wire SN ,
  output wire Q  ,
  output wire QN );
  reg nr; // notifier
  UDP_DFFRS (q, D, CK, RN, SN, nr);
  buf (Q,  q);
  not (QN, q);
  specify
    specparam tpCQ01  = 0.12:0.24:0.46 , tpCQ10  = 0.29:0.46:0.73 ;
    specparam tpSQ01  = 0.12:0.24:0.46 , tpSQ10  = 0.00:0.00:0.00 ;
    specparam tpRQ01  = 0.00:0.00:0.00 , tpRQ10  = 0.29:0.46:0.73 ;
    specparam tpCQN01 = 0.17:0.33:0.63 , tpCQN10 = 0.39:0.63:1.00 ;
    specparam tpRQN01 = 0.17:0.33:0.63 , tpRQN10 = 0.00:0.00:0.00 ;
    specparam tpSQN01 = 0.00:0.00:0.00 , tpSQN10 = 0.39:0.63:1.00 ;
    specparam tsD  = 0.34 ; // setup
    specparam thD  = 0.40 ; // hold
    specparam tr   = 0.14 ; // recovery
    specparam tw   = 0.92 ; // width
    (posedge CK =>  (Q  +: D))    = (tpCQ01, tpCQ10) ;
    (negedge SN =>  (Q  +: 1'b1)) = (tpSQ01, tpSQ10) ;
    (negedge RN =>  (Q  +: 1'b0)) = (tpRQ01, tpRQ10) ;
    (posedge CK =>  (QN -: D))    = (tpCQN01, tpCQN10) ;
    (negedge RN =>  (QN +: 1'b1)) = (tpRQN01, tpRQN10) ;
    (negedge SN =>  (QN +: 1'b0)) = (tpSQN01, tpSQN10) ;
    $recovery (posedge RN, posedge CK, tr, nr);
    $recovery (posedge SN, posedge CK, tr, nr);
    $setuphold (posedge CK, D, tsD, thD, nr);
    $width (posedge CK, tw, 0, nr);
    $width (negedge CK, tw, 0, nr);
    $width (negedge RN, tw, 0, nr);
    $width (negedge SN, tw, 0, nr);
  endspecify
endmodule

`endcelldefine

primitive UDP_DFFRS (Q, D, CK, RN, SN, NR);
  output Q; reg Q;
  input D;
  input CK;
  input RN;
  input SN;
  input NR; // notifier
  table
  // D C R S N : Q : Qnext
     ? ? ? 0 ? : ? : 1; // preset
     ? ? 1 * ? : 1 : -; // pessimism
     ? ? 0 1 ? : ? : 0; // reset
     ? ? * 1 ? : 0 : -; // pessimism
     1 r 1 1 ? : ? : 1; // clock 1
     1 p 1 1 ? : 1 : -; // pessimism
     0 r 1 1 ? : ? : 0; // clock 0
     0 p 1 1 ? : 0 : -; // pessimism
     ? n ? ? ? : ? : -; // clock negedge
     * ? ? ? ? : ? : -; // data edge
     ? ? ? ? * : ? : x; // notifier
  endtable
endprimitive
