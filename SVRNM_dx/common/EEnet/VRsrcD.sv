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

// VRsrcD.sv - EEnet differential V+R model for use between two EEnet nodes

// This module connects a resistor and voltage source in series between
// two EEnet nodes.  Nets are driven and the external drive to them is
// computed using the EEIO module (one for each node), which also performs 
// tolerance and iteration limiting so that only significant external
// changes will be passed through this module.

// Given those operations, this module's computation is very simple:
// it measures the external drive on one side, adds the specified voltage
// and resistance to that measurement, and drives the resulting value to 
// the other side.  If the V+R to be added is X or Z, both sides will just
// be driven with X or Z respectively.

// Net imeas monitors the current flow through the device (P-to-N).  
// Values for vval&rval are applied after specified tr interval.

//     Updated:  2019-12-06 (ronv) always bump R at start of R ramp

import EE_pkg::*; 

// Shorthand for standard real constants:
`ifdef EEX
`else
 `define Z `wrealZState
 `define X `wrealXState
 `define EEZ '{0.0, 0.0, `Z}
 `define EEX '{`X, 0.0, `X}
`endif

module VRsrcD (inout EEnet P,N, input real vval,rval, output real imeas);

parameter real vtol=1e-5;     // output voltage update tolerance
parameter real itol=1e-9;     // output current update tolerance
parameter real rtol=0.1;      // output resistance update tolerance
parameter real itermax=20;    // max iterations at one timepoint
parameter real rz=1e13;       // resistance to treat as Z
parameter real tr=0;          // (sec) risetime for vval&rval changes
parameter real vwig=1e-9;     // wiggle to force change at start of risetime

real trns=0;                  // no delay at time zero
initial #(1step) trns=tr*1s;  // delay by tr thereafter (convert to nanoseconds)

real Iout;                    // computed current flow (P-to-N)

EEstruct Pdrv = `EEZ;   // drive to apply to P net
EEstruct Pext = `EEZ;   // measured external drive from P net
EEstruct Ndrv = `EEZ;   // drive to apply to N net
EEstruct Next = `EEZ;   // measured external drive from N net

EEIO  #(.vtol(vtol), .itol(itol), .rtol(rtol), .rz(rz), .itermax(itermax))
  DP(P, Pdrv, Pext), DN(N, Ndrv, Next);   // Drive & measure P & N nets

real Vval,Rval=1e13;               // copies of vval&rval with risetime added
always begin
  if (trns==0) begin               // if no risetime, change V&R immediately
    Vval = vval;                   //   update V directly
    Rval = (rval<rz)? rval : `Z;   //   map rval>=rz to Z level
  end
  else begin                       // with risetime, add point to start ramp
    Vval+=1e-11;                            // tiny voltage bump
    if (Rval===`Z && rval!==`Z) Rval=rz/2;  // if leaving Z state, go to rz/2
    else if (Rval!=rval || Rval>1e3)        // else if changing or large R
      Rval+=(rval>Rval?1:-1)*1e-7*(1+Rval); //  bump resistance value
    Vval <= #(trns) vval;                   // update after risetime interval
    Rval <= #(trns) (rval<rz)? rval : `Z;   // map rval>=rz to Z level
  end
  @(vval,rval);                    // repeat on next input change
end

always_comb                        // update drive to N net
  if (Vval<1e12 && Rval>=0)  Ndrv = '{Pext.V-Vval, Pext.I, Pext.R+Rval};
  else if ((Vval===`Z) || (Rval===`Z))  Ndrv = `EEZ;
  else                                  Ndrv = `EEX; 

always_comb                        // update drive to P net
  if (Vval<1e12 && Rval>=0)  Pdrv = '{Next.V+Vval, Next.I, Next.R+Rval};
  else if ((Vval===`Z) || (Rval===`Z))  Pdrv = `EEZ;
  else                                  Pdrv = `EEX; 

// Compute current flow from P to N:
always @(DP.Imeas) if (DP.Iter==0 || abs(DP.Imeas-Iout)>itol) Iout = DP.Imeas;
always @(DN.Imeas) if (DN.Iter==0 || abs(DN.Imeas+Iout)>itol) Iout = -DN.Imeas;

assign imeas = Iout;                    // drive measured current output   

endmodule
