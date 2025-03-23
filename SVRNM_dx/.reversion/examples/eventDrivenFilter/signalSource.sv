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

module signalSource import cds_rnm_pkg::*; (input logic en, output wreal4state out);

parameter real Ts = 1e-9; // sample time (sec)


real interval;  // interval between changes
real dAmpl;   // change in amplitude
real ampl;    // instantaneous amplitude

logic res, clk;
event start, stop;
integer count, lastCount;

initial begin
   clk = 1'b0;
   ampl = 0.0;
   count = 0;
end

assign    out = (en == 1'b1) ? ampl : `wrealZState;

always 
  fork
  begin : srcGen
     @start forever
        begin
           #Ts clk = ~clk;          // Generate sample clock
        end
  end
  @stop disable srcGen;
  join 

always @ (clk) begin
   if (count >= 250000)
      count = 0;
   else
      count++;
end

always @ (en) begin
   if (en == 1'b1) begin
      ->start;
      count = 0;
   end
   else
      ->stop;
end

// Code behaviors on count values
// Take some large steps
always @ (count == 100)
   ampl = 2.0;

always @ (count == 8000)
   ampl = -2.0;

always @ (count == 16000)
   ampl = 0.0;

// Take some smaller steps

always @ (count == 18000)
   ampl = 2e-3;

always @ (count == 22000)
   ampl = 4e-3;

always @ (count == 24000)
   ampl = -4e-3;

always @ (count == 30000)
   ampl = 0.0;

// Short pulses

always @ (count == 35000)
   ampl = 500e-3;

always @ (count == 35150)
   ampl = 0.0;

always @ (count == 50000)
   ampl = -350e-3;

always @ (count == 51510)
   ampl = 0.0;

// quick stair step

always @ (count == 70050)
begin
   lastCount = count;
   repeat (12) begin
      @ (count == (lastCount + 800))
      ampl = ampl + 0.2;
      lastCount = count;
   end
   lastCount = count;
   repeat (24) begin
      @ (count == (lastCount + 800))
      ampl = ampl - 0.2;
      lastCount = count;
   end
   lastCount = count;
   repeat (12) begin
      @ (count == (lastCount + 800))
      ampl = ampl + 0.2;
      lastCount = count;
   end
   ampl = 0.0;
end
   

endmodule
