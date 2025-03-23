////////////////////////////////////////////////////////////////////////
// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2019, Cadence Design Systems, Inc. All rights reserved.

// The model contained herein is the proprietary and confidential information 
// of Cadence (except as noted), and is supplied subject to, and may be used only by Cadences 
// customer in accordance with a previously executed license and maintenance 
// agreement between Cadence and that customer. This model is intended for use 
// with products only from Cadence Design Systems, Inc.  The use or sharing of 
// any models from this library or any of its modified/extended form is 
// strictly prohibited with any non-Cadence products.

// ALL MATERIALS FURNISHED BY CADENCE HEREUNDER ARE PROVIDED "AS IS" WITHOUT 
// WARRANTY OF ANY KIND, AND CADENCE SPECIFICALLY DISCLAIMS ANY WARRANTY OF 
// NONINFRINGEMENT, FITNESS FOR A PARTICULAR PURPOSE OR MERCHANTABILITY. 
// CADENCE SHALL NOT BE LIABLE FOR ANY COSTS OF PROCUREMENT OF SUBSTITUTES, 
// LOSS OF PROFITS, INTERRUPTION OF BUSINESS, OR FOR ANY OTHER SPECIAL, 
// CONSEQUENTIAL OR INCIDENTAL DAMAGES, HOWEVER CAUSED, WHETHER FOR BREACH OF 
// WARRANTY, CONTRACT, TORT, NEGLIGENCE, STRICT LIABILITY OR OTHERWISE.
// --------------------------------------------------------------
// 
// Mixed Signal Neuron Model for Neural Net
//    The circuit performs a multiply-and-accumulate of
//    1024 independent single-bit inputs by 1024 single-bit 
//    weights. If the number of 1's after multiplication (XOR)
//    exceeds the number of 0's, the neuron will output a 1.
//    Input values are latched on clkn, and the comparison is
//    made on clkp. Therefore, the valid output will always 
//    lag the input by 1 clock cycle.
//
// Based on work presented by Murmann, et. al., 2015
//   (see https://indico.cern.ch/event/830212/attachments/1891493/3130913/20190827cern-FOR-PUB.pdf )
// 
// --------------------------------------------------------------

`timescale 1ns / 1ps 

 

module msNeuron (out, vdd, vss, clkn, clkp, en, w, x);

output  out;

inout  vdd, vss;

input  clkn, clkp, en;

input [1023:0]  x;
input [1023:0]  w;

// Buses in the design

wire  [1023:0]  net20;

wire  [1023:0]  net19;


xNOR I1[1023:0] ( .clk(clkn), .vss(vss), .w(w), .vdd(vdd), 
    .x(x), .out(net20));

xOR I2[1023:0] ( .clk(clkn), .vss(vss), .w(w), .vdd(vdd), 
    .x(x), .out(net19));


// CapDeq #(.c (1e-12), .vtol (0.25)) C5 ( .N(vss), .P(net8));

// CapDeq #(.c (1e-12), .vtol (0.25)) C6 ( .N(vss), .P(net7));

// Integrating Caps at comparator inputs
CapGeq  #(.c (5e-14), .vtol (0.0001), .tinc (5e-9)) C5 (.P(net8));

CapGeq  #(.c (5e-14), .vtol (0.0001), .tinc (5e-9)) C6 (.P(net7));

// Series Caps feeding multiply outputs to summing nodes
CapDeq  #(.c (1e-14), .vtol (0.0001), .tinc (5e-9)) C4[1023:0] ( .N(net19), .P(net7));


CapDeq  #(.c (1e-14), .vtol (0.0001), .tinc (5e-9)) C3[1023:0] ( .N(net20), .P(net8));



comparator I5 ( .clkp(clkp), .vdd(vdd), .vss(vss), .out(out), 
    .clkn(clkn), .en(en), .inm(net7), .inp(net8));

endmodule


