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

// SwitD (P,N,en) - EEnet fully diffl switch (uses EEIO for port access).
// Parameter ron defines resistance when enabled, else roff.
// Parameter vos defines offset voltage from P to N.
// If risetime specified, makes small change to resistance when en changes,
//  then changes to the new ron or roff after the risetime interval.
// Optional rform flag will add extra timepoints at 10%, 50%, and 90% of the way 
//  through the transition interval to provide better consistency when switching 
//  in capacitive or inductive circuits.  This will also map nicely to the way
//  that the electrical equivalent for this module, ESwitD, will transition the
//  resistance over the interval in the electrical circuit.
// If no risetime specified, any feedback from output to enable control could
//  cause repeating iterations to occur.  Model will stop oscillating and print 
//  a warning message when more than itermax iterations occur at a timepoint.

// Updated 2020-06-04 (ronv) Cadence Design Systems, Inc.

`timescale 1ns/1ps

// Shorthand for standard real constants:
`ifdef EEX
`else
 `define Z `wrealZState
 `define X `wrealXState
 `define EEZ '{0.0, 0.0, `Z}
 `define EEX '{`X, 0.0, `X}
`endif

module SwitD  import EE_pkg::*;  (
  inout EEnet P,N,    // differential EEnet nets
  input en );         // enable signal

parameter real ron=10;          // on resistance of switch
parameter real roff=1e13;       // off resistance of switch (default is `Z)
parameter real vos=0;           // offset voltage when conducting
parameter real tr=0;            // (sec) risetime for enable input change
// Resistive transition parameters:
parameter integer rform=0;      // =1 will add points at 10%/50%/90% of transition
parameter real rxon=(ron>0.1)? $sqrt(ron*1e4):30;  // near-on point (>=30ohms)
parameter real rxoff=(roff<5e9)? $sqrt(roff*2e4):1e7;  // near-off (<=10Mohms)
parameter real rxctr=$sqrt(rxon*rxoff);  // midpoint between rxon & rxoff
parameter real rwig=1e-7;       // ron relative inc to force point before risetime
// EEIO update control parameters:
parameter real vtol=1e-4;       // output voltage update tolerance
parameter real itol=1e-9;       // output current update tolerance
parameter real itermax=20;      // max iterations at one timepoint

real Rdrv,Rnew;                 // present and new value for drive resitance
real Roff;                      // off resistance 
real Ronth,Roffth;              // "bumped" R values for start of ramp

initial begin
  Roff = (roff<1e13)? roff:`Z;  // off state resistance (default is Z if not set)
  Rdrv = Roff;                  // initially set to off state
  Ronth = ron+rwig*(ron+1);     // incremented version of ron
  Roffth = roff*1e10/(roff+1e10); // decremented version of roff
end

// Process rise time:
real trns=0;                   // no delay at time zero
event err0;                    // flag indicates leaving DC op with en=X
initial begin
  #(1step) trns=tr*1s;         // delay by tr thereafter (convert to nanoseconds)
  if ((en|!en)!==1'b1) ->err0; // raise flag if enable not yet set
end

EEstruct Pdrv = `EEZ;   // drive to apply to P net (initially all in Z state)
EEstruct Pext = `EEZ;   // measured external drive from P net
EEstruct Ndrv = `EEZ;   // drive to apply to N net
EEstruct Next = `EEZ;   // measured external drive from N net

EEIO  #(.vtol(vtol), .itol(itol), .itermax(itermax))
  DP(P, Pdrv, Pext), DN(N, Ndrv, Next);   // Drive & measure P & N nets

real Imeas;                   // computed current flow (P-to-N)
real Tchg;                    // time of last input update
int Iter,IterERR;             // update counter

// Process enable input - convert to resistor changes:
always begin
  if ($realtime>Tchg) begin        // when starting a new timestep
    Iter=0;                        //  initial pass is Iter=0
    Tchg=$realtime;                //  save time value for next check
  end
  else Iter++;                     // bump iteration counter
  if (Iter<=itermax) begin         // if within iteration limit:
    if (en)                       Rnew = ron;  // en=1 so turn on
    else if (!en || $realtime==0) Rnew = Roff; // en=0 (or X at t=0) so turn off
    else                          Rnew = `X;   // en=X at t>0 so output X
    if (trns>0) begin              // if risetime specified:
      Rdrv = (Rdrv<=Ronth)? Ronth : Roffth;    // bump at start of risetime
      if (rform && (en|!en) && Rdrv!==`X) begin// if adding interim points:
        Rdrv <= #(0.1*trns) en? rxoff:rxon;    //  small change at 10%
        Rdrv <= #(0.5*trns) rxctr;             //  then center at 50% 
        Rdrv <= #(0.9*trns) en? rxon:rxoff;    //  and near-done at 90%
      end
      Rdrv <= #(trns) Rnew;                    // then update after risetime
    end
    else Rdrv = Rnew;              // else no risetime, so immediate update
  end                              // do nothing after iter limit
  else if (Iter==itermax+1) begin  // if too many iters:
    IterERR++;                     //  bump error flag & print warning
    $display("<ERROR> %M (%1d) SwitD enable iteration limited at T=%.3fns",
                        IterERR,                               $realtime/1ns);
  end
  @(en,err0);
end

always begin                     // Update Ndrv when enable or Pext changes
   if (Rdrv<1e13)                //  pass values when resistive value specified
         Ndrv = '{Pext.V-vos, Pext.I, Pext.R+Rdrv};
   else  Ndrv = `EEZ;            // else Z & X both map to Z state here
   @(Rdrv,Pext.V,Pext.I,Pext.R); // repeat when enable or input changes
end

always begin                     // Update Ndrv when enable or Pext changes
   if (Rdrv<1e13)                //  pass values when resistive value specified
         Pdrv = '{Next.V+vos, Next.I, Next.R+Rdrv};
   else  Pdrv = `EEZ;            // else Z & X both map to Z state here
   @(Rdrv,Next.V,Next.I,Next.R); // repeat when enable or input changes
end

// Measure current flow from P to N:
assign Imeas = DP.Imeas;

endmodule
