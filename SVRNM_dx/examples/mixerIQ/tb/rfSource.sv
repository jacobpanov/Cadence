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
// Modulated RF signal source for RF test benches
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1fs

`ifndef M_TWO_PI
`define M_TWO_PI 6.28318530717958647652
`endif

module rfSource import cds_rnm_pkg::*; (rfp, rfm);

   parameter carrierFreq = 2440e6;
   parameter modFreq = 100e3;
   parameter modDev =  500e3;   //FM deviation
   parameter amplitude = 0.4;

   output wreal4state rfp;
   output wreal4state rfm;

   real   modulation;
   real   instFreq;
   real   instPeriod = 1/(2*carrierFreq);
   logic  rfDiff = 1'b0;


   real  modPeriod = modFreq*16;  //sample rate for modulation


   always # (1/modPeriod) begin
     modulation = modDev * $sin(`M_TWO_PI*modFreq*$realtime);
     instFreq = carrierFreq + modulation;
     instPeriod = (instFreq != 0) ? 1/(2*instFreq) : 1/(2*carrierFreq);
   end

   always # (instPeriod)
      rfDiff = ~rfDiff;

   assign rfp = (rfDiff == 1) ? amplitude : -amplitude;
   assign rfm = (rfDiff == 0) ? amplitude : -amplitude;

endmodule
