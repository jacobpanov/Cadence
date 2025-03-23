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

// CapGeq is a single-ended capacitor from P to ground.
// Parameters c and rs define capacitance and optional series resistance.
// Paremeter ic is the initial voltage on the capacitor at time zero.
// Parameters tinc & vtol control output updating.
//
// This model replaces the capacitor with an equivalent resistance over each
// timestep.  Current/Voltage relation over a timestep dT is:
//    Vcap = Vold + (dT/C)*(Icap+Iold)/2
// This can be implemented as equivalent voltage source plus series resistance:
//    Req = dT/2C
//    Veq = Vold+Iold*Req
// That is the model for the capacitor itself.  Any series resistance would be 
// added to Req when driving the output, so the internal capacitor voltage at
// any instant can be computed by:
//    Vcap = Vin - rs*Icap
// So this fits into the simple linear resistance format that is used already
// for EEnet evaluation.  Whenever the node voltage is updated, this function 
// will recompute Req and Veq based on the step from the previous timepoint.  
// Iterations at the same timepoint do not require any update to this element, 
// as it is only dependent on the previous timepoint value -- it just needs to
// save the final voltage at each timepoint for use in computations at the
// next timepoint.
//
// Model automatically updates its output every tinc seconds, and whenever an 
// external change causes the node to be reevaluated.
//
// Integration accuracy is determined by the relationship of Tinc to the 
// dominant time constant of the R-C interaction occuring.  Error increases 
// with increasing timestep size, limited by the assumption of linear variation
// of voltage and current over the step interval (actual response may be of
// decaying exponential format).  Generally error is good for Tinc<Tau/2 and 
// moderate for Tinc=Tau, but it will of course vary depending on application. 

// This model always starts with specified initial condition value at time zero,
// and is only accurate for use in systems with time constants greater than 
// about 0.7*Tinc.  For more comprehensive capabilities, see the CapGeq model 
// (adds DC op point evaluation and estimating response for smaller system Tau)
// and the CapGx model (includes variable-timestep-size selection based on Tau).

// Updated: 2017-05-30 (ronv)

`timescale 1ns/1ps
import EE_pkg::*;

module CapGeq1(P);
inout EEnet P;

parameter real c=1e-9;      // capacitance
parameter real rs=0;        // series resistance
parameter real ic=0;        // initial capacitor voltage at time zero
parameter real tinc=1e-9;   // timestep for computing voltage update (sec)

real Vcap,Tcap,Icap;        // voltage on capacitor @ time, and current
real Vold,Told,Iold;        // V,T,I at previous timepoint
real Veq,Req;               // equiv V & R for capacitor model over timestep

bit ck,cko;                 // internal clock to drive sampling
always begin :ckgen         // start resettable clock generator
  cko <= #(1step) ck;       // cko lags one resolution step behind ck
  #(tinc*1s) ck=!ck;        // clock changes after specified timestep
end

initial begin
  Vcap=ic; Tcap=0; Icap=0;       // fixed initial condition at time zero
  Vold=ic; Told=0; Iold=0;
  Veq=ic; Req=(rs==0)? 1e-3:rs;  // cap is near-ideal voltage at time zero
end

always @(P.V,ck) if (P.V<1e6) begin // on clock or input voltage change
  if ($realtime>Tcap) begin      // if forward timestep occured
    Iold = (Vcap-Veq)/Req;       // save last values at previous timepoint
    Vold = Vcap;
    Told = Tcap;
    Tcap = $realtime;            // save new time value
    Req = (Tcap-Told)/(2s*c);    // equiv resistance based on C and timestep
    Veq = Vold+Iold*(Req-rs);    // equiv voltage based on previous V&I
    Req = Req+rs;                // add series resistance to Req term
    if (ck==cko) disable ckgen;  // reset clock generator on external event
  end
  Vcap = P.V;                    // update saved voltage & current values
  Icap = (P.V-Veq)/Req;
end

// Drive equivalent voltage & resistance onto output pin:
assign P = '{Veq,0,Req};

endmodule
