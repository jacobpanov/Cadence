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

// EEnet capacitor model - uses standard trapezoidal integration method
// (SPICE element stamp format) for proper voltage/current interaction.
// Accuracy dependent on ratio of specified timestep size tinc to the
// system's effective time constant (quadratic dependence).

import EE_pkg::*;

module CapGeq0(inout EEnet P);// EEnet model for a capacitor

parameter real c=1e-9;        // capacitance value
parameter real rs=0;          // optional series resistance
parameter real ic=0;          // initial capacitor voltage at time zero
parameter real tinc=1e-9;     // timestep for updates (sec)

real Vcap,Tcap,Icap,Vold,Told,Iold;  // V,T,I now and previous
real Veq,Req;                 // equiv V & R for this timepoint

reg ck=0;                     // internal clock to drive sampling
always #(tinc*1s) ck=!ck;     // changes every tinc seconds

initial begin                 // initialize all non-zero real variables
  Vcap=ic; Vold=ic; Veq=ic; Req=(rs==0)? 1e-3:rs;
end

always @(P.V,ck) if (P.V<1e6) begin  // on clock or input voltage change
  if ($realtime>Tcap) begin   // if forward timestep occurred
    Iold = Icap;              // save last values at previous timepoint
    Vold = Vcap; Told = Tcap;
    Tcap = $realtime;         // save new timepoint value
    Req = (Tcap-Told)/(2s*c); // equiv resistance based on C and timestep
    Veq = Vold+Iold*(Req-rs); // equiv voltage for form of V1=Vout+I1*Rout
    Req = Req+rs;             // add series resistance to Req term
  end
  Vcap = P.V;  Icap = (P.V-Veq)/Req; // update voltage & current values
end

assign P = '{Veq,0,Req};      // Drive equivalent V&R to output pin

endmodule

