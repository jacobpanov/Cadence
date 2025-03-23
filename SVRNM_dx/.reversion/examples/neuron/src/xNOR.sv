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
// Latching exclusive NOR for Mixed Signal Neuron Model
//
// --------------------------------------------------------------

`timescale 1s/100fs

import EE_pkg::*;

module xNOR  (
  output EEnet out, 
  inout  EEnet vdd, vss, 
  input logic w, x, clk 
);

parameter real propDelay = 1e-11;
parameter real latchNrg  = 2.5e-16; // Joules per event
parameter real iStandby  = 1e-12;  // Amps
parameter real rOut = 50;
parameter real vddMax = 1.2;
parameter real vddMin = 0.7;
parameter real vssMax = 0.1;
parameter real minFaultDur = 100e-9;

logic outInt;
real iSupply;
logic vddOK, vssOK, vddOKFilt, vssOKFilt, supplyOK;
real outV;
real eventCurrent, iActive;
event latchEvent;

initial begin
  iActive = 0.0;
end

always @ (vdd.V or vss.V)
   eventCurrent = ((vdd.V - vss.V) > vddMin) ? (latchNrg / (propDelay * (vdd.V - vss.V))) : 0.0;
   // A = J / V*s

always @ (vdd.V)
   vddOK = (vdd.V > vddMin) && (vdd.V < vddMax);
assign #(minFaultDur*1s) vddOKFilt = vddOK;

always @ (vss.V or vdd.V)
   vssOK = (vss.V > -vssMax) && (vss.V < vssMax);
assign #(minFaultDur*1s) vssOKFilt = vssOK;

assign supplyOK = vddOKFilt && vssOKFilt;

assign #(propDelay*1s) out = '{ (outInt === 1'b1) ? vdd.V : (outInt === 1'b0) ? vss.V : `wrealZState , `wrealZState, rOut };

always @ (posedge clk or supplyOK) begin
   if (supplyOK === 1'b1) begin
      outInt = !(w ^ x);
      ->latchEvent;
   end
   else
      outInt = 1'bx;
end

always @latchEvent begin
   iActive = eventCurrent;
   #(propDelay*1s) iActive = 0;
end

assign iSupply = ((supplyOK === 1'b1) * iStandby) + iActive;
assign vdd = '{`wrealZState, -iSupply, 0};
assign vss = '{`wrealZState,  iSupply, 0};

endmodule
