// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2017, Cadence Design Systems, Inc. All rights reserved.

// The model contained herein is the proprietary and confidential information 
// of Cadence, and is supplied subject to, and may be used only by Cadences 
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

// Detailed model of voltage doubler charge pump operation.
// Uses EEnet format for input & output pins to model current handling,
// logic for clock input.  Assumes ground at zero volts.
// 
// DOUBLER TOPOLOGY:
//       [IN]*------+----------+
//                  S1         S0
//             [Vck]*-----||---*[MID]---S1---+------*[OUT]
//                  S0    CP                _|_ +     
//                  |   -Vcp+             CL--- Vcl 
//                 _|_                      _|_ -  
//                  -                        -
//
// IMPLEMENTATION NOTES:
//
// The two S1 switches are closed when the clock is high; the two S0
// switches are closed when the clock is low; both are open while the
// clock is switching.
//
// Basic operation:  When clock is low, Cp is charged up to Vin.
// Then when clock goes high, Cp and Vin are connected in series to
// the output pin, which can drive the output up to near 2*Vin.
//
// This EEnet module describes the four switches and two capacitors directly.
// Risetime is specified on the switched resistors so the currents are
// produced with proper turn-on/off shapes (evaluations assume linear 
// conductance variation during switching) so that the resulting integrations
// in the CapGeq model will be accurate.

`timescale 1ns/1ps

module doubler0_full import EE_pkg::*; (
  inout EEnet OUT,          // EEnet format output
  input CK,                 // clock control input 
  inout EEnet IN            // EEnet formal input
  );

  EEnet VCK,MID;              // internal nodes in topological model

  parameter real CL=100e-9;   // output capacitance
  parameter real Cp=10e-9;    // Internal capacitor of charge pump
  parameter real Ron=3;       // on resistance of switches
  parameter real Roff=1e6;    // off resistance of switches
  parameter real Tsw=5e-9;    // non-overlap interval for switching
  parameter real Ts=50e-9;    // sample rate 

  real Rs1=Roff, Rs0=Roff;    // resistance for clock phases
  real Is1i,Is0i,Is1o,Is0o;   // currents in switches

  assign #(Tsw*1s,0) Phi1 = (CK===1'b1); // generate non-overlapping phases
  assign #(Tsw*1s,0) Phi0 = (CK===1'b0);
  always @(Phi1) Rs1 = Phi1? Ron:Roff;   // choose resistances based on phase
  always @(Phi0) Rs0 = Phi0? Ron:Roff;

  // Netlist of 2 capacitors and 4 switched resistors:
  CapDeq #(.c(Cp), .tinc(Ts), .vtol(0.001)) Cpump(MID,VCK);
  CapGeq #(.c(CL), .tinc(Ts), .vtol(0.001), .rxflag(0)) Cout (OUT);
  VRsrcD #(.tr(Tsw))  S1i(IN,  VCK, 0.0, Rs1, Is1i);
  VIRsrcG #(.tr(Tsw)) S0i(VCK,      0.0, 0.0, Rs0);
  VRsrcD #(.tr(Tsw))  S1o(MID, OUT, 0.0, Rs1, Is1o);
  VRsrcD #(.tr(Tsw))  S0o(IN,  MID, 0.0, Rs0, Is0o);

endmodule
