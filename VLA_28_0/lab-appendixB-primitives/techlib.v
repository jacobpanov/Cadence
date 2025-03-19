`timescale  1ns /  10ps

`celldefine

/* NOT */

module inv (
  input  wire A ,
  output reg  Y );
  always @* Y = ~(A) ;
endmodule


/* BUFIF1 */

module tribuf (
  input  wire A ,
  input  wire E ,
  output reg  Y );
  always @* Y = E ? A : 'bz ;
endmodule


/* AND */


/* NAND */

module nd2 (
  input  wire A ,
  input  wire B ,
  output reg  Y );
  always @* Y = ~(A & B);
endmodule

module nd3 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output reg  Y );
  always @* Y = ~(A & B & C);
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
  output reg  Y );
  always @* Y = ~(A & B & C & D & E & F & G & H);
endmodule


/* OR */

module or2 (
  input  wire A ,
  input  wire B ,
  output reg  Y );
  always @* Y = (A | B);
endmodule


/* NOR */

module nr2 (
  input  wire A ,
  input  wire B ,
  output reg  Y );
  always @* Y = ~(A | B);
endmodule

module nr3 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output reg  Y );
  always @* Y = ~(A | B | C);
endmodule


/* AND-OR-INV */

module ao21 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output reg  Y );
  always @* Y = ~((A & B) | C);
endmodule

module ao211 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  input  wire D ,
  output reg  Y );
  always @* Y = ~((A & B) | C | D);
endmodule


/* OR-AND-INV */

module oa21 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  output reg  Y );
  always @* Y = ~((A | B) & C);
endmodule

module oa211 (
  input  wire A ,
  input  wire B ,
  input  wire C ,
  input  wire D ,
  output reg  Y );
  always @* Y = ~((A | B) & C & D);
endmodule


/* D-TYPE FLIP-FLOPS */

module dff_neg (
  input  wire D   ,
  input  wire CKN ,
  output reg  Q   );
  always @(negedge CKN)
    Q <= D ;
endmodule

module dffr (
  input  wire D  ,
  input  wire CK ,
  input  wire RN ,
  output reg  Q  );
  always @(posedge CK,
           negedge RN)
    Q <= RN ? D : 'b0 ;
endmodule

module dffs (
  input  wire D  ,
  input  wire CK ,
  input  wire SN ,
  output reg  Q  ,
  output reg  QN );
  always @(posedge CK,
           negedge SN)
    begin
      Q  <= SN ?  D : 'b1;
      QN <= SN ? ~D : 'b0;
    end
endmodule

module dffrs (
  input  wire D  ,
  input  wire CK ,
  input  wire RN ,
  input  wire SN ,
  output reg  Q  ,
  output reg  QN );
  always @(posedge CK,
           negedge RN,
           negedge SN)
    begin
      Q  <= SN ? RN ?  D : 'b0 : 1'b1; // SN beats RN
      QN <= RN ? SN ? ~D : 'b0 : 1'b1; // RN beats SN
    end
endmodule

`endcelldefine
