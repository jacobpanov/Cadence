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
// NMOS_EE (D,G,S) - EEnet fully diffl PMOS switch
// Parameter vth defines minimum Vsg or Vdg for conduction.
// Parameters ron and roff define on & off resistances.
// Symmetric model: works the same upside down.
// Note: two-state operation only, so may not be useful in drain-to-gate 
//  feedback situations (could result in iteration issues).

// Updated 2018-10-25 (ronv) Cadence Design Systems Inc.

import EE_pkg::*;

module PMOS_EE (
  inout EEnet D,          // EEnet drain pin
  input EEnet G,          // EEnet gate pin
  inout EEnet S );        // EEnet source pin

parameter real vth=0.6;       // source-gate voltage required for turnon
parameter real ron=10;        // drain-source on resistance
parameter real roff=1e13;     // off resistance (<1e13 for non-Z)
// EEIO update control parameters:
parameter real vtol=1e-4;     // output voltage update tolerance
parameter real itol=1e-9;     // output current update tolerance
parameter real itermax=20;    // max iterations at one timepoint

real Vsg,Vdg;                 // controlling voltages
reg en;                       // enable state (high or low)
real Ids;                     // drain-source current

assign Vsg = S.V-G.V;         // variable for gate-source voltage
assign Vdg = D.V-G.V;         // variable for gate-drain voltage

initial forever begin
  if (Vsg>vth || Vdg>vth) en=1'b1; // on when either junction above threshold
  else                    en=1'b0; // off for all other cases (including X&Z)
  @(Vsg,Vdg);
end

SwitD #(.ron(ron), .roff(roff), .vtol(vtol), .itol(itol), .itermax(itermax)) 
  sw(D,S,en);

assign Ids = sw.Iout;         // measure drain-source current

endmodule
