
// Generated by Cadence Genus(TM) Synthesis Solution 21.17-s066_1
// Generated on: Mar 12 2025 22:59:52 EDT (Mar 13 2025 02:59:52 UTC)

// Verification Directory fv/mux 

module leq_unsigned(A, B, Z);
  input [1:0] A;
  input B;
  output Z;
  wire [1:0] A;
  wire B;
  wire Z;
  wire n_6, n_8, n_13, n_15;
  not g2 (Z, n_6);
  not g3 (n_8, A[1]);
  nand g5 (n_15, n_13, A[0]);
  nand g8 (n_6, n_15, n_8);
  not g13 (n_13, B);
endmodule

module geq_unsigned(A, B, Z);
  input [1:0] A, B;
  output Z;
  wire [1:0] A, B;
  wire Z;
  wire n_9, n_13, n_15, n_16, n_17, n_18, n_19;
  not g3 (n_9, B[1]);
  nand g6 (n_16, n_13, B[0]);
  nor g7 (n_15, A[1], n_9);
  nand g8 (n_18, A[1], n_9);
  not g9 (n_17, n_15);
  nand g10 (n_19, n_16, n_17);
  nand g11 (Z, n_18, n_19);
  not g14 (n_13, A[0]);
endmodule

module bmux(ctl, in_0, in_1, z);
  input ctl, in_0, in_1;
  output z;
  wire ctl, in_0, in_1;
  wire z;
  CDN_bmux2 g1(.sel0 (ctl), .data0 (in_0), .data1 (in_1), .z (z));
endmodule

module mux(mux_out, clock, select, in1, in2, in3);
  input clock, in1, in2, in3;
  input [1:0] select;
  output mux_out;
  wire clock, in1, in2, in3;
  wire [1:0] select;
  wire mux_out;
  wire n_6, n_7, n_8, n_12, n_14, n_15, n_16, n_17;
  wire n_18, n_19, n_20, n_29, temp_reg;
  leq_unsigned lte_27_16(.A (select), .B (1'b1), .Z (n_6));
  geq_unsigned gte_29_16(.A (select), .B (2'b11), .Z (n_8));
  bmux mux_temp_reg_28_16(.ctl (n_7), .in_0 (in3), .in_1 (in2), .z
       (n_12));
  bmux mux_temp_reg_27_16(.ctl (n_6), .in_0 (n_12), .in_1 (in1), .z
       (n_19));
  not g3 (n_17, n_6);
  and g6 (n_15, n_8, n_14);
  or g7 (n_16, n_15, n_7);
  and g8 (n_18, n_16, n_17);
  or g9 (n_20, n_18, n_6);
  CDN_flop mux_out_reg(.clk (clock), .d (temp_reg), .sena (1'b1), .aclr
       (1'b0), .apre (1'b0), .srl (1'b0), .srd (1'b0), .q (mux_out));
  CDN_latch temp_reg_reg(.d (n_19), .ena (n_20), .aclr (1'b0), .apre
       (1'b0), .q (temp_reg));
  nand g10 (n_14, select[1], n_29);
  not g11 (n_7, n_14);
  not g12 (n_29, select[0]);
endmodule

`ifdef RC_CDN_GENERIC_GATE
`else
module CDN_flop(clk, d, sena, aclr, apre, srl, srd, q);
  input clk, d, sena, aclr, apre, srl, srd;
  output q;
  wire clk, d, sena, aclr, apre, srl, srd;
  wire q;
  reg  qi;
  assign #1 q = qi;
  always 
    @(posedge clk or posedge apre or posedge aclr) 
      if (aclr) 
        qi <= 0;
      else if (apre) 
          qi <= 1;
        else if (srl) 
            qi <= srd;
          else begin
            if (sena) 
              qi <= d;
          end
  initial 
    qi <= 1'b0;
endmodule
`endif
`ifdef RC_CDN_GENERIC_GATE
`else
module CDN_latch(ena, d, aclr, apre, q);
  input ena, d, aclr, apre;
  output q;
  wire ena, d, aclr, apre;
  wire q;
  reg  qi;
  assign #1 q = qi;
  always 
    @(d or ena or apre or aclr) 
      if (aclr) 
        qi <= 0;
      else if (apre) 
          qi <= 1;
        else begin
          if (ena) 
            qi <= d;
        end
  initial 
    qi <= 1'b0;
endmodule
`endif
`ifdef RC_CDN_GENERIC_GATE
`else
`ifdef ONE_HOT_MUX
module CDN_bmux2(sel0, data0, data1, z);
  input sel0, data0, data1;
  output z;
  wire sel0, data0, data1;
  reg  z;
  always 
    @(sel0 or data0 or data1) 
      case ({sel0})
       1'b0: z = data0;
       1'b1: z = data1;
      endcase
endmodule
`else
module CDN_bmux2(sel0, data0, data1, z);
  input sel0, data0, data1;
  output z;
  wire sel0, data0, data1;
  wire z;
  wire inv_sel0, w_0, w_1;
  not i_0 (inv_sel0, sel0);
  and a_0 (w_0, inv_sel0, data0);
  and a_1 (w_1, sel0, data1);
  or org (z, w_0, w_1);
endmodule
`endif // ONE_HOT_MUX
`endif
