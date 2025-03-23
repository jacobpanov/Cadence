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
// Main Power Supply for RF Transceiver System Test Bench
//   parameters set default supply value and ramp time
//   but variables are used in the actual calculations,
//   and these can be set from the testbench
//
//--------------------------------------------------------------------------------------

`timescale 1s/1ps
import cds_rnm_pkg::*;
import EE_pkg::*;

module tbPwrRamp(VDD4, VSS, enable);

parameter real defaultFinalValue = 4.2;
parameter real defaultRampTime = 5e-6;
parameter real defaultInternalR = 1e-2;
parameter real rampInterval = 10e-9;

inout EEnet VDD4, VSS;
input logic enable;

real finalValue;
real rampTime;
integer i;
real vddVal;
real iLoad;
real internalR;
integer rampSteps;
real  rampStepSize;

initial begin
   finalValue = defaultFinalValue;
   rampTime = defaultRampTime;
   internalR = defaultInternalR;
   vddVal = 0.0;
end

//  EEnet-based Voltage source

   Vvar_ideal #(.tr(1e-11), .vtol(1e-6)) vSource (
       .P          (VDD4), 
       .N          (VSS),
       .vval       (vddVal),
       .imeas      (iLoad)
   );

//assign VDD4 = '{vddVal,0,0};
//assign iLoad = VDD4.I;

//  Going Up
always @ (posedge (enable === 1'b1)) begin
   vddVal = 0.0;  // This device must start at zero
   rampSteps = $ceil(rampTime/rampInterval); // How many steps will it take?
   rampStepSize = finalValue / rampSteps;  // How big will each step be?
   for (i=0;i<rampSteps;i=i+1) begin
      vddVal = vddVal + rampStepSize; // Take a step up ...
      #(rampInterval);  // and then wait before the next one
   end
   vddVal = finalValue;  //Make sure to end up at the correct value
end

// Going Down
always @ (negedge (enable === 1'b1)) begin
   rampSteps = $ceil(rampTime/rampInterval); // How many steps will it take?
   rampStepSize = vddVal / rampSteps;  // How big will each step be? Starting from where vdd is now.
   for (i=0;i<rampSteps;i=i+1) begin
      vddVal = vddVal - rampStepSize; // Take a step down ...
      #(rampInterval);  // and then wait before the next one
   end
   vddVal = 0.0; // Make sure to end at zero
end

endmodule


