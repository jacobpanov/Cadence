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
// Pre-amplifier for Transmitter model.
//   Has a tuning input that emulates a frequency selective resonant circuit
//   (but does not actually have a frequency dependence)
//   Has a gain control useful for ramping the output for anti-splatter
//
//---------------------------------------------------------------

`timescale 1s / 1ps


module txPreAmp import cds_rnm_pkg::*; import EE_pkg::*; (
  input logic inp,
  input logic inm,
  inout EEnet vdd,
  inout EEnet vss,
  input wreal4state ibias,
  output wreal4state outp,
  output wreal4state outn,
  input logic [4:0] gain,
  input logic [4:0] tune,
  input logic en);

  parameter real iActive = 800e-6;  //Base active current drain
  parameter real iStandby = 1e-6;
  parameter real gainNomdB = -93;  //gain for setting 0
  parameter real gainStepdB = 3.0; //additional gan per step
  parameter real gainCurrentUnit = 50e-6; // additional current per gain step
  parameter real tuningConst = 0.003876;  //Determines "Q" of tuning -- smaller is narrower
  parameter real vddMin = 1.0;
  parameter real vddMax = 2.0;
  parameter real vssMax = 0.1;
  parameter real iBiasMax = 2e-6;
  parameter real iBiasMin = 500e-9;
  parameter real amplNom = 1; //reference amplitude for 0 dB gain

  reg preAmpOn;
  reg enInt = 0;
  reg vddGood;
  reg vssGood;
  reg ibiasGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  logic ibiasGoodFilt;
  logic Active;
  real iSupply;
  logic outInt;
  real ampl = 0.0;
  real gainNum;
  real tuneCoeff;
  integer tuneCtrOffset = 0;
  real gainError = 1.0;

//  Current source to model active core (background) current
   Isrc_ideal_gaussian #(.tr(5e-9)) coreLoad (
       .P          (vdd),
       .N          (vss), 
       .ival       (iSupply)
  );

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

  always @ (ibias)
      ibiasGood = (ibias <= iBiasMax) && (ibias >= iBiasMin);
  assign #(250e-9) ibiasGoodFilt = ibiasGood;

   always @ (en)
      if (en === 1'b1)  enInt = 1;
      else enInt = 1'b0;

  assign Active = vddGoodFilt && vssGoodFilt && ibiasGoodFilt;

  always @ (enInt or Active) begin
     if (enInt == 1'b1 &&  Active === 1'b1)
        preAmpOn = 1'b1;
     else preAmpOn = 1'b0;
  end

  always @ (preAmpOn or gain) begin
     if ((^gain !== 1'bx) && (^gain !== 1'bz) && (preAmpOn === 1'b1))
        gainNum = 10 ** ((gainNomdB + (gain * gainStepdB))/20);
     else gainNum = 0;   
     ampl = amplNom * gainNum * gainError;
  end

  always @ (preAmpOn or tune) begin
     if ((^tune !== 1'bx) && (^tune !== 1'bz) && (preAmpOn === 1'b1))
       tuneCoeff = 1 - (tuningConst * ($signed(tune - 16 + tuneCtrOffset) ** 2));  // simulate a parabolic tuning curve
     else tuneCoeff = 0;
  end

  assign outInt = (preAmpOn === 1'b1) ? (inp && !inm) : 1'bx;  // treat input as differential and pass on if Active

  assign outp = (outInt === 1'b1) ?  (ampl * tuneCoeff) : ( (outInt === 1'b0) ? -(ampl*tuneCoeff) : `wrealZState );
  assign outn = (outInt === 1'b1) ? -(ampl * tuneCoeff) : ( (outInt === 1'b0) ?  (ampl*tuneCoeff) : `wrealZState );

 assign iSupply = ((vddGoodFilt && vssGoodFilt) * iStandby) + (Active * (iActive + (gain*gainCurrentUnit)));

endmodule
