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
// SwitG (P,Vn,en) - EEnet single-ended switch to specified Vin.
// Parameters ron and roff define resistance when en=1 and en=0.
// If en is X or Z, drives to Z at time 0, X thereafter.
// If risetime specified, makes small change to resistance when en changes,
//  then changes to the new ron or roff after the risetime interval.
// Optional rform flag will add extra timepoints at 10%, 50%, and 90% of the way 
//  through the transition interval to provide better consistency when switching 
//  in capacitive or inductive circuits.  This will also map nicely to the way
//  that the electrical equivalent for this module, ESwitD, will transition the
//  resistance over the interval in the electrical circuit.
// Vn feeds through immediately (no risetime effect from voltage input).
// If no risetime specified, any feedback from output to enable control could
//  cause repeating iterations to occur.  Model will stop oscillating and print 
//  a warning message when more than itermax iterations occur at a timepoint.

// Updated 2020-06-04 (ronv) added risetime operation

`timescale 1ns/1ps

// Shorthand for standard real constants:
`ifdef EEX
`else
 `define Z `wrealZState
 `define X `wrealXState
 `define EEZ '{`Z, 0.0, `Z}
 `define EEX '{`X, 0.0, `X}
`endif

module SwitG  import EE_pkg::*;  (
  output EEnet P,   // EEnet net (driven when enabled)
  input real Vn,    // real input voltage
  input en );       // enable

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
// iteration control parameter:
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

real Imeas;                   // current flowing through switch
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
    $display("<ERROR> %M (%1d) SwitG enable iteration limited at T=%.3fns",
                        IterERR,                               $realtime/1ns);
  end
  @(en,err0);
end

assign P = '{Vn+vos,0,Rdrv};  // drive net with computed resistance & voltage

// Compute current flow from P to gnd whenever net is updated:
always @(P.V,P.I,P.R)  
   if (Rdrv==0)         Imeas = P.I;                  // ron=0
   else if (Rdrv<1e13)  Imeas = (P.V-(Vn+vos))/Rdrv;  // normal I=V/R
   else                 Imeas = 0;                    // no current if Z or X

endmodule

