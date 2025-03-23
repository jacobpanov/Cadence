// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2014, Cadence Design Systems, Inc. All rights reserved.

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

// Isrc is a differential unidirectional passive current source from P to N.
// Input ival defines the current.  Current ival will flow from P to N when
// the voltage from P to N is at least dv=0.1V.  If ival is zero or negative,
// the value of imin will be used instead.  For lower voltages, the current 
// will be replaced by a resistor of size (dv/ival).
//
// This block expects one side (P or N) to be at a low impedance to simplify
// the math used:  It doesn't attempt to fully mirror impedances between the
// P and N nodes, so if both sides include significant impedances, iteration  
// issues may occur when the differential voltage drops below dv.
//
// General form:
//   If V(P,N)>dv then IP=-ival, IN=ival, RP=RN=rp
//   else              VP=VN, VN=VP, RP=RN=(dv/ival)
//     where ival will be replaced with imin if current is small or negative.

// Updated: 2017-05-15 (ronv)

`timescale 1ns/1ps
import EE_pkg::*;

module  Isrc_ideal (P,N,ival);
inout EEnet P,N;
input real ival;

parameter real tr=0;          // risetime for input current change (seconds)
parameter real Kinc=1e-6;     // fractional change at start of ramp
parameter real rp=1e12;       // output resistance (may be needed for convergence)

real Ia,dI,Ival;              // input current value with risetime
real trt;                     // risetime value in timescale units
real Idrv,Rdrv;               // drive I & R
real Vp, Vn;                  // Placeholders for terminal voltages

initial begin 
  trt=0;              // no risetime at time zero
  #(1step) trt=tr*1s; // risetime converted to timescale
  Ival  = 0;          //must start at 0
end

// Update Ival, including optional risetime:
always begin
  Ia = ((ival !== `wrealZState) && (ival !== `wrealXState)) ? ival : 0;     // filter x and z inputs
  dI = abs(Ia-Ival);               // actual change of current
  if (trt>0 && dI>0) Ival += Kinc*dI;  // bump by fraction of change
  if (trt>0)
     Ival <= #(trt) Ia;               // change after risetime
  else
     Ival = Ia;
  @(ival);
end


always begin
         // current output mode
    Idrv <= Ival;     // allow positive-only current

    @(Ival);          // update on drive change
end

always @ (P.V or N.V)
   begin
      Vp = P.V;   //Internal tracking variables
      Vn = N.V;
   end

assign P = '{0, -Idrv, rp};
assign N = '{0,  Idrv, rp};

endmodule

