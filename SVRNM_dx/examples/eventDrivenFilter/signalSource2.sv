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
//  Sawtooth signal source
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1ps

module signalSource2 import cds_rnm_pkg::*; (input logic en, output wreal4state out);

parameter real ampl = 2.0;
parameter real dcVal = 0.0; // DC value
parameter real period = 25e-6; //sawtooth period in sec
parameter integer sampPer = 60; // samples per period

real val;
event start, stop;

initial begin
   val = dcVal;   
end

always 
  fork
  begin : srcGen
     @start forever
        #(period/sampPer) begin
           if (val >= ((ampl/2) - dcVal))
              val = dcVal - (ampl/2);
           else
              val = val + (ampl/sampPer);
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


