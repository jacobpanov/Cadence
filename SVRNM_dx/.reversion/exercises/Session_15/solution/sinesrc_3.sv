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

// EEnet Sinusoidal Source with active event update

`timescale 1ns/1ps

module sinesrc  import EE_pkg::*; (output EEnet P, input real vdc,vm,fsin);

parameter real rs=0;             // optional output resistance (ohms)
parameter real ptspercyc=12;     // output max sample stepsize (ns)
const real pi=3.14159;

real Phs,Vout;     // present phase (cycles) and output voltage (V)
real T0,F0;        // time (ns) and frequency (Hz) at last timepoint
real dT;           // actual timestep size (seconds)
real Td=1s;        // maximum timestep size (ns)

// UPDATE TO CHECK FOR VALID FSIN INPUT:
always begin                     // DRIVE UPDATE PROCEDURE:
  if (fsin>0) begin              // if valid fsin input
    dT = ($realtime-T0)/1s;      // timestep size since previous point
    Phs += dT*F0;                // update the phase to present time
    Vout = vdc+vm*$sin(2*pi*Phs);// update output drive
    if (fsin!=F0) begin          // if frequency has changed,
      F0 = fsin;                 //   then update F0 value
      Td = 1s/(F0*ptspercyc);    //   and max stepsize for pts per cycle
    end                          // (this just limits computation)
  end
  else begin                     // invalid vsin so just drive DC value
    F0 = 0;                      // zero freq
    Td = 1s;                     // static output (long delay)
    Phs= 0;                      // and reset phase
    Vout = vdc;                  // output is just DC value
  end
  T0=$realtime;                  // save time for use next step

  fork
    @(P.V,P.I,P.R,vdc,vm,fsin);  // wait for net or control change
    #(Td);                       // or after max sample period
  join_any                       // continue after either of above events
end

assign P = '{Vout,0.0,rs};       // drive output net

endmodule

