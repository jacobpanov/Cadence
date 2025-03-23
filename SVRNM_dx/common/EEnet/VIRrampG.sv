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

// VIRrampG.sv - driver for VIR format EEnet signals including risetime

// General drive to EEnet net - accepts all V/I/R combinations. 
// Output is bumped slightly at start time of ramp, then ramps from that 
// value up to the specified new value with a risetime of tr, generating
// points at least every ts seconds.  If the net is updated externally 
// during the risetime interval, the output value will be updated for that
// timepoint and this source will program the next event to occur ts after 
// the last timepoint or at the endpoint of the risetime (whichever occurs
// first).  If another input change occurs during a risetime interval, the
// present value of all inputs will become the starting point for the next
// risetime to the specified new values.
// 
// Note that risetime and sample rate are specified in timescale units.  
// A risetime of zero means that output changes immediately with input;
// A sample step of zero means no forced sampling is included.
// A change to sample step size will update the sampling process immediately.

// RAMPING FORMATS:
//  V and I are both ramped linearly.
//  R is ramped logarithmically between 10 ohms and 10Mohms, with linear and 
//  inverse tails on the ends to allow ramping to zero and infinite values
//  (or tiny and huge values) while spending only a minimal amount of the 
//  ramp time outside of the 10 to 1M ohm region.
//  Model ramps variable "K" linearly between 0 and 8, and computes resistance
//  based on K value during ramp.  Here's a table showing the conversion format:
//      K:  0  0.01  0.1   1    2     3    4    5    6    7    7.9  7.99   8
//      R:  0   0.1   1   10   100  1000  1e4  1e5  1e6  1e7   1e8   1e9   Z
//    Type: |    linear    |       logarithmic            |     inverse    |
//  You will need to include several points within the ramp (via ts) if you
//  want to accurately generate the logarithmic ramping characteristic.
//  Large steps of resistance will typically be processed by capacitive elements
//  as if it were linearly ramping conductance over each step, so extra points
//  are important to accurately match analog switching response.

// NOTE: THIS MODULE DEFINES ALL TIME UNITS IN NANOSECONDS.

//  Updated:  2020-03-26 (ronv) Cadence Design Systems 

