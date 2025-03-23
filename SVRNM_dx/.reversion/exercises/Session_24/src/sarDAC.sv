//systemVerilog HDL for "SAR_ADC", "sarDAC" "systemVerilog"
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
// D to A converter for use with SAR ADC model
//   
//--------------------------------------------------------------------------------------

`timescale 1s / 1ps

module sarDAC import cds_rnm_pkg::*; import EE_pkg::*; (
   vdd, vss, in, en, outp, outn, vref1, vcm, vref2 );

  parameter real vddMax = 1.8;
  parameter real vddMin = 1.0;
  parameter real vssMax = 0.1;
  parameter real vref1Max = 1.8;
  parameter real vref1Min = 1.0;
  parameter real vref2Max = 0.8;
  parameter real vref2Min = 0.0;
  parameter real vcmMax = 1.2;
  parameter real vcmMin = 0.4;
  parameter real iActive = 800e-6;
  parameter real iStandby = 1e-6;
  parameter real lsbRatio = 0.001;
  parameter real updateDelay = 0.5e-9; // delay i seconds

  input logic [7:0] in;
  input logic en;
  input wreal4state vref1, vcm, vref2;
  output wreal4state outp, outn;
  inout EEnet vdd, vss;

  real lsbSize;
  real outDiff;
  reg enInt = 0;
  reg dacOn;
  reg vddGood;
  reg vssGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  reg vref1Good;
  reg vref2Good;
  logic vref1GoodFilt;
  logic vref2GoodFilt;
  reg vcmGood;
  logic vcmGoodFilt;
  real  iSupply;
  logic supplyOK;
  real  vmin;
  real  vmax;
  real  dcOffset = 0.0;

  initial begin
     lsbSize = 0.5e-3;
  end

  always @ (vdd.V)
      vddGood = ((vdd.V >= vddMin) && (vdd.V < vddMax));
  assign #(250e-9) vddGoodFilt = vddGood;
  
  always @ (vss.V)
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
  assign #(250e-9) vssGoodFilt = vssGood;

  always @ (vref1)
      vref1Good = ((vref1 <= vref1Max) && (vref1 >= vref1Min));
  assign #(250e-9) vref1GoodFilt = vref1Good;
  assign vmax = (vref1 - vcm) * 2;  //should always be +ive

  always @ (vref2)
      vref2Good = ((vref2 <= vref2Max) && (vref2 >= vref2Min));
  assign #(250e-9) vref2GoodFilt = vref2Good;
  assign  vmin = (vref2 - vcm) *2; //should always be -ive

  always @ (vcm)
      vcmGood = ((vcm <= vcmMax) && (vcm >= vcmMin));
  assign #(250e-9) vcmGoodFilt = vcmGood;

  assign supplyOK = (vref1 < vdd.V) && 
                    (vcm < vref1) && 
                    (vref2 < vcm) && 
                    (vss.V < vref2) &&
                    vddGoodFilt   &&
                    vssGoodFilt   &&
                    vref1GoodFilt &&
                    vref2GoodFilt &&
                    vcmGoodFilt     ;

   always @ (en)
      if (en === 1'b1)  enInt = 1;
      else enInt = 1'b0;

   always @ (posedge (enInt && supplyOK))
      begin
          dacOn = 1;
      end

   always @ ((negedge enInt) or supplyOK)
      begin
          if (supplyOK !== 1'b1) begin
             outDiff = `wrealZState;
          end
          else begin
             outDiff = 0;
          end
        dacOn = 0;
     end

  always @ (enInt or vmax or vmin) begin
     if ((vmax !== `wrealZState) && (vmin !== `wrealZState))
        lsbSize = (vmax - vmin) / (2**8);
     else
        lsbSize = 0;
  end

  always @ (enInt or in) begin
     if ((^in !== 1'bz) && (^in !==1'bx))
        outDiff = ($signed(in - 127) * lsbSize) + dcOffset;
     else outDiff = 0.0;
  end

  assign #(updateDelay) outp = vcm + outDiff / 2.0;
  assign #(updateDelay) outn = vcm - outDiff / 2.0;

  assign iSupply = (iStandby * (vddGoodFilt & vssGoodFilt)) + (dacOn * iActive);

endmodule
