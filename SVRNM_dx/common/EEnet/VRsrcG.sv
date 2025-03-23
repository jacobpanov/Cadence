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

// VRsrcG is a single-ended voltage source with resistance from P to ground.
// Inputs vval and rval define the voltage and current.
// Output imeas is the returned value of the current flowing (PtoGND) through 
// the source, so positive supply current is usually a negative number.
// Optional risetime specification provides trivial change to value at time
// of input change, followed by full change after risetime.  This allows for
// response to mirror analog response with point on both ends of transition.

// Updated: 2017-03-20 (ronv) added rval input & tr param

`timescale 1ns/1ps
import EE_pkg::*;

// Shorthand for standard real constants:
`define Z `wrealZState
`define X `wrealXState

module  VRsrcG(P,vval,rval,imeas);
inout EEnet P;
input real vval,rval;
output real imeas;


parameter real tr=0;          // risetime for analog changes (seconds)
parameter real Kinc=1e-6;     // fractional change at start of ramp

real Vval,Rval;               // V,R values to pass to node
real trt;                     // risetime value in timescale units

initial begin
  trt=0;                      // no risetime at time zero
  #(1step) trt=tr*1s;         // risetime converted to timescale
end

// update Vval & Rval when input, including special cases and opt risetime:
always begin
  if (vval<1e12 && rval>=0) begin             // normal drive
    if (trt>0) begin                                 // if risetime included:
      if (Rval===`Z)       Rval=1e10;                //  leaving high-Z region
      else if (vval!=Vval) Vval += Kinc*(vval-Vval); //  bump V slightly
      else if (rval<Rval)  Rval -= Kinc*(Rval+1);    //  bump R slightly 
      else                 Rval += Kinc*(Rval+1);    //   in proper direction
    end
    Vval <= #(trt) vval;      // change to new values after risetime
    Rval <= #(trt) rval;
  end
  else if ((vval===`Z) || (rval===`Z)) begin  // going to high Z drive
    if (trt>0) Rval += Kinc*(Rval+1);         // if risetime, bump R value
    Rval <= #(trt) `Z;                        // change to Z state
    Vval <= #(trt) 0;                         // V not used when R=Z
  end
  else begin                            // going to invalid drive         
    if (trt>0) Rval += Kinc*(Rval+1);   // if risetime, bump R first
    Rval <= #(trt) `X;                  // change to X state
    Vval <= #(trt) `X;
  end
  @(vval,rval);
end

// Drive voltage & resistance onto output pin:
assign P = '{Vval,0,Rval};

// Return measured current flowing through source (P to ground):
assign imeas = (Rval==`Z)? 0 : (Rval==0)? P.I : (P.V-Vval)/Rval;

endmodule