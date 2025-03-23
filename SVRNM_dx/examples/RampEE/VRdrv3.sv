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

// VRdrv3 - V+R ramping driver with auto-update on external events
// This module updates output at beginning and end of every ramp, and also 
// updates whenever an external event causes the output net to change, or 
// every ts (ns) when no external events are occuring.

`timescale 1ns/1ps

module VRdrv3  import EE_pkg::*;
   (output EEnet Net, input real vval, rval, tr);

parameter real ts=1ns;               // max timestep size
real Vnow,Rnow,Tnow;                 // present drive values
real Vnew,Rnew,Tnew;                 // final values at end of ramp
real srV,srR,td;                     // ramp slew rates & time until done

event NewDrv;
always @(vval,rval) ->NewDrv;        // generate event when vval or rval change

always begin                         // MAIN CALCULATION LOOP:
  if (Tnew>0) begin                  // when it has been ramping,
    if ($realtime>=Tnew) begin       // if at end of ramp
      Vnow = Vnew; Rnow = Rnew;      //  set to final values
      Tnew = 0;                      //  and indicate it's now static
    end
    else if ($realtime>Tnow) begin   // else if new timepoint
      Vnow = Vnew-srV*(Tnew-$realtime); // update values for this point
      Rnow = Rnew-srR*(Tnew-$realtime);
    end
  end
  Tnow = $realtime;                  // save present time value
  if (NewDrv.triggered) begin        // if drive change occurs now
    if (tr>0 && $realtime>0) begin   // if starting a ramp
      if (Tnew==0) begin             // if it had been static
        Vnow+=1e-12;                 //  bump V at start of any ramp
        if (rval!==Rnow) Rnow+=1e-4; //  also bump R if starting R ramp
      end
      Vnew = vval; Rnew = rval;      // save new final values
      Tnew = $realtime+tr;           // save time for ramp completion
      srV = (Vnew-Vnow)/tr;          // compute slew rates
      srR = (Rnew-Rnow)/tr;
    end
    else begin                       // else it's an immediate step change
      Vnew = vval; Rnew = rval;       
      Vnow = vval; Rnow = rval;
      Tnew = 0;                      // indicate static at new value
    end
  end
  if (Tnew==0) @(NewDrv);            // if static, wait for new drive spec
  else fork                          // else wait for several events:
    @(NewDrv);                       //  * new drive spec
    #1step @(Net.V,Net.R,Net.I);     //  * net changes at a new timepoint
    begin                             
      td = Tnew-$realtime;
      if (ts<=td) #ts;               //  * next sample point or
      else        #td;               //  * completion of risetime
    end
  join_any                           // continue when any one of those occur
end

assign Net = '{Vnow,0,Rnow};         // drive present value to net

endmodule

