//systemVerilog HDL for "RX", "dcocDAC" "systemVerilog"
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
// DAC for DC Offset Correction in RXBB Model
//
//--------------------------------------------------------------------------------------


`timescale 1s / 1ps


module dcocDAC import cds_rnm_pkg::*; import EE_pkg::*; (
   vdd, vss, in, en, outp, outn, vref );

  parameter real vddMax = 1.8;
  parameter real vddMin = 1.0;
  parameter real vssMax = 0.1;
  parameter real vrefMin = 0.4;
  parameter real vrefMax = 1.2;
  parameter real iActive = 200e-6;
  parameter real iStandby = 1e-6;
  parameter real lsbRatio = 0.001;
  parameter real updateDelay = 5e-9; // delay in seconds

  input logic signed [7:0] in;
  input logic en;
  input wreal4state vref;
  output wreal4state outp, outn;
  inout EEnet vdd, vss;

  real lsbSize;
  real outDiff;
  reg enInt = 0;
  reg dacOn;
  reg vddGood;
  reg vssGood;
  reg vrefGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  logic vrefGoodFilt;
  real  iSupply;
  logic supplyOK;

  initial begin
     lsbSize = 0.5e-3;
  end

//  Current source to model active core (background) current
   Isrc_ideal_gaussian #(.tr(4e-9)) coreLoad (
       .P          (vdd),
       .N          (vss), 
       .ival       (iSupply)
  );

  always @ (vdd.V)
      vddGood = ((vdd.V >= vddMin) && (vdd.V <= vddMax));
  // glitch filter
  assign #(200e-9) vddGoodFilt = vddGood;
  
  always @ (vss.V)
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
  // glitch filter
  assign #(200e-9) vssGoodFilt = vssGood;

  always @ (vref)
      vrefGood = ((vref >= vrefMin) && (vref <= vrefMax));
  // glitch filter
  assign #(200e-9) vrefGoodFilt = vrefGood;

  assign supplyOK = vddGoodFilt && vssGoodFilt && vrefGoodFilt;

   always @ (en)
      if (en === 1'b1)  enInt = 1;
      else enInt = 1'b0;

   // Determine operating state
   always @ (enInt or supplyOK) begin
      if ((enInt == 1'b1) && (supplyOK === 1'b1)) begin
          dacOn = 1;
      end
      else begin
          if (supplyOK !== 1'b1) begin
             outDiff = `wrealZState;
             dacOn = 0;
          end
          else begin
             outDiff = 0;
             dacOn = 0;
          end
     end
  end

  // The LSB size is a ratio of the reference voltage
  always @ (enInt or vref) begin
     if (vref !== `wrealZState)
        lsbSize = vref * lsbRatio;
     else
        lsbSize = 0;
  end

  // Set the differential output based on input and LSB size
  always @ (dacOn or in) begin
     if ((^in !== 1'bz) && (^in !==1'bx))
        outDiff = in * lsbSize;
     else outDiff = 0.0;
  end

  // Generate the single-ended outputs 
  assign #(updateDelay) outp = outDiff / 2.0;
  assign #(updateDelay) outn = -outDiff / 2.0;

  assign iSupply = (iStandby * (vddGoodFilt & vssGoodFilt)) + (dacOn * iActive);

endmodule
