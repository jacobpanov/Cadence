////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/100ps
module alu
#(
  parameter WIDTH=8
 )
 (
  input  wire [      2:0] opcode    ,
  input  wire [WIDTH-1:0] in_a      ,
  input  wire [WIDTH-1:0] in_b      ,
  output wire             a_is_zero ,
  output wire [WIDTH-1:0] alu_out    
 );

//localparam PASS0=0, PASS1=1, ADD=2, AND=3, XOR=4, PASSB=5, PASS6=6, PASS7=7;

  wire [7:0] OP;

  generate
    genvar g1;
    for (g1=0;g1<=7;g1=g1+1) begin : GEN1
      equal #3 opcode_inst (OP[g1], opcode, g1[2:0]);
    end
  endgenerate

  wire [WIDTH-1:0] zeroes = 0;
  equal #WIDTH equal_inst (a_is_zero, in_a, zeroes);

//assign alu_out = {WIDTH{opcode==PASS0}} & (in_a       )
//               | {WIDTH{opcode==PASS1}} & (in_a       )
//               | {WIDTH{opcode==ADD  }} & (in_a + in_b)
//               | {WIDTH{opcode==AND  }} & (in_a & in_b)
//               | {WIDTH{opcode==XOR  }} & (in_a ^ in_b)
//               | {WIDTH{opcode==PASSB}} & (       in_b)
//               | {WIDTH{opcode==PASS6}} & (in_a       )
//               | {WIDTH{opcode==PASS7}} & (in_a       );

  wire [WIDTH-1:0] axob, out[0:7];
  wire [WIDTH-1:0] co, aplb;
  wire [WIDTH-1:0] ci = {co,1'b0};
  generate
    genvar g2;
    for (g2=0;g2<WIDTH;g2=g2+1) begin : GEN2
      and (out[0][g2], OP[0], in_a[g2]); // PASS0
      and (out[1][g2], OP[1], in_a[g2]); // PASS1
      add add_inst (co[g2], aplb[g2], in_a[g2], in_b[g2], ci[g2]);
      and (out[2][g2], OP[2], aplb[g2]); // ADD
      and (out[3][g2], OP[3], in_a[g2], in_b[g2]); // AND
      xor (axob[g2], in_a[g2], in_b[g2]);
      and (out[4][g2], OP[4], axob[g2]); // XOR
      and (out[5][g2], OP[5], in_b[g2]); // PASSB
      and (out[6][g2], OP[6], in_a[g2]); // PASS6
      and (out[7][g2], OP[7], in_a[g2]); // PASS7
      or (alu_out[g2], out[0][g2], out[1][g2], out[2][g2], out[3][g2],
                       out[4][g2], out[5][g2], out[6][g2], out[7][g2]);
    end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////

module controller
(
  input  wire [2:0] opcode ,
  input  wire [2:0] phase  ,
  input  wire       zero   , // accumulator is zero
  output wire       sel    , // select instruction address to memory
  output wire       rd     , // enable memory output onto data bus
  output wire       ld_ir  , // load instruction register
  output wire       inc_pc , // increment program counter
  output wire       halt   , // halt machine
  output wire       ld_pc  , // load program counter
  output wire       data_e , // enable accumulator output onto data bus
  output wire       ld_ac  , // load accumulator from data bus
  output wire       wr       // write data bus to memory
);

//localparam integer HLT=0, SKZ=1, ADD=2, AND=3, XOR=4, LDA=5, STO=6, JMP=7;

  wire [7:0] OP, PH;
  generate
    genvar g;
    for (g=0;g<=7;g=g+1) begin : GEN
      equal #3 opcode_inst (OP[g], opcode, g[2:0]);
      equal #3 phase_inst  (PH[g], phase , g[2:0]);
    end
  endgenerate

//assign sel = phase==0
//          || phase==1
//          || phase==2
//          || phase==3;
  or (sel, PH[0], PH[1], PH[2], PH[3]);

//assign rd = phase==1
//         || phase==2
//         || phase==3
//         || opcode==ADD && phase==5
//         || opcode==ADD && phase==6
//         || opcode==ADD && phase==7
//         || opcode==AND && phase==5
//         || opcode==AND && phase==6
//         || opcode==AND && phase==7
//         || opcode==XOR && phase==5
//         || opcode==XOR && phase==6
//         || opcode==XOR && phase==7
//         || opcode==LDA && phase==5
//         || opcode==LDA && phase==6
//         || opcode==LDA && phase==7
  and (rd25, OP[2], PH[5]), (rd26, OP[2], PH[6]), (rd27, OP[2], PH[7]);
  and (rd35, OP[3], PH[5]), (rd36, OP[3], PH[6]), (rd37, OP[3], PH[7]);
  and (rd45, OP[4], PH[5]), (rd46, OP[4], PH[6]), (rd47, OP[4], PH[7]);
  and (rd55, OP[5], PH[5]), (rd56, OP[5], PH[6]), (rd57, OP[5], PH[7]);
  or (rd, PH[1], PH[2], PH[3], rd25, rd26, rd27, rd35, rd36, rd37,
                               rd45, rd46, rd47, rd55, rd56, rd57);

//assign ld_ir = phase==2 || phase==3;
  or (ld_ir, PH[2], PH[3]);

//assign inc_pc = phase==4
//             || opcode==SKZ && zero && phase==6;
  and (inc6, PH[6], OP[1], zero);
  or (inc_pc, PH[4], inc6);

//assign halt = opcode==HLT && phase==4;
  and (halt, PH[4], OP[0]);

//assign ld_pc = opcode==JMP && phase==6
//            || opcode==JMP && phase==7;
  and (ld_pc6, OP[7], PH[6]), (ld_pc7, OP[7], PH[7]);
  or (ld_pc, ld_pc6, ld_pc7);

//assign data_e = opcode==STO && phase==6
//             || opcode==STO && phase==7;
  and (data_e6, OP[6], PH[6]), (data_e7, OP[6], PH[7]);
  or (data_e, data_e6, data_e7);

//assign ld_ac = opcode==ADD && phase==7
//            || opcode==AND && phase==7
//            || opcode==XOR && phase==7
//            || opcode==LDA && phase==7;
  and (ld_ac2, OP[2], PH[7]), (ld_ac3, OP[3], PH[7]),
      (ld_ac4, OP[4], PH[7]), (ld_ac5, OP[5], PH[7]);
  or (ld_ac, ld_ac2, ld_ac3, ld_ac4, ld_ac5);

//assign wr = opcode==STO && phase==7;
  and (wr, OP[6], PH[7]);

endmodule

////////////////////////////////////////////////////////////////////////////////

module counter
#(
  parameter integer WIDTH=5
 )
 (
  input  wire clk  ,
  input  wire rst  ,
  input  wire load ,
  input  wire enab ,
  input  wire [WIDTH-1:0] cnt_in ,
  output wire [WIDTH-1:0] cnt_out 
 );

  wire [WIDTH-1:0] co;
  wire [WIDTH-1:0] ci = {co, 1'b1};

  generate
    genvar g;
    for (g=0;g<WIDTH;g=g+1) begin : GEN
      cnt cnt_inst (co[g], cnt_out[g], cnt_in[g], clk, enab, load, rst, ci[g]);
    end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////

module driver
#(
  parameter WIDTH=8
 )
 (
  input  wire             data_en ,
  input  wire [WIDTH-1:0] data_in ,
  output wire [WIDTH-1:0] data_out 
 );

  generate
    genvar g;
    for (g=0;g<WIDTH;g=g+1) begin : GEN
      drvr drvr_inst (data_out[g], data_in[g], data_en);
    end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////

