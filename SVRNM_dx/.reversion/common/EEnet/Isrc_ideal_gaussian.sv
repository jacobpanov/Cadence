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
// Derived from Isrc 2019-04-08 (danielcr) Using gaussian moving average to smooth
//  output changes

`timescale 1ns/1ps

`ifndef M_TWO_PI
`define M_TWO_PI 6.28318530717958647652
`endif

import EE_pkg::*;

module  Isrc_ideal_gaussian (P,N,ival);
inout EEnet P,N;
input real ival;

parameter real tr=(1/50e6);   // sample period for input change filter (seconds)
parameter real Kinc=1e-6;     // fractional change at start of ramp
parameter real rp=1e12;       // output resistance (may be needed for convergence)
parameter real tol = 1e-9;    // Threshold for activating filter
parameter real alpha = 0.5;   // Gaussian Filter parameter

real Ia,dI,Ival;              // input current value with risetime
real trt;                     // risetime value in timescale units
real Idrv,Rdrv;               // drive I & R
real Vp, Vn;                  // Placeholders for terminal voltages

real xin[6:0]; // 7 deep
real hg[6:0];
real coeff1;   //Normalization constant
real coeff2 [6:0]; // varying gaussian coefficient
reg  filtClk = 1'b0;
reg  filtOn = 1'b0;
event startFiltClk, stopFiltClk;

initial begin 
  trt=0;              // no risetime at time zero
  #(1step) trt=tr*1s; // risetime converted to timescale
  Ival  = 0;          //must start at 0

 // initialize filter
  hg = '{0.0,0.0,0.0,0.0,0.0,0.0,0.0};
// normalization constant determined empirically
  coeff1 = 0.989739190193443/$sqrt(`M_TWO_PI * alpha); 

  coeff2[0] = $exp(-(3**2)/(2*alpha));
  coeff2[1] = $exp(-(2**2)/(2*alpha));
  coeff2[2] = $exp(-(1**2)/(2*alpha));
  coeff2[3] = $exp(-(0**2)/(2*alpha));
  coeff2[4] = $exp(-(1**2)/(2*alpha));
  coeff2[5] = $exp(-(2**2)/(2*alpha));
  coeff2[6] = $exp(-(3**2)/(2*alpha));
end

// Update Ival, including optional risetime:
always @(ival or (posedge filtClk)) begin
  Ia = ((ival !== `wrealZState) && (ival !== `wrealXState)) ? ival : 0;     // filter x and z inputs
  dI = abs(Ia-Ival);               // actual change of current
//  if (trt>0 && dI>0) Ival += Kinc*dI;  // bump by fraction of change
  if ( (trt>0) && (dI>tol) && (filtOn == 1'b0) ) // If tolerance exceeded and filter not on
    begin
       filtOn = 1'b1;
       -> startFiltClk;   //Turn the filter on
    end
  else if ( (trt>0) && (dI>tol) && (filtOn == 1'b1) ) // If filter already on
    begin
       Ival <= hg[0];
    end
  else if ( (trt>0) && (dI<tol) && (filtOn == 1'b1) ) // If filter already on, but output converged
    begin
       Ival <= Ia;
       -> stopFiltClk;
       filtOn = 1'b0;
    end
  else // if trt <= 0;
    Ival <= #(trt) Ia;               // change after risetime

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

always @ (posedge filtClk) begin
   xin[6] = xin[5];
   xin[5] = xin[4];
   xin[4] = xin[3];
   xin[3] = xin[2];
   xin[2] = xin[1];
   xin[1] = xin[0];
   xin[0] = Ia;
   hg[6] = xin[6]*coeff1*coeff2[6];
   hg[5] = xin[5]*coeff1*coeff2[5];
   hg[4] = xin[4]*coeff1*coeff2[4];
   hg[3] = xin[3]*coeff1*coeff2[3];
   hg[2] = xin[2]*coeff1*coeff2[2];
   hg[1] = xin[1]*coeff1*coeff2[1];
   hg[0] = xin[0]*coeff1*coeff2[1] + hg[1] + hg[2] + hg[3] + hg[4] + hg[5] + hg[6];
end

  // This block generates the filter clock. It is activated and deactivated
  // via the two events startFiltClk and stopFiltClk.
  always
  fork
  begin : filtClkGen
     filtClk = 1'b0; // Starts at 0
     @startFiltClk forever
        #(trt/2) filtClk = ~filtClk;
  end
  @stopFiltClk disable filtClkGen;
  join

endmodule

