`timescale  1ns /  10ps

`celldefine

/* NOT */

module inv (
  input  wire A ,
  output wire Y );
  not (Y, A);
endmodule


/* BUFIF1 */

module tribuf (
  input  wire A ,
  input  wire E ,
  output wire Y );
  bufif1 (Y, A, E);
endmodule


/* AND */


/* NAND */

module nd2 (
  input  wire A ,
  input  wire B ,
  output wire Y );
  nand (Y, A, B);
endmodule

module nd3 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output wire Y );
  nand (Y, A, B, C);
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
endmodule


/* OR */

module or2 (
  input  wire A ,
  input  wire B ,
  output wire Y );
  or (Y, A, B);
endmodule


/* NOR */

module nr2 (
  input  wire A ,
  input  wire B ,
  output wire Y );
  nor (Y, A, B);
endmodule

module nr3 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output wire Y );
  nor (Y, A, B, C);
endmodule


/* AND-OR-INV */

module ao21 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output wire Y );
  and (ab, A, B);
  nor (Y, ab, C);
endmodule

module ao211 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  input  wire D ,
  output wire Y );
  and (ab, A, B);
  nor (Y, ab, C, D);
endmodule


/* OR-AND-INV */

module oa21 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output wire Y );
  or (ab, A, B);
  nand (Y, ab, C);
endmodule

module oa211 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  input  wire D ,
  output wire Y );
  or (ab, A, B);
  nand (Y, ab, C, D);
endmodule


/* D-TYPE FLIP-FLOPS */

// Edge Triggered D Flipflop Implementation

module dff_neg (
  input  wire D   ,
  input  wire CKN ,
  output wire Q   );
  nor  (mq,  mqn, sqn, CKN);
  nor  (mqn, mq,       D  );
  nor  (sq,  sqn, mqn     );
  nor  (sqn, sq,       CKN);
  nor  (Q,      sqn, QN);
  nor  (QN,     mq,  Q );
endmodule

module dffr (
  input  wire D  ,
  input  wire CK ,
  input  wire RN ,
  output wire Q  );
  nand (mq,  mqn, sqn, CK);
  nand (mqn, mq,  RN,  D );
  nand (sq,  sqn, mqn    );
  nand (sqn, sq,  RN,  CK);
  nand (Q,      sqn, QN);
  nand (QN, RN, mq,  Q );
endmodule

module dffs (
  input  wire D  ,
  input  wire CK ,
  input  wire SN ,
  output wire Q  ,
  output wire QN );
  nand (mq,  mqn, sqn, CK);
  nand (mqn, mq,       D );
  nand (sq,  sqn, mqn, SN);
  nand (sqn, sq,       CK);
  nand (Q,  SN, sqn, QN);
  nand (QN,     mq,  Q );
endmodule

module dffrs (
  input  wire D  ,
  input  wire CK ,
  input  wire RN ,
  input  wire SN ,
  output wire Q  ,
  output wire QN );
  nand (mq,  mqn, sqn, CK);
  nand (mqn, mq,  RN,  D );
  nand (sq,  sqn, mqn, SN);
  nand (sqn, sq,  RN,  CK);
  nand (Q,  SN, sqn, QN);
  nand (QN, RN, mq,  Q );
endmodule

`endcelldefine
