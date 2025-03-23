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
//
// Testbench resource for measuring PLL lock time 
//
// This module requires inputs as follows:
//   vcoIn    -- net connecting to the vco output
//   targFreq -- an input net or variable that contains the desired locked
//               frequency of the PLL in Hz
//   lockSpec -- The limit within which the PLL should be considered locked in Hz
//   window   -- The length of time the frequency must be within lockSpec of targFreq
//               for the PLL to be considered locked, in seconds
//   holdOff  -- Time after enable to delay beginning measurement, for calibration or setup.
//               (Optional, if not desired set to zero) In seconds.
//               Note: holdOff time is still included in the total lock time returned.
//   enableSig -- logic signal indicating start of PLL lock
//   
//   The module outputs the measurment lockTime in seconds, which is valid if 'done' is set.
//
//---------------------------------------------------------------

`timescale 1s/1fs

module pllLockTimeMeas (
input real targFreq, lockSpec, window, holdOff,
input logic enableSig, vcoIn,
output real lockTime,
output logic done
);

  parameter real lockTimeSpec = 75e-6;

   logic locked = 1'b0;
   logic measuring = 1'b0;
   real potentialLockedTime, actualLockedTime, enabledTime;
   real measFreq, lastVcoEdge;
   event wait4Lock, endWait;

   initial begin
      done = 1'b0;
      lockTime = 0.0;
   end

   always @ (posedge (enableSig === 1'b1)) begin
      // Start the measurement
      lastVcoEdge = $realtime;
      enabledTime = $realtime;
      measuring = 1'b1;
      locked = 1'b0;
      done = 1'b0;
   end

   always @ (posedge vcoIn) begin
      measFreq = (($realtime - lastVcoEdge) != 0) ? 1/($realtime - lastVcoEdge) : 0.0;
      lastVcoEdge = $realtime;
   end

   // When the frequency is close to target, after the holdoff period,
   // if measuring is enabled
   always @ (abs(measFreq - targFreq) < lockSpec) begin
      if ((abs(measFreq - targFreq) < lockSpec) && 
          (($realtime - enabledTime) > holdOff) &&
          (measuring == 1'b1)) begin
         potentialLockedTime = $realtime; //Store this time for later
         locked = 1'b1;
         ->wait4Lock;
      end
      else begin // Freq out of spec OR within holdOff OR not measuring
         locked = 1'b0;
         ->endWait;
      end
   end

   always 
     fork 
        begin : lockWait
           @wait4Lock forever begin 
              #(1e-8); // check every 10 ns
              if (($realtime - potentialLockedTime) > window) begin
              // PLL freq has been close to target for long enough ...
                 actualLockedTime = potentialLockedTime; // locked time retroactively accepted
                 lockTime = actualLockedTime - enabledTime; // total lock time computed
                 done = 1'b1;
                 measuring = 1'b0; // done with measurement
                 $display("PLL lock time of %f us measured at time %f s.",(lockTime/1us),$realtime);
                 ->endWait;
              end
          end
       end
       @endWait disable lockWait;
    join

   function real myabs (real inVal);
      return (inVal >= 0) ? inVal : -inVal;
   endfunction

endmodule
