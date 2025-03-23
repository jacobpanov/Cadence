// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2019, Cadence Design Systems, Inc. All rights reserved.

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
// EENET SINGLE POLE OPAMP MODEL
// Midstage defines inverting gain & offset, pole, and slewing and clipping.
// Output stage is just a buffer with fixed output resistance.
//
// Model is implemented with EEnet output port so timestep and voltage tolerance
// parameters must be properly set for useful operation.  Default timestep
// based on stepsize of Tau in closed loop unity gain configuration.  For 
// higher gain closed loop feedback, upper bound of tinc scales with effective
// closed loop gain (based upon fixed gain-bandwidth product).
// Nonconvergence messages will print during simulation if timestep is 
// specified too large and excessive oscillations or nonconvergence effects
// may be evident in the resulting output signals.

// Note that inputs and supplies are just voltage sensing, not EEnet format,
// so if drive from an EEnet net is required, the node.V value should be passed
// in to get the real voltage value from the EEnet net.

//     Updated:  2019-07-29 (ronv) Cadence Design Systems

`timescale 1ns/1ps

module opamp1 import EE_pkg::*; (output EEnet vout, input real vinp,vinm, vdd,vss);

parameter real sr   = 100e6;    // slew rate (V/sec)
parameter real voff = 0;        // offset voltage (V)
parameter real ugf  = 10e6;     // unity gain freq (Hz)
parameter real av   = 10e3;     // DC gain (V/V)
parameter real rout = 100;      // output resistance (ohms)
parameter real tinc = 0.16/ugf; // timestep size (sec)
parameter real vtol = 0.1e-3;   // voltage tolerance (V)

localparam real r1 = 1e6;
localparam real c1 = 1/(2*3.14159265*r1*ugf/av);
localparam real gm1 = av/r1; 
localparam real imax = c1*sr;
localparam real rclip = tinc/(2000*c1);  // clipper uses 0.1% of cap Req

real Imid;
EEnet N1;

assign Imid = imax*$tanh(gm1*(vinp-vinm+voff)/imax);  // compute I source
VIRsrcG  Mid (N1, 0.0, Imid, r1);                     // drive I+R to midstage
CapGeq  #(.c(c1), .tinc(tinc), .vtol(vtol)) C1 (N1);  // cap on midstage
ClipG   #(.ron(rclip), .isat(imax)) CL (N1,vdd,vss);  // clip to supply limits
VIRsrcG  Vo (vout, N1.V, 0.0, rout);                  // drive V+R to output

endmodule

