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

// IndD is a differential inductor from P to N.
// Parameters l and rs define inductance and optional series resistance.
// Parameter ic is the initial current through the inductor at time zero.
// Default ic value of 1e9 indicates inductor treated as short at DC op point.
// Parameters tinc & itol control output updating.
//
// This model replaces the inductor with an equivalent resistance over each
// timestep.  Current/Voltage relation over a timestep dT is:
//    Iind = Iold + (dT/L)*(Vind+Vold)/2
// This can be implemented as equivalent current source plus series resistance:
//    Req = 2L/dT
//    Ieq = Iold+Vold/Req
// That is the model for the inductor itself. Series resistance adds to that,
// after converting to V+R format:
//    Vdr = -Ieq*Req
//    Rdr = Req+rs
// Given the external voltage, the current and internal inductor voltage are:
//    Iind = (Vin-Vdr)/Rdr
//    Vind = Vin - rs*Iind
// So this still fits into the simple linear resistance format that is used 
// already for EEnet evaluation.  Whenever a node is updated, this function 
// will recompute Vdr and Rdr based on the step from the previous timepoint.  
// Iterations at the same timepoint do not require any update to this element, 
// as it is only dependent on the previous timepoint value -- it just needs to
// update the saved values at that timepoint for use in computations at the
// next timepoint.
//
// Model automatically updates whenever either net changes, or every tinc
// seconds if no external changes occur.  But if either external net goes to
// a high impedance state, model will update at a rate equal to the time 
// constant Tau=L/Rext, until the voltage across the inductor drops to below
// the voltage tolerance vtol.  This should limit issues with switches abruptly
// turning off (resulting in rapid voltage pulse discharging the inductor).

// Updated: 2020-05-26 (ronv)  Fix DC op with specified IC current

import EE_pkg::*;

// Shorthand for standard real constants:
`ifdef EEX
`else
 `define Z `wrealZState
 `define X `wrealXState
 `define EEZ '{0.0, 0.0, `Z}
 `define EEX '{`X, 0.0, `X}
`endif

module IndD (inout EEnet P,N);   // diffl inductor model

parameter real l=1e-6;      // inductance
parameter real rs=0;        // series resistance
parameter real ic=1e9;      // initial current at time zero (or big uses DCOP)
parameter real tinc=1e-9;   // timestep for computing voltage update (sec)
parameter real tmin=1e-12;  // minimum timestep when limiting at big R
parameter real vtol=1e-4;   // voltage tolerance (V)
parameter real itol=1e-9;   // current tolerance (A)
parameter real rtol=0.1;    // output resistance update tolerance
parameter real itermax=20;  // max iterations at one timepoint for EEIO

real Vin;                   // instantaneous differential input voltage
real Iind,Tind,Vind;        // current thru inductor @ time, and voltage
real dT;                    // timestep size
real Ieq,Req;               // equiv I+R for inductor model over timestep
real Vdr,Rdr;               // V+R driving the differential output
real Rext;                  // total external resistance connected to inductor
real Rxth,Rxmax;            // output resistance timestep threshold & max bound
real td,tdnow;              // clock delay parameter and present value

initial begin
  Rxth = 1.5*l/tinc;        // external resistance that requires step limiting
  Rxmax = l/tmin;           // external resistance resulting in minimum timestep
  td = tinc*1s;             // initialize to default timestep size
end

// Continuously running cancellable timer (posedge(ck)):
bit ck,ckx;
assign cka=ck;
always begin:ckgen
  ck = 1'b0;         // normally zero
  wait (td>0);       // wait for nonzero delay
  tdnow=td;          // save delay value
  #(td);             // wait for specified delay
  ck = 1'b1;         // timer event is posedge
  wait (cka);        // wait for clock to propagate out before continuing
end

EEstruct Pdrv = `EEZ;   // drive to apply to P net
EEstruct Pext = `EEZ;   // measured external drive from P net
EEstruct Ndrv = `EEZ;   // drive to apply to N net
EEstruct Next = `EEZ;   // measured external drive from N net

// Get external drives values & drive with internal computed values:
EEIO  #(.vtol(vtol), .itol(itol), .rtol(rtol), .itermax(itermax))
  DP(P, Pdrv, Pext), DN(N, Ndrv, Next);

// Define differential drive with value Vdr+Rdr:
assign Ndrv = '{Pext.V-Vdr, Pext.I, Pext.R+Rdr};
assign Pdrv = '{Next.V+Vdr, Next.I, Next.R+Rdr};

initial begin                     // Handle DC op point evaluation
  if (ic<1e9) begin
    Ieq=ic; Req=1e9;              // ideal drive with high impedance
    Rdr=1e9; Vdr=ic*Rdr;          // specify as V/R for this implementation
  end
  else begin
    Ieq=0; Req=0;                 // Inductor shorted at DC, so
    Vdr=0; Rdr=(rs>0)? rs:1e-3;   // use rs, or small value if no rs specified
    while ($realtime==0) begin    // repeat until non-zero input time
      @(P.V,N.V,ck);              // wait for event 
      Vin = P.V-N.V;              // get differential input voltage
      Iind = (Vin-Vdr)/Rdr;       // convert to inductor current & voltage
      Vind = Vin-rs*Iind;
    end
  end
  forever begin                   // MAIN LOOP (starts after DC op completed)
    if ($realtime>Tind) begin     // if new timepoint
      if (Vin<1e12) begin         // update only on valid new point (ignore X)
        dT = $realtime-Tind;      // compute timestep
        Req = (2s*l)/dT;          // update I+R model for inductor over timestep
        Ieq = Iind+Vind/Req;      // Ieq is based on old V&I values
        Iind = (Vin-Vdr)/Rdr;     // convert to inductor current & voltage
        Vind = Vin-rs*Iind;
        Vdr = -Ieq*Req;           // compute output drive V+R
        Rdr = Req+rs;
        Rext = Pext.R+Next.R;     // check external resistance total value
        if (Rext>Rxth && abs(Vdr)>vtol)      // if L/R forces small timesteps,
          if (Rext>Rxmax) td = 1s*tmin;      // minimum stepsize
          else            td = (1s*l)/Rext;  // larger-Rext stepsize
        else td=1s*tinc;                     // normal stepsize
        if (!ck || td!=tdnow) disable ckgen; // reset timer
      end
    end
    else begin        // iteration at same timepoint, so just update I&V 
      Iind = (Vin-Vdr)/Rdr;
      Vind = Vin-rs*Iind;
      Rext = Pext.R+Next.R;               // check external resistance value
      if (Rext>Rxth && abs(Vin)>vtol)     // if L/R forces small timesteps,
        if (Rext>Rxmax) td = 1s*tmin;     // minimum stepsize
        else            td = (1s*l)/Rext; // larger-Rext stepsize
      else td=1s*tinc;                    // normal stepsize
      if (td!=tdnow) disable ckgen;       // reset clock gen on td change
    end
    Tind = $realtime;             // save present time
    @(P.V,N.V,posedge(ck));       // repeat on clock or input change
    Vin = P.V-N.V;                // update differential input voltage
  end
end

endmodule
