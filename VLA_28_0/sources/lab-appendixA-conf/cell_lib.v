`timescale 1ns/100ps
module add (co, y, a, b, c);
  output co, y; input a, b, c;
  xor (y, a, b, c);
  and (co1, a, b);
  and (co2, a, c);
  and (co3, b, c);
  or  (co, co1, co2, co3);
endmodule

module cnt (co, q, d, c, e, l, r, ci);
  output co, q; input d, c, e, l, r, ci;
  buf (es, c);
  not (em, c);
  incr incr_i (co, dc, q, ci);   // incr
  mux21 mux_1 (de, e, q, dc);    // enab
  mux21 mux_2 (dl, l, de, d);    // load
  mux21 mux_3 (dr, r, dl, 1'b0); // reset
  mux21 mux_4 (qm, em, qm, dr);  // master
  mux21 mux_5 (q , es, q , qm);  // slave
endmodule

module dff (q, d, c, e, r);
  output q; input d, c, e, r;
  buf (es, c);
  not (em, c);
  mux21 mux_1 (de, e, q, d);
  mux21 mux_2 (dr, r, de, 1'b0);
  mux21 mux_3 (qm, em, qm, dr);
  mux21 mux_4 (q , es, q , qm);
endmodule

module drvr (y, a, e);
  output y; input a, e;
  bufif1 (y, a, e);
endmodule

module equal (y, a, b);
  parameter W=1;
  output y; input [W:1] a, b;
  wire [W:1] eq;
  wire [W:0] an;
  assign an[0]=1'b1;
  generate
    genvar g;
    for (g=1;g<=W;g=g+1) begin : GEN
      xnor (eq[g], a[g], b[g]);
      and (an[g], eq[g], an[g-1]);
    end  
  endgenerate
  assign y=an[W];
endmodule

module incr (co, y, a, c);
  output co, y; input a, c;
  xor (y, a, c);
  and (co, a, c);
endmodule

module mux21 (y, s, a, b);
  output y; input s, a, b;
  buf (sb, s);
  not (sa, s);
  and (as, a, sa);
  and (bs, b, sb);
  or  (y, as, bs);
endmodule

