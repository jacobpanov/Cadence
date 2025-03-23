// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2018, Cadence Design Systems, Inc. All rights reserved.

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

// VIRsrcG.sv - driver for VIR format EEnet signals

// General drive to EEnet net - accepts all V/I/R combinations. 
// Output is driven after specified tr interval.  
// Default tr value is zero here, but note that the VAMS electrical model 
// requires a value greater than zero for proper analog operation, so it
// should be set nonzero when comparing with analog response.  Note that there
// is no interpolation during risetime interval in this model: it just steps 
// to new value at end of risetime period.  A more complex model would be 
// needed if slow-rising-ramp effect is required.

//     Updated:  2020-01-16 (ronv) 

import EE_pkg::*; 
`timescale 1ns/1ps

module VIRsrcG (inout EEnet P, input real vval,ival,rval);

parameter real tr = 0;        // (sec) risetime for all drive changes

EEstruct Pval='{0,0,1e13};    // value to drive to output (initially Z)
real rinc;                    // increment to apply to R value at start of change
real Imeas;                   // measured current (for probing)
real trns=0;                  // no delay at time zero
initial #(1step) trns=tr*1s;  // delay by tr thereafter (convert to nanoseconds)

always begin
  if (trns==0) Pval = '{vval,ival,rval};   // just pass thru
  else begin
    if (Pval.R+Pval.V===`wrealZState && vval+rval<1e15) // Z-to-normal transition
      Pval = '{vval,Pval.I+1e-13,5e12};    //  goes from highZ to huge R at new V
    else begin                             // otherwise bump at start of change
      if      (rval==Pval.R) rinc = 0;                 // constant R
      else if (rval<Pval.R)  rinc = -1e-7*Pval.R;      // decreasing R
      else                   rinc = 1e-7*(Pval.R+1);   // increasing R
      Pval = '{Pval.V+1e-11,Pval.I+1e-13,Pval.R+rinc}; // bump all coefs
    end
    Pval <= #(trns) '{vval,ival,rval};     // new point after risetime
  end
  @(vval,ival,rval);
end

assign P = Pval;              // drive to output net

// Compute measured current flowing through source (P to ground):
assign Imeas = (Pval.R>0)? (P.V-Pval.V)/Pval.R-Pval.I :  
               (Pval.R==0)? P.I : -Pval.I;

endmodule

