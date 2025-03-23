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
// DIO_EE (A,C) - EEnet fully diffl switch
// Parameter von & ron define active operation; parameter roff in off mode.
// In "on" region:  Id = (V-von)/ron.
// In "off" region: Id = V/roff.
// Crossing of those two lines is at:  Vx = von/(1-ron/roff)

// Updated 2019-04-19 (ronv) Cadence Design Systems Inc.

import EE_pkg::*;

module DIO_EE (
  inout EEnet A,          // EEnet anode pin
  input EEnet C );        // EEnet cathode pin

parameter real von=0.2;       // diode on voltage
parameter real ron=10;        // diode on resistance
parameter real roff=1e10;     // off resistance (<1e13 for non-Z)
// EEIO update control parameters:
parameter real vtol=1e-4;     // output voltage update tolerance
parameter real itol=1e-9;     // output current update tolerance
parameter real itermax=20;    // max iterations at one timepoint

reg en;                       // enable state (high or low)
real Idio;                    // diode current
real Vd,Vx;                   // diode voltage and threshold
assign Vd = A.V-C.V;

initial begin
  Vx = von/(1-ron/roff);   // crossing point between two lines
  forever begin
    if (Vd>Vx) en=1'b1; // on when above threshold
    else       en=1'b0; // off when at or below threshold
    @(Vd);
  end
end

SwitD #(.ron(ron), .roff(roff), .vos(von), .vtol(vtol), .itol(itol), 
        .itermax(itermax))  sw(A,C,en);

// Report current, force new point at each current or voltage change:
always @(sw.DP.Imeas,A.V,C.V) Idio <= sw.DP.Imeas+((Idio==sw.DP.Imeas)? 1e-14:0);

endmodule

