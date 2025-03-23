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
//  Ramped frequency sine signal source
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1ps
`define M_TWO_PI 6.28318530718

module signalSource3 import cds_rnm_pkg::*; (input logic en, output wreal4state out);

parameter real ampl = 2.0;  // peak-to-peak swing
parameter real dcVal = 0.0; // DC value
parameter real fMin = 10e3; // start of freq ramp (Hz)
parameter real fMax = 10e6; // end of freq ramp (Hz)
parameter real Ts = 1e-9;  // sampling period (sec)
parameter real sweepRate = 500e3; // sweep length in units of Ts
                                  // i.e. number of samples

real val,Phs, Freq;
event start, stop;

initial begin
   val = dcVal;  
   Freq = fMin;
   if (fMax <= fMin) begin
      $display("fMax must be > fMin !!"); 
      $stop;
   end
end

always 
  fork
  begin : srcGen
     @start forever
        begin
           val = dcVal + 0.5*ampl*$sin(`M_TWO_PI*Phs);  // compute input from levels & phase
           Freq = (Freq < fMax) ? Freq + (fMax - fMin)/sweepRate : fMin;
           #Ts Phs = Phs+Ts*Freq;          // update phase after delay
           if (Phs>=1) Phs -= 1;           // wrap phase in range 0 to 1
        end
  end
  @stop disable srcGen;
  join  

always @ (en) begin
   if (en == 1'b1) 
      ->start;
   else
      ->stop;
end

assign out = (en == 1'b1) ? val : `wrealZState;

endmodule


