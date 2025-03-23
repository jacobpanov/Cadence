//--------------------------------------------------------------------------------------
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
//--------------------------------------------------------------------------------------
//
// Testbench Stimulus RF source with power ramp
// inputs:
// carrierFreq  -- RF Carrier Frequency in MHz
// amplitude    -- Carrier Amplitude. By convention, 1pk => 0 dBm
// modulation   -- real valued modulation waveform. +/- 1 is full deviation
// sampClk      -- should match incoming modulation samples. Typical is 8 samp/sym
//
// Parameter:
// modDev       -- full FM deviation (for +/- 1 mod input)
// rampStep     -- Step size of each step during power ramp up and down
// rampDuration -- Duration in seconds of power ramps up and down
//--------------------------------------------------------------------------------------

`timescale 1s/1fs

module tbRFSource (
  input  real carrierFreq, amplitude, modulation,
  output real rfp, rfm,
  input logic sampClk, enable
);

   parameter modDev =  500e3;   // FM deviation
   parameter rampStep = 3;      // ramp step size in dB
   parameter rampDuration = 2e-6; // Ramp duration in seconds
   parameter carrierDefault = 2440e6; // default carrier freq

   real   instFreq;
   real   instPeriod = 1.0/(2.0*carrierDefault);
   real   amplInt = `wrealZState;
   real   ampldBm;
   real   rampStart;
   logic  rfDiff = 1'b0;
   integer i;

   // Ramp Up on posedge of enable
   always @ (posedge enable) begin
      ampldBm = 20*$log10(amplitude);
      rampStart = ampldBm - 31*rampStep; // set very low starting point
      i = 0;
      repeat (32) begin
         amplInt = 10**((rampStart+(i*rampStep))/20);
         # ((rampDuration/32)*1s);
         i = i + 1;
      end
   end

   // Ramp Down on negedge of enable
   always @ (negedge enable) begin
      ampldBm = 20*$log10(amplitude);
      rampStart = ampldBm; // set starting point at max power
      i = 0;
      repeat (32) begin
         amplInt = 10**((rampStart-(i*rampStep))/20);
         # ((rampDuration/32)*1s);
         i = i + 1;
      end
      if (enable !== 1'b1) amplInt = `wrealZState; // set to Z at end of ramp, it is OFF
      else amplInt = amplInt; // in case it came back on again too soon
   end

   // Convert the incoming modulation waveform into a modulated carrier frequency
   always @ (posedge sampClk) begin
     instFreq = carrierFreq*1e6 + (modDev * modulation);
     // Lots of extra logic to avoid divide-by-zero
     instPeriod = (instFreq != 0) ? 1/(2*instFreq) : (carrierFreq != 0) ? 1/(2*carrierFreq*1e6) : 1/(2*carrierDefault);
   end

   // Generate the RF signal
   always # (instPeriod) begin
      rfDiff = ~rfDiff;
   end

   // Make differential outputs and add amplitude information
   assign rfp = (rfDiff == 1) ? amplInt : -amplInt;
   assign rfm = (rfDiff == 0) ? amplInt : -amplInt;

endmodule
