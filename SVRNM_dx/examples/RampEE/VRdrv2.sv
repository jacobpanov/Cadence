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

// VRdrv2 - V+R ramping driver
// Linearly ramps V and R values over the risetime tr (ns) specified.
// Add slight update at start of ramp to generate event to allow proper
// analog/linear plotting and integration of waveform when driving a capacitive
// or inductive relationship. This model assumes non-overlapping ramp requests.

`timescale 1ns/1ps

module VRdrv2  import EE_pkg::*;
   (output EEnet Net, input real vval, rval, tr);

parameter real ts=1ns;             // sample rate during ramping
EEstruct Drv='{0,0,1e12};          // value to drive to output net
real vinc,rinc;                    // coefs for ramping V and R
int nstep;                         // number of full steps in ramp
real td;                           // fractional step to finish ramp

always begin
  if ($realtime>0) begin            // if not DC op point,
    Drv.V += 1e-12;                 // bump voltage slightly
    if (rval!==Drv.R) Drv.R+=1e-4;  // also bump R if starting R ramp
    nstep = $floor(tr/ts);          // number full steps during ramp
    td = ts*(tr/ts-nstep);          // remainder after nsteps done
    if (nstep>=1) begin             // if interim steps needed,
      vinc = (ts/tr)*(vval-Drv.V);  // compute V&R change per ts 
      rinc = (ts/tr)*(rval-Drv.R);  // then drive out the ramp points
      repeat (nstep) #(ts) Drv = '{Drv.V+vinc,0,Drv.R+rinc};
    end
    #(td);                          // remaining time til end of ramp
  end
  Drv = '{vval,0,rval};             // update to final value
  @(vval,rval);                     // repeat when input changes
end

assign Net = Drv;                   // drive the net

endmodule