module memory
#(
  parameter integer AWIDTH=5,
  parameter integer DWIDTH=8
 )
 (
  input  wire              clk  ,
  input  wire              wr   ,
  input  wire              rd   ,
  input  wire [AWIDTH-1:0] addr ,
  inout  wire [DWIDTH-1:0] data  
 );

  generate
    genvar g1, g2;
    for (g1=0;g1<(2**AWIDTH);g1=g1+1) begin : GEN1
      equal #AWIDTH equal_inst (eq, addr, g1[AWIDTH-1:0]);
      and (w, wr, eq), (r, rd, eq);
      for (g2=0;g2<DWIDTH;g2=g2+1) begin : GEN2
        dff dff_inst (q, data[g2], clk, w, 1'b0);
        drvr drvr_inst (data[g2], q, r);
      end
    end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////

module multiplexor
#(
  parameter WIDTH=5
 )
 (
  input  wire             sel  ,
  input  wire [WIDTH-1:0] in0  ,
  input  wire [WIDTH-1:0] in1  ,
  output wire [WIDTH-1:0] mux_out
 );

  generate
    genvar g;
    for (g=0;g<WIDTH;g=g+1) begin : GEN
      mux21 mux_inst (mux_out[g], sel, in0[g], in1[g]);
    end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////

module register
#(
  parameter integer WIDTH=8
 )
 (
  input  wire clk  ,
  input  wire rst  ,
  input  wire load ,
  input  wire [WIDTH-1:0] data_in,
  output wire [WIDTH-1:0] data_out
 );

  generate
    genvar g;
    for (g=0;g<WIDTH;g=g+1) begin : GEN
      dff dff_inst (data_out[g], data_in[g], clk, load, rst);
    end
  endgenerate

endmodule
