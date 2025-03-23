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
// Stimulus for Bias Reference generator testbench
//
//--------------------------------------------------------------------------------------

`timescale 1s/1ps

module BIAS_stimulus (vtrim,itrim1, itrim5, en);
   output logic [4:0] vtrim, itrim1, itrim5;
   output logic en;

   integer vtrimVal = 0;
   integer signed itrim1Val = 0;
   integer signed itrim5Val = 0;
   integer i;
   logic enVal = 0;

   assign vtrim = vtrimVal;
   assign itrim1 = itrim1Val;
   assign itrim5 = itrim5Val;
   assign en = enVal;

   initial begin
      #(10us) enVal = 1'b1;
      #(50us);
      for (i=0;i<32;i=i+1) begin
         vtrimVal = i;
         #(10us);
      end
      vtrimVal = 15;
      #(50us);
      for (i=-15;i<15;i=i+1) begin
         itrim1Val = i;
         #(10us);
      end
      itrim1Val = 0;
      #(50us);
      for (i=-15;i<15;i=i+1) begin
         itrim5Val = i;
         #(10us);
      end
      itrim5Val = 0;
      #(50us) enVal = 1'b0;
      #(10us) $finish;
   end

endmodule
