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
//  Irregularly varying signal source
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1ps
import cds_rnm_pkg::*;

module signalSource (input logic en, output wreal4state out);

parameter real minTupdate1 = 1e-6;
parameter real maxTupdate1 = 25e-6;
parameter real minTupdate2 = 100e-6;
parameter real maxTupdate2 = 250e-6;
parameter real maxAmpl = 2.0;
parameter real maxChange = 0.5;

real interval;  // interval between changes
real dAmpl;   // change in amplitude
real ampl;    // instantaneous amplitude
logic res;

initial begin
   interval = minTupdate1;
   ampl = 0.0;
end

always #(interval) begin
   res = std::randomize(interval) with {interval inside {[minTupdate1:maxTupdate1],[minTupdate2:maxTupdate2]};};
   res = std::randomize(dAmpl) with {dAmpl inside {[-maxChange:maxChange]};};

   if ( ((ampl + dAmpl) < maxAmpl) && ((ampl + dAmpl) > -maxAmpl) )
      ampl = ampl + dAmpl;
   else if ((ampl + dAmpl) >= maxAmpl)
      ampl = maxAmpl;
   else
      ampl = -maxAmpl;

end

assign #(10e-9) out = (en == 1'b1) ? ampl : `wrealZState;

endmodule
