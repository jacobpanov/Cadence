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

// IndDeq0 is a differential inductor from P to N.
// Parameters l and rs define inductance and optional series resistance.
// Parameter ic is the initial current through the inductor at time zero.
// Parameter tinc is the sample update timestep.
//
// This model replaces the inductor with an equivalent voltage and resistance
// over each timestep.  Current/Voltage relation over a timestep dT is:
//    Iind = Iold + (dT/L)*(Vind+Vold)/2
// This can be implemented as equivalent current source plus series resistance:
//    Req = 2L/dT
//    Ieq = Iold+Vold/Req
// That is the model for the inductor itself. Series resistance adds to that,
// after converting to V+R format:
//    Vdr = -Ieq*Req
//    Rdr = Req+rs
// Given the external voltage, the current and internal inductor voltage are:
//    Iind = (Vdif-Vdr)/Rdr
//    Vind = Vdif - rs*Iind
// So this still fits into the simple linear resistance format that is used 
// already for EEnet evaluation.  Whenever a node is updated, this function 
// will recompute Vdr and Rdr based on the step from the previous timepoint.  
// Iterations at the same timepoint do not require any update to this element, 
// as it is only dependent on the previous timepoint value -- it just needs to
// update the saved values at that timepoint for use in computations at the
// next timepoint.
//
// Model updates whenever either net changes and every tinc seconds.

import EE_pkg::*;

module IndDeq0 (inout EEnet P,N);   // differential inductor model

parameter real l=1e-6;      // inductance
parameter real rs=0;        // series resistance
parameter real ic=0;        // initial current at time zero
parameter real tinc=1e-9;   // timestep for computing voltage update (sec)
parameter real itermax=20;  // EEIO coefs: max iterations at one timepoint
parameter real vtol=1e-4;   //  voltage tolerance (V)
parameter real itol=1e-9;   //  current tolerance (A)

real Vdif;                  // differential input voltage
real Iind,Tind,Vind;        // current thru inductor @ time, and voltage
real dT;                    // timestep size
real Ieq,Req;               // equiv I+R for inductor model over timestep
real Vdr,Rdr;               // V+R driving the differential output
EEstruct Pdrv,Pext,Ndrv,Next; // structs for drive & measure EEIO signals   
bit ck=0; 	                // internal clock to drive sampling

always #(tinc*1s) ck=!ck;	// clock changes every tinc seconds

// Get external drives values & drive with internal computed values:
EEIO  #(.vtol(vtol), .itol(itol), .itermax(itermax))
  DP(P, Pdrv, Pext), DN(N, Ndrv, Next);

// Define differential drive to EEIO blocks based on Vdr & Rdr:
assign Ndrv = '{Pext.V-Vdr, Pext.I, Pext.R+Rdr};
assign Pdrv = '{Next.V+Vdr, Next.I, Next.R+Rdr};
assign Vdif = P.V-N.V;      // measure differential input

initial begin               // DC op point:
  Ieq=ic; Req=1e9;          // ideal current drive with high impedance
  Vdr=-ic*1e9; Rdr=1e9;     // specify as V/R for this implementation
end

always @(Vdif,ck) if (Vdif<1e6) begin  // on clock or input voltage change
  if ($realtime>Tind) begin // if forward timestep occurred
    dT   = $realtime-Tind;  // compute timestep
    Tind = $realtime;       // save present time
    Req  = (2s*l)/dT;       // update I+R model for inductor over timestep
    Ieq  = Iind+Vind/Req;   // Ieq is based on old V&I values
    Vdr  = -Ieq*Req;        // compute output drive V+R
    Rdr  = Req+rs;          // including series resistance term
  end
  Iind = (Vdif-Vdr)/Rdr;    // save V&I on all iterations
  Vind = Vdif-rs*Iind;
end
endmodule

