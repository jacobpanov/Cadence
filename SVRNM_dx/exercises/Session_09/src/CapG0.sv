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

// Simple capacitor model (assumes discretely changing drive current)
`timescale 1ns/1ps
import EE_pkg::*;

module  CapG0 (inout EEnet P);
  parameter real c=1e-9;      // capacitance value (farads)
  parameter real tinc=1e-9;   // update timestep (seconds)
  bit ck;
  real dV,Icap,Tcap,Vout;

always #(tinc*1s) ck=!ck;     // toggle clock at defined rate

always @(P.I,ck) begin               // on input change or clock cycle:
  dV = Icap*($realtime-Tcap)/(c*1s); // change of voltage is I*dT/C
  Icap = P.I;  Tcap = $realtime;     // save new current & time
  Vout += dV;                        // update voltage
end

assign P = '{Vout,0,0};   // drive output voltage as ideal voltage source

endmodule
