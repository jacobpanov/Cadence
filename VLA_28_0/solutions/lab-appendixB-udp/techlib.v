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

module dff_neg (
  input  wire D   ,
  input  wire CKN ,
  output wire Q   );
  supply1 Vdd;
  not (ck, CKN);
  UDP_DFFRS (q, D, ck, Vdd, Vdd);
  buf (Q,  q);
endmodule

module dffr (
  input  wire D  ,
  input  wire CK ,
  input  wire RN ,
  output wire Q  );
  supply1 Vdd;
  UDP_DFFRS (q, D, CK, RN, Vdd);
  buf (Q,  q);
  not (QN, q);
endmodule

module dffs (
  input  wire D  ,
  input  wire CK ,
  input  wire SN ,
  output wire Q  ,
  output wire QN );
  supply1 Vdd;
  UDP_DFFRS (q, D, CK, Vdd, SN);
  buf (Q,  q);
  not (QN, q);
endmodule

module dffrs (
  input  wire D  ,
  input  wire CK ,
  input  wire RN ,
  input  wire SN ,
  output wire Q  ,
  output wire QN );
  UDP_DFFRS (q, D, CK, RN, SN);
  buf (Q,  q);
  not (QN, q);
endmodule

`endcelldefine

primitive UDP_DFFRS (Q, D, CK, RN, SN);
  output Q; reg Q;
  input D;
  input CK;
  input RN;
  input SN;
  table
  // D C R S : Q : Qnext
     ? ? ? 0 : ? : 1; // preset
     ? ? 1 * : 1 : -; // pessimism
     ? ? 0 1 : ? : 0; // reset
     ? ? * 1 : 0 : -; // pessimism
     1 r 1 1 : ? : 1; // clock 1
     1 p 1 1 : 1 : -; // pessimism
     0 r 1 1 : ? : 0; // clock 0
     0 p 1 1 : 0 : -; // pessimism
     ? n ? ? : ? : -; // clock negedge
     * ? ? ? : ? : -; // data edge
  endtable
endprimitive
