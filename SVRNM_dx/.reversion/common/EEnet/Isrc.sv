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
// Input ival defines nominal current.  Current ival will flow from P to N when
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
//   If V(P,N)>dv then IP=-ival, IN=ival, Rdrv=rp
//                else Rdrv=(dv/ival)||rp = dV/(ival+dv/rp)
//   where ival will be replaced with imin if current is small or negative.
//   Voltage at each side will drive the other side, but they will only be 
//   updated when changed by at least imin*Rdrv (That will keep from forcing
//   differential updates on small voltage changes in constant-current mode).
//   Saturation threshold also includes hysteresis of vtol to help supress  
//   possible oscillations when signals are changing close to the threshold.

// Updated: 2017-12-09 (ronv)

`timescale 1ns/1ps
import EE_pkg::*;

module  Isrc(P,N,ival);
inout EEnet P,N;
input real ival;

parameter real tr=0;        // risetime for input current change (seconds)
parameter real dv=0.1;      // min voltage drop for full current flow
parameter real rp=1e14;     // output resistance (default uses `Z)
parameter real imin=1e-12;  // minimum current flow
parameter real vtol=1e-4;   // voltage tolerance for V update

real roff,ip;               // terms in resistor value calculation
real vmin;                  // minimum significant differential voltage change
real Ia,dI,Ival;            // input current value with risetime
real trt;                   // risetime value in timescale units
real Vp,Vn;                 // input voltages, sampled as needed
real Idrv,Rdrv;             // drive I & R
bit Rmode;                  // mode flag: 0=current mode, 1=resistive mode
int Niter,Nerr;             // iteration bounds: iter per timept & errors
real Tchg;                  // time of input signal change

initial begin
  Ival=imin;                // initial value for drive current
  if (rp<1e14) begin        // if rp value specified:
    roff=rp;                // roff is rp
    ip=dv/rp;               // compute offset to saturated R due to rp
  end
  else begin                // else ideal current drive:
    roff=`wrealZState;      // resistance is `Z
    ip=0;                   // no offset in saturated R calculation
  end
  trt=0;                    // no risetime at time zero
  #(1step) trt=tr*1s;       // risetime converted to timescale
end

// Update Ival based on input ival, including optional risetime effect:
always begin
  Ia = (ival>imin)? ival:imin;  // allow positive-only output current
  if (trt==0) Ival = Ia;        // pass directly if no risetime
  else begin
    dI = Ia-Ival;               // actual change of current
    if (abs(dI)>imin) Ival += 1e-6*dI; // bump by tiny fraction of change
    Ival <= #(trt) Ia;          // then schedule change after risetime delay
  end
  @(ival);
end

// Define Rmode (true when voltage-limited, includes hysteresis of vtol):
always_comb Rmode = (P.V-N.V < (Rmode? dv:dv-vtol)); 

always begin             // Update I&R drive coefs on input or mode change:
  if (Rmode) begin       // resistive form limits when low or negative delta-V
    Idrv = 0;            // not in current format so no current drive
    Rdrv = dv/(Ival+ip); // define R to go from (0,0) to (dv,ival)
  end
  else begin             // current output mode
    Idrv = Ival;         // allow positive-only current
    Rdrv = roff;         // include default parallel R
  end 
  vmin = vtol+imin*Rdrv; // min significant diffl voltage change
  @(Rmode,Ival);         // update on drive or mode change
end

// Update Vp & Vn when change is significant to differential current flow:
always_comb if (abs(P.V-Vp)>vmin) Vp=P.V;
always_comb if (abs(N.V-Vn)>vmin) Vn=N.V;

assign P = '{Vn,-Idrv,Rdrv};    // Drive with ival+Vdif/rp (current mode) 
assign N = '{Vp, Idrv,Rdrv};    //   or Vdif/Rsat (sat mode) to each net

endmodule

