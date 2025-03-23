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

// VIRrampGs.sv - sampled data VIR format EEnet driver including risetime

// Drive to EEnet for sampled data system.  Accepts all V/I/R combinations. 
// Risetime and sample period are specified in timescale units. 
// Asynchronous updates will be evaluated when they occur, and risetimes that
// are not a multiple of ts can result in end of risetime occuring mid-step.
// Two flags control detailed behavior:
//   addpt=1  inserts a timepoint at start and end of asynchronous risetimes.
//            (set to zero to only update output at sample points)
//   dsamp=1  forces an event at every sample point by inserting tiny changes.
//            (set to zero to only change when actual value change occurs) 

// At time=0, any changes are immediately applied (as DC op point operation).
// Otherwise, tr is used for risetime.  If tr is zero or invalid, ts is used.
// If another control change occurs before output response is complete, present
// VIR will be saved and transition to the new VIR will occur over the next
// risetime interval starting at that point.
// If vval or rval inputs are set to `wrealZState or `wrealXState or a huge 
// value, this model will convert the drive to be the specified rz resistance.

// RAMPING FORMATS:
//  V and I are both ramped linearly.
//  R is ramped logarithmically between 10 ohms and 10Mohms, with linear and 
//  inverse tails on the ends to allow ramping to/from zero and infinite values
//  (or tiny and huge values) while spending only a minimal amount of the 
//  ramp time outside of the 10 to 10M ohm region.
//  Model ramps variable "K" linearly between 0 and 8, and computes resistance
//  based on K value during ramp.  Here's a table showing the conversion format:
//      K:  0  0.01  0.1   1    2    3     4    5    6    7   7.9  7.99   8
//      R:  0   0.1   1   10   100  1000  1e4  1e5  1e6  1e7  1e8   1e9   Z
//    Type: |    linear    |       logarithmic            |    inverse    |

// NOTE: THIS MODULE DEFINES ALL TIME UNITS IN NANOSECONDS.

//  Updated:  2020-03-26 (ronv) Cadence Design Systems

import EE_pkg::*; 
`timescale 1ns/1ps

module VIRrampGs (
  inout EEnet P,             // EEnet net to drive 
  input real vval,ival,rval, // input V,I,R values to drive to net
  input real tr              // risetime (ns) to the new {V,I,R} value
);

parameter real ts=1;         // sample period (ns)
parameter real rz=1e13;      // resistance for Z input drive
parameter bit addpt=1;       // flag to insert points at start/end of risetime
parameter bit dsamp=1;       // flag to force change on every sample point

// Functions to convert between resistance values and K values:
// (K value is ramped linearly, R value computed from K)
`define KtoR(K) ((K<=1)? 10*K : (K<7)? $exp(ln10*K) : (K<kz)? 1e7/((8-K)) : rz)
`define RtoK(R) ((R<=10)? 0.1*R : (R<1e7)? $ln(R)/ln10 : (R<rz)? 8-1e7/R : kz)

real ln10 = $ln(10);         // constant
real kz = 8-1e7/rz;          // rz value converted to K

// Internal variables
real Tstart,Tsamp,Tdone;     // time at start of ramp, sample point, end of ramp
real Trem;                   // time remaining until end of ramp
real Vnow,Inow,Rnow,Know;    // VIR values at present time
real Vdr,Idr,Rdr,Kdr,Tdr;    // output VIR drive values & time
real Vnew,Inew,Rnew,Knew;    // final output drive values at Tdone
real Tr;                     // risetime to use (substitutes ts if tr invalid)
real srV,srI,srK;            // slew rates for signals approaching Tdone

// Process control changes from vval, ival, and rval inputs:
always @(vval,ival,rval) begin
  Tstart=$realtime;                 // time of input control change
  if (Tstart>Tsamp) UpdateNow;      // if between samples, update "now" value
  if (Rnow==rz && vval<1e9) Vnow=vval; // step to vval if already Z drive
  if (rval<rz && vval<1e9) begin    // if ramping to normal V & R values
    Vnew=vval; Rnew=rval; Knew=`RtoK(rval);
  end
  else begin                        // else ramping to highZ case
    Vnew=Vnow; Rnew=rz; Knew=kz;
  end
  Inew=ival;                        // save new I value
  if ($realtime==0) begin           // if DC op point
    Vnow=Vnew; Inow=Inew; Rnow=Rnew; Know=Knew;  // update now values
    Tdone=0;                        // step to new specification
    UpdateDrive;                    // and drive output immediately
  end 
  else begin                        // otherwise define ramping coefs
    Tr=(tr>0)? tr:ts;               // if tr=0 or X, use ts instead
    srV=(Vnew-Vnow)/Tr;             // ramp rate to new V,I,K
    srI=(Inew-Inow)/Tr;
    srK=(Knew-Know)/Tr;
    Tdone=$realtime+Tr;             // save "done" time
    if (addpt) UpdateDrive;         // update if addpt at new time
  end
end

// Drive update at every sample point:
always #(ts) begin                  // every sample period
  Tsamp=$realtime;                  // time of sample
  UpdateNow;                        // update the "now" value
  UpdateDrive;                      // and drive to output
end

// If adding output points, add point at end of ramp when mid-sample
initial if (addpt)                  // only do this when point-at-events flag
 forever wait (Tdone>0)             // when ramp segment starts
  fork                              // if endpoint is actually mid-sample
    #Tr if ($realtime>Tsamp && $realtime<Tsamp+ts) begin // then after risetime
      UpdateNow;                    // update the "now" value
      UpdateDrive;                  // and drive to output
    end
    @(Tdone);                       // but cancel above if new ramp is started
  join_any


// Update at new time point:
task UpdateNow;
  if (Tdone>0) begin                    // if it had been ramping,
    Trem = Tdone-$realtime;             // compute time remaining in ramp
    if (Trem>0.5step) begin             // if still ramping, 
      if (srV!=0) Vnow = Vnew-srV*Trem; // update values using slew rates
      if (srI!=0) Inow = Inew-srI*Trem;
      if (srK!=0) begin
        Know = Knew-srK*Trem;
        Rnow = `KtoR(Know);
      end
    end
    else begin                          // else reached final value
      Vnow=Vnew; Inow=Inew; Know=Knew; Rnow=Rnew; 
      srV=0; srI=0; srK=0; Tdone=0; 
    end
  end                   // otherwise it's already static so no change needed.
endtask

// Update the driven value. If "dsamp" format, change V&I at every point.
task UpdateDrive;
  if (dsamp && $realtime>Tdr) begin     // if forcing update at all points
    if (Vdr==Vnow && Idr==Inow) begin   // if no change to VorI, bump both
      Vdr+=1e-12;                       // bump V by 1pV
      Idr+=1e-16;                       //  and I by 0.1fA
    end
    else begin                          // otherwise only bump voltage if needed
      Vdr = (Vdr==Vnow)? Vdr+1e-12 : Vnow;  // bump or update voltage
      Idr = Inow;                       // update current 
    end
    if (srK!=0 && $realtime==Tstart) begin  // if resistance starting to ramp,
      Kdr = Know+((srK>0)? 1e-7:-1e-7); // add tiny K bump
      Rdr = `KtoR(Kdr);                 // and compute new R
    end
    else begin
      Kdr=Know; Rdr=Rnow;               // else just update resistance
    end
  end
  else begin                            // Else just pass through
    Vdr=Vnow; Idr=Inow; Kdr=Know; Rdr=Rnow;
  end
  Tdr=$realtime;                        // save time of update
endtask

assign P = '{Vdr,Idr,Rdr};              // drive the output net

endmodule

`undef KtoR
`undef RtoK

