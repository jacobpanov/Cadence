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

  // Declare needed variables
      // <<< Your Code Here >>>

  // Initialize outputs
   initial begin
      done = 1'b0;
      lockTime = 0.0;
   end

  // Collect the start signal and time
   always @ (posedge (enableSig === 1'b1)) begin
      // Start the measurement
      // <<< Your Code Here >>>
   end

  // VCO Frequency Measurement
   always @ (posedge vcoIn) begin
      // <<< Your Code Here >>>
   end

   // When the frequency is close to target, after the holdoff period,
   // collect a timestamp and start the search window
      // <<< Your Code Here >>>


  // When PLL freq has been close to target for long enough ...
      // <<< Your Code Here >>>
      $display("PLL lock time of %f us measured at time %f s.",(lockTime/1us),$realtime);




  // Absolute value function, if needed
   function real myabs (real inVal);
      return (inVal >= 0) ? inVal : -inVal;
   endfunction
 
endmodule