import EE_pkg::*; 
`timescale 1ns/1ps

module VIRrampG (
  inout EEnet P,             // EEnet net to drive 
  input real vval,ival,rval, // input V,I,R values to drive to net
  input real tr,             // risetime to the new (V,I,R) values
  input real ts              // max stepsize during new risetime
);

parameter real rz=1e13;      // resistance for Z input drive
parameter real ttol=0.01;    // time tolerance (ns)

// Functions to convert between resistance values and K values:
// (K value is ramped linearly, R value computed from K)
`define KtoR(K) ((K<=1)? 10*K : (K<7)? $exp(ln10*K) : (K<kz)? 1e7/((8-K)) : rz)
`define RtoK(R) ((R<=10)? 0.1*R : (R<1e7)? $ln(R)/ln10 : (R<rz)? 8-1e7/R : kz)

real ln10 = $ln(10);         // constant
real kz = 8-1e7/rz;          // rz value converted to K

// Internal variables
real Ts,Tr;                  // bounded versions of risetime & stepsize
realtime Tstart,Tdone;       // beginning & end of risetime interval (ns)
realtime Tsamp,tdel;         // time at check, and deltaT until end of risetime
real tdif;                   // time difference since last sample point
real Vdr,Idr,Rdr,Kdr;        // output drive values at Tsamp
real Vnew,Inew,Rnew,Knew;    // new output drive values
real srV,srI,srK;            // ramping slew rates (per nanosecond)
real srVo,srIo,srKo;         // old values of slew rates
bit Csamp;                   // set high for sample event
bit Cupdt;                   // set high when value update needed
int Nupd;                    // count of output updates

// Process tr: small risetimes round down to zero or up to ttol:
always begin
  Tr = (tr>ttol)? tr : (tr>0.5*ttol)? ttol : 0;
  @(tr);
end

// Process ts: zero stepsize means no sampling, small stepsize rounds up to ttol:
always begin
  Ts = (ts>ttol)? ts : (ts==0)? 1e9: ttol;
  if (Tdone>0 && Ts>0) Cupdt=1; // treat same as output change during ramp
  @(ts);
end

// Process vval,ival,rval:
always begin
  if (vval<1e9 && rval<rz) begin    // normal value processing
    Vnew=vval; Inew=ival; Rnew=rval; Knew=`RtoK(rval);
  end
  else begin                        // input Z or X or huge treated as rz
    Vnew=Vdr; Inew=ival; Rnew=rz; Knew=kz;
  end
  Tstart = $realtime;               // save time where ramp is started
  if (Tr==0 || $realtime==0) begin  // just pass thru if Tr=0 or DC op point
    Vdr = Vnew;                     //  set to final V,I,R values
    Idr = Inew;
    Kdr = Knew;
    Rdr = Rnew;
    Tdone = 0;                      // indicate it's constant output drive
    srV=0; srI=0; srK=0;
  end                      
  else begin                        // else update point & compute new coefs:
    if (Tdone>0) begin              // is ramping now, so update present value
      tdif = $realtime-Tsamp;       // get dT since last samp
      Vdr += srV*tdif;              // update VIK values using ramp rates
      Idr += srI*tdif;              
      Kdr += srK*tdif;
      Rdr = `KtoR(Kdr);             // and compute new R
    end
    Tsamp = $realtime;              // save time when drive values updated
    disable ckgen;                  // reset sample timer to start here
    Nupd++;                         // count updates to output drive
    srVo=srV; srIo=srI; srKo=srK;   // save old slopes
    if (Rdr==rz && Rnew<rz) begin   // If resistance changing from Z to nonZ,
      Vdr = Vnew;                   //  step Vdrv to new value while still highZ
      srV = 0;                      //  and set its slew rate to zero
    end
    else srV = (Vnew-Vdr)/Tr;       // compute slew rates toward new values
    srI = (Inew-Idr)/Tr;
    srK = (Knew-Kdr)/Tr;
    if (srVo==0) Vdr += 1e-12;      // add tiny V&I bump at start of ramp
    if (srIo==0) Idr += 1e-16;
    if (srKo==0 && srK!=0) begin    // if resistance starting a ramp,
      Kdr += (srK>0)? 1e-7:-1e-7;   // also add tiny K bump
      Rdr = `KtoR(Kdr);             // and compute new R
    end
    Tdone = Tstart+Tr;              // time when ramp will complete
  end
  @(vval,ival,rval);                // repeat on input change
end

// Sample timer:
always begin :ckgen                 // start resettable sample clock generator
  wait (Tdone>0);                   // wait until start of risetime interval
  tdel = Tdone-$realtime;           // delta time until end of risetime
  if (tdel>Ts+0.5*ttol) #(Ts);      // during ramp, wait for sample delay time
  else                  #(tdel);    // at end, finish the risetime interval
  Csamp = 1;                        // create sampling event now
  wait (!Csamp);                    // wait until Csamp is cleared
end

// Generate event when output is externally updated at a new timepoint:
always @(P.V,P.R) if (Tdone>0 && $realtime>Tsamp) Cupdt = 1;

// Update output based on slew rates whenever an event occurs:
always begin
  if (Tdone>0) begin         // if it is still ramping
    tdel = Tdone-$realtime;  // compute remaining time until end of ramp.
    if (tdel<0.5*ttol) begin // if ramping has completed (or close enough)
      Vdr = Vnew;            //  then update to final V,I,R values
      Idr = Inew;
      Kdr = Knew;
      Rdr = Rnew;
      Tdone = 0;             //  indicate it's now constant output drive
      srV=0; srI=0; srK=0;
    end
    else if ($realtime>Tsamp) begin // if mid-ramp and past last computed value
      Vdr = Vnew-srV*tdel;          //  then update V,I,R values
      Idr = Inew-srI*tdel;
      Kdr = Knew-srK*tdel;
      Rdr = `KtoR(Kdr);
      Tsamp = $realtime;     // save time when drive values updated
    end                      // else iteration at same timepoint (no update)
  end
  if (!Csamp) disable ckgen; // restart sample generator if needed
  else  Csamp=0;             // initiate next sample interval
  Cupdt=0;                   // finished processing update
  Nupd++;                    // count number of updates to output drive
  wait (Cupdt|Csamp);        // wait for event for next update
end

assign P = '{Vdr,Idr,Rdr};   // drive the output net

endmodule

`undef KtoR
`undef RtoK

