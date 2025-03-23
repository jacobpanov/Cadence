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

// Differential EEnet capacitor implemented with VRsrc & CapGx models.
// VRsrc connects between differential nodes, measures the current, and
// passes it to the CapGx model to compute voltage and resistance, which 
// is passed back to the VRsrc model to apply to the differential input.
// Since the CapGx internal RxExt is always set from above, it is always
// in the adaptive mode.

// Updated: 2020-06-10 (ronv)

`timescale 1ns/1ps
import EE_pkg::*;

module  CapDx(P,N);
inout EEnet P,N;  // differential pins to capacitor
EEnet DV;         // single-ended version of capacitor voltage
real Icap;        // current flowing through the capacitor
real Vd,Rd;       // voltage & resistance to drive CapG due to DC op point

parameter real c=1e-9;      // capacitance
parameter real rs=0;        // series resistance
parameter real ic=1e9;      // initial voltage at time zero (or big uses DCOP)
parameter real reltol=0.01; // relative error tolerance (stepsize control vs. V)
parameter real vtol=1e-4;   // voltage tolerance.
parameter real tmin=1e-11;  // minimum timestep (sec) (when external R tiny)
parameter real tmax=1e-7;   // maximum timestep (sec) (when external R huge)
parameter real itermax=20;  // max iterations at one timepoint.
parameter real rtol=0.1;    // output resistance update tolerance
parameter real itol=1e-9;   // output current update tolerance

// drive voltage Vcap from cap model and series rs back to differential input:
VRsrcD  #(.itermax(itermax),.vtol(vtol),.tr(0), .rtol(rtol), .itol(itol)) 
   VC(.P, .N, .vval(CD.Veq), .rval(CD.Req), .imeas(Icap));

// drive current into capacitor model (X&Z map to zero, or at DC measure V):
assign DV = '{Vd, (Icap<1e6)? Icap:0.0, Rd}; 

// capacitor model converts from input current to output voltage:
CapGx #(.c(c), .rs(rs), .ic(ic), .reltol(reltol), .vtol(vtol), 
        .tmin(tmin), .tmax(tmax) )  CD(DV);

// Pass DC voltage to capacitor at time zero when using no initial condition:
initial if (ic<1e9) Rd = 1e12;  // with IC, cap works same at DC as transient.
else begin                      // with no IC, pass in voltage at time zero:
  Rd = 1e3;                     // set moderate R (cap is 1e12 ohms at DC)
  while ($realtime==0) begin        // update on each voltage change
    if (P.V-N.V<1e9) Vd = P.V-N.V;  // pass DC diffl voltage to cap
    @(P.V,N.V);                     // repeat at each DC input voltage change
  end
  Vd = 0; Rd = 1e12;            // then go to current-only drive when T>0
end

initial                         // get external R to pass to cap:
 forever @(VC.Pext.R,VC.Next.R) CD.RxExt = VC.Pext.R+VC.Next.R;

endmodule
