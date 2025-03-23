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

// Test VIRrampG ramp generation 

import EE_pkg::*; 
`timescale 1ns/1ps

module Ramp_TB;

EEnet A0,A,As,As0,B,C,D,E;
real vval,ival,rval,tr,ts;
real RCD, v2,i2,r2,tr2,ts2;

// ELEMENT CHECKS:

VIRrampG RampA0 (A0,vval,ival,rval, tr,0.0); // source with no sampling
VIRrampG RampA  (A, vval,ival,rval, tr,ts);  // source with sampling, no load

VIRrampGs #(.ts(15)) 
       RampAs (As,vval,ival,rval,tr);        // sampled version default
VIRrampGs #(.ts(15),.dsamp(0),.addpt(0)) 
       RampAs0(As0,vval,ival,rval,tr);       // sampled-data-only version

EVIRrampG RampAa (Aa,vval,ival,rval,tr,ts);  // electrical version of ramp gen

// LOADING EFFECT CHECKS:

VIRrampG RampB  (B, vval,ival,rval, tr,ts);  // source with V+R load
assign B = '{1.0, 0.0, 1000.0};              // 1V+1kohm connected

VIRrampG RampC (C, vval,ival,rval, tr,ts);   // source with R+C connected
VRsrcD   RdifCD(C,D,0.0,RCD,imeasC);         // resistor is R2
CapGeq #(.c(1e-10),.tinc(1e-8)) CapD(D);     // cap is 1e-10, sampled at 1e-8

VIRrampG RampE (E, vval,ival,rval, tr,ts);   // source running into another source
VIRrampG RampE2(E, v2, i2, r2, tr2, ts2);    // second source with indep drive

initial begin
  tr=80; ts=15; vval=2; ival=0; rval=100;    // initial drive
  RCD=1e3;                                   // cap R*C=100ns
  tr2=20; ts2=4; v2=0; i2=2e-4; r2=1e4;      // second source changes faster
  #30  vval=1;              // ramp V 2 to 1
  #100 rval=1e3;            // ramp R 100 to 1k
  #100 ival=2e-3;           // ramp I 0 to 1m
  #25  ival=0;              // (@25ns) reramp I * to 0
  #100 rval=`wrealZState;   // ramp R 1k to Z
  #24  i2=0;
  #30  i2=1e-4;
  #51  rval=0;              // ramp R Z to 0
  #100 rval=50;             // ramp R 0 to 50
  #25  r2=1e3;
  #5   vval=3;              // (@30ns) ramp V * to 3.0 (extend R)
  #35  vval=0.5;            // (@35ns) reramp V * to 0.5 (extend R)
  #30  rval=5e3;            // (@30ns) reramp R * to 5k  (extend V)
  #70  i2=0;
  #30  vval=2; rval=10;     // ramp V 0.5 to 2 AND R 5k to 10
  #2   v2=2; r2=1e5;
  #30  ival=5e-3;           // (+32ns) ramp I 0 to 5m (extend V&R)
  #50  tr=0;  vval=3; rval=100;  // (+50ns) step or quick ramp V to 3, R to 100
  #50  tr=40; vval=1; ival=0;    // tr=40ns ramp V to 1, I to 0
  #50  tr=2;  vval=3; rval=1e4;  // tr=2ns  ramp V to 3, R to 10k
  #20  tr=60; vval=1; rval=0;    // tr=60ns ramp V to 1, R to 0
  #100 ts=0;  vval=3; rval=1000; // ramp V to 3, R to 1000 (unsampled rampG)
  #100 $stop;
end
endmodule

