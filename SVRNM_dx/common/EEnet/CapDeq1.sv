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

// Differential EEnet capacitor implemented with VRsrc & CapGeq models.
// VRsrc connects between differential nodes, measures the current, and
// passes it to the CapGeq model to compute voltage and resistance, which 
// is passed back to the VRsrc model to apply to the differential input.
// Note, this format does not support variable time constant format since
// the capacitor does not "see" the impedances on the VRsrc nodes.

// Updated: 2020-01-16 (ronv)

`timescale 1ns/1ps
import EE_pkg::*;

module  CapDeq1(P,N);
inout EEnet P,N;  // differential pins to capacitor
EEnet DV;         // single-ended version of capacitor voltage
real imeas;       // current flowing through the capacitor

parameter real c=1e-9;      // capacitance
parameter real rs=0;        // series resistance
parameter real ic=0;        // initial capacitor voltage at time zero
parameter real tinc=1e-9;   // timestep for computing voltage update (sec)
parameter real vtol=1e-4;   // voltage tolerance.
parameter real itermax=20;  // max iterations at one timepoint.
parameter real rtol=0.1;    // output resistance update tolerance
parameter real itol=1e-9;   // output current update tolerance

// drive voltage V+R from cap model back to differential input:
VRsrcD  #(.itermax(itermax),.vtol(vtol),.tr(0), .rtol(rtol), .itol(itol)) 
   VC(.P, .N, .vval(CD.Veq), .rval(CD.Req), .imeas);
// drive current into capacitor model:
assign DV = '{0,imeas,`wrealZState}; 
// capacitor model converts from input current to output voltage:
CapGeq1 #(.c(c), .rs(rs), .ic(ic), .tinc(tinc)) CD(DV);

endmodule
