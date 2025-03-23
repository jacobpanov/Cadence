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
// Local Bias block for transmitter model
//
//---------------------------------------------------------------

`timescale 1s / 1ps

module txBias import cds_rnm_pkg::*; import EE_pkg::*; (
    inout EEnet vdd,
    inout EEnet vss,
    input logic en,
    output wreal4state pbias [1:0],
    input [3:0] trim,
    inout EEnet inBias );

  parameter real iActive = 50e-6;  //Base active current drain
  parameter real iStandby = 1e-6;
  parameter real vddMin = 1.0;
  parameter real vddMax = 2.0;
  parameter real vssMax = 0.1;
  parameter real iBiasNom = 1e-6;
  parameter real iRatio = 0.20; // ratio of pbias to inBias
  parameter real rBiasOn = 100e3; // 0.5V / 5 uA
  parameter real rBiasOff = 10e6; //high R when off
  parameter real IBIAS_MAX=7.5e-6;
  parameter real IBIAS_MIN=2.5e-6;
  parameter real trimStep = 100e-9;
  parameter real turnOnDelay = 2e-6;


  reg biasOn;
  reg enInt = 0;
  reg vddGood;
  reg vssGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  logic Active;
  logic inBiasOK;
  real iSupply;
  real biasVal;
  real rBias;
  real iBiasIn;

//  Current source to model active core (background) current
   Isrc_ideal_gaussian #(.tr(1e-8)) coreLoad (
       .P          (vdd),
       .N          (vss), 
       .ival       (iSupply)
  );

// Input impedance at inbias port modeled with an EE_net VRsrcG
   VRsrcG #(.tr(1e-10), .Kinc(1e-9)) iBiasInputR (
       .P(inBias),
       .vval( ),
       .rval(rBias),
       .imeas(iBiasIn)
   );

  // Supply Checks
  always begin 
      vddGood = ((vdd.V >= vddMin) && (vdd.V < vddMax));
      @ (vdd.V);
  end
  assign #(250e-9) vddGoodFilt = vddGood;
  
  always begin 
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
      @ (vss.V);
  end
  assign #(250e-9) vssGoodFilt = vssGood;

  assign inBiasOK = ((iBiasIn >= IBIAS_MIN) && (iBiasIn <= IBIAS_MAX));

   always @ (en)
      if (en === 1'b1)  enInt = 1;
      else enInt = 1'b0;

  assign Active = vddGoodFilt && vssGoodFilt;

  // Set the proper input resistance when enabled
  always @ (enInt or Active or inBiasOK) begin
     if ((enInt == 1'b1) &&  (Active === 1'b1))
        rBias = rBiasOn;
     else begin
        rBias = rBiasOff;
        biasOn = 1'b0;
     end

     if ((inBiasOK === 1'b1) && (rBias == rBiasOn)) begin
        #(turnOnDelay);
        if ((inBiasOK === 1'b1) && (rBias == rBiasOn)) // still On
               biasOn = 1'b1;
     end
     else begin
        biasOn = 1'b0;
     end
  end

  always @ (negedge (enInt && (Active === 1'b1)))
       biasOn = 1'b0;

  // Process trim input and adjust current mirror ratio accordingly
  always @ (biasOn or trim or iBiasIn) begin
     biasVal = biasOn * ( (iBiasIn * iRatio) + ($signed(trim - 8) * trimStep) );
  end

  // Assign reference current values to output ports
  assign pbias[0] = biasVal;
  assign pbias[1] = biasVal;

  // calculate supply current based on ON state and supplied references
  assign iSupply = (Active * iStandby) + (biasOn * (iActive + (2 * biasVal)));
 
endmodule
