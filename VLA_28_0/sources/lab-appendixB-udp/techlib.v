`timescale  1ns /  10ps

`celldefine

/* BUF */

module bfr (
  input  wire A ,
  output wire Y );
  supply1 Vdd;
  supply0 Vss;
  nmos (Y, Vdd, A);
  pmos (Y, Vss, A);
endmodule

/* NOT */

module inv (
  input  wire A ,
  output wire Y );
  supply1 Vdd;
  supply0 Vss;
  pmos (Y, Vdd, A);
  nmos (Y, Vss, A);
endmodule


/* BUFIF1 */

module tribuf (
  input  wire A ,
  input  wire E ,
  output wire Y );
  nmos (Y, A, E);
endmodule


/* AND */


/* NAND */

module nd2 (
  input  wire A ,
  input  wire B ,
  output wire Y );
  supply1 Vdd;
  supply0 Vss;
  pmos (Y,  Vdd, A), (Y, Vdd, B);
  nmos (ya, Vss, A), (Y, ya,  B);
endmodule

module nd3 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output wire Y );
  supply1 Vdd;
  supply0 Vss;
  pmos (Y,  Vdd, A), (Y, Vdd, B), (Y, Vdd, C);
  nmos (ya, Vss, A), (yb, ya, B), (Y, yb,  C);
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
  supply1 Vdd;
  supply0 Vss;
  pmos (Y,  Vdd, A), (Y, Vdd, B), (Y, Vdd, C), (Y, Vdd, D),
       (Y,  Vdd, E), (Y, Vdd, F), (Y, Vdd, G), (Y, Vdd, H);
  nmos (ya, Vss, A), (yb, ya, B), (yc, yb, C), (yd, yc, D),
       (ye, yd,  E), (yf, ye, F), (yg, yf, G), (Y,  yg, H);
endmodule


/* OR */

module or2 (
  input  wire A ,
  input  wire B ,
  output wire Y );
  supply1 Vdd;
  supply0 Vss;
  nmos (Y,  Vdd, A), (Y, Vdd, B);
  pmos (ya, Vss, A), (Y, ya,  B);
endmodule


/* NOR */

module nr2 (
  input  wire A ,
  input  wire B ,
  output wire Y );
  supply1 Vdd;
  supply0 Vss;
  pmos (ya, Vdd, A), (Y, ya,  B);
  nmos (Y,  Vss, A), (Y, Vss, B);
endmodule

module nr3 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output wire Y );
  supply1 Vdd;
  supply0 Vss;
  pmos (ya, Vdd, A), (yb, ya,  B), (Y, yb,  C);
  nmos (Y,  Vss, A), (Y,  Vss, B), (Y, Vss, C);
endmodule


/* AND-OR-INV */

module ao21 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output wire Y );
  supply1 Vdd;
  supply0 Vss;
  pmos (pa, Vdd, A), (pa, Vdd, B), (Y, pa,  C);
  nmos (na, Vss, A), (Y,  na,  B), (Y, Vss, C);
endmodule

module ao211 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  input  wire D ,
  output wire Y );
  supply1 Vdd;
  supply0 Vss;
  pmos (pa, Vdd, A), (pa, Vdd, B), (pb, pa,  C), (Y, pb,  D);
  nmos (na, Vss, A), (Y,  na,  B), (Y,  Vss, C), (Y, Vss, D);
endmodule


/* OR-AND-INV */

module oa21 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output wire Y );
  supply1 Vdd;
  supply0 Vss;
  pmos (pa, Vdd, A), (Y,  pa,  B), (Y, Vdd, C);
  nmos (na, Vss, A), (na, Vss, B), (Y, na,  C);
endmodule

module oa211 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  input  wire D ,
  output wire Y );
  supply1 Vdd;
  supply0 Vss;
  pmos (pa, Vdd, A), (Y,  pa,  B), (Y, Vdd, C), (Y, Vdd, D);
  nmos (na, Vss, A), (na, Vss, B), (nb, na, C), (Y, nb,  D);
endmodule


/* D-TYPE FLIP-FLOPS */
// Master Slave D Flipflop Implementation

module dff_neg (
  input  wire D   ,
  input  wire CKN ,
  output wire Q   );
  bfr bfr1 (CKN, ckn);
  inv inv1 (CKN, ck );
  // buffer d
  inv inv2 (D, d1);
  // master latch
  cmos cmos1 (d2, d1, ckn, ck);
  inv inv3 (d2,     mq );
  inv inv4 (mq,     mqn);
  cmos cmos2 (d2, mqn, ck, ckn);
  // slave latch
  cmos cmos3 (d3, mq, ck, ckn);
  inv inv5 (d3,      sqn);
  inv inv6 (sqn,     sq );
  cmos cmos4 (d3, sq, ckn, ck);
  // buffer q
  inv inv7 (sqn, Q );
  bfr bfr2 (sqn, QN);
endmodule

module dffr (
  input  wire D  ,
  input  wire CK ,
  input  wire RN ,
  output wire Q  );
  bfr bfr1 (CK, ck );
  inv inv1 (CK, ckn);
  // buffer d
  inv inv2 (D, d1);
  // master latch
  cmos cmos1 (d2, d1, ckn, ck);
  inv inv3 (d2,     mq );
  nd2 nd22 (mq, RN, mqn);
  cmos cmos2 (d2, mqn, ck, ckn);
  // slave latch
  cmos cmos3 (d3, mq, ck, ckn);
  nd2 nd23 (d3,  RN, sqn);
  inv inv4 (sqn,     sq );
  cmos cmos4 (d3, sq, ckn, ck);
  // buffer q
  inv inv5 (sqn, Q );
  bfr bfr2 (sqn, QN);
endmodule

module dffs (
  input  wire D  ,
  input  wire CK ,
  input  wire SN ,
  output wire Q  ,
  output wire QN );
  bfr bfr1 (CK, ck );
  inv inv1 (CK, ckn);
  // buffer d
  inv inv2 (D, d1);
  // master latch
  cmos cmos1 (d2, d1, ckn, ck);
  nd2 nd21 (d2, SN, mq );
  inv inv3 (mq,     mqn);
  cmos cmos2 (d2, mqn, ck, ckn);
  // slave latch
  cmos cmos3 (d3, mq, ck, ckn);
  inv inv4 (d3,      sqn);
  nd2 nd24 (sqn, SN, sq );
  cmos cmos4 (d3, sq, ckn, ck);
  // buffer q
  inv inv5 (sqn, Q );
  bfr bfr2 (sqn, QN);
endmodule

module dffrs (
  input  wire D  ,
  input  wire CK ,
  input  wire RN ,
  input  wire SN ,
  output wire Q  ,
  output wire QN );
  bfr bfr1 (CK, ck );
  inv inv1 (CK, ckn);
  // buffer d
  inv inv2 (D, d1);
  // master latch
  cmos cmos1 (d2, d1, ckn, ck);
  nd2 nd21 (d2, SN, mq );
  nd2 nd22 (mq, RN, mqn);
  cmos cmos2 (d2, mqn, ck, ckn);
  // slave latch
  cmos cmos3 (d3, mq, ck, ckn);
  nd2 nd23 (d3,  RN, sqn);
  nd2 nd24 (sqn, SN, sq );
  cmos cmos4 (d3, sq, ckn, ck);
  // buffer q
  inv inv3 (sqn, Q );
  bfr bfr2 (sqn, QN);
endmodule

`endcelldefine
