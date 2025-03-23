// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2020, Cadence Design Systems, Inc. All rights reserved.

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
//
// ClipG - clip EEnet net to specified supply limits.
//   VDD,VSS are supply inputs (real variables)
//   ron is on resistance of limiter
//   dV is distance from the supply to theshold point of limiter
//   Isat is current needed to get output to voltage limit (sets dV=Isat*ron)
// This module uses the SwitG model to define the two clippers - just linear
// resistance model when on, else off.  Current measurement returns a positive
// value when the VDD limit is encountered, a negative value when VSS limiting
// occurs.
// Note that in presence of any EEnet capacitance on the net, the sudden 
// resistance decrease when this element switches on could result in iteration
// issues, unless the 'BigStep' alternative formulation is included in the 
// capacitor model (enabled by default in CapGeq, CapDeq, and CapGx models).

// Updated 2019-07-29 (ronv) Cadence Design Systems

import EE_pkg::*;

module ClipG (
  output EEnet P,       // EEnet net (driven when clipping occuring)
  input real VDD,VSS);  // real voltage values to clip at
 
parameter real ron=0.1;       // (ohm) on resistance at clip limit
parameter real isat=0.01;     // (A) current needed to drive to voltage limit
parameter real dv=ron*isat;   // (V) distance from supply to limiting threshold
parameter real roff=1e13;     // (ohm) off resistance of switch (default is `Z)
parameter real itermax=20;    // SwitG max iterations at one timepoint

real Imeas;

assign ENhi = (P.V>VDD-dv) && (thi.Imeas>=0);
assign ENlo = (P.V<VSS+dv) && (tlo.Imeas<=0);

SwitG #(.ron(ron), .roff(roff), .itermax(itermax))
   thi(P,VDD,ENhi), tlo(P,VSS,ENlo);

assign Imeas = thi.Imeas+tlo.Imeas;   // limiter current

endmodule

