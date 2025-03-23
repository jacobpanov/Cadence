// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2016, Cadence Design Systems, Inc. All rights reserved.

// The model contained herein is the proprietary and confidential information of Cadence, 
// and is supplied subject to, and may be used only by Cadences customer in accordance with 
// a previously executed license and maintenance agreement between Cadence and that customer. 
// This model is intended for use with products only from Cadence Design Systems, Inc.  
// The use or sharing of any models from this library or any of its modified/extended form 
// is strictly prohibited with any non-Cadence products.
  
// ALL MATERIALS FURNISHED BY CADENCE HEREUNDER ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
// ANY KIND, AND CADENCE SPECIFICALLY DISCLAIMS ANY WARRANTY OF NONINFRINGEMENT, FITNESS 
// FOR A PARTICULAR PURPOSE OR MERCHANTABILITY. CADENCE SHALL NOT BE LIABLE FOR ANY COSTS 
// OF PROCUREMENT OF SUBSTITUTES, LOSS OF PROFITS, INTERRUPTION OF BUSINESS, OR FOR ANY 
// OTHER SPECIAL, CONSEQUENTIAL OR INCIDENTAL DAMAGES, HOWEVER CAUSED, WHETHER FOR BREACH 
// OF WARRANTY, CONTRACT, TORT, NEGLIGENCE, STRICT LIABILITY OR OTHERWISE.
// --------------------------------------------------------------
//
//  8-bit ADC array + Latch array
//  Array length = `NCOLS
//  Array output = 8-bit value corresponding to the channel selected by the input decoder
//
// --------------------------------------------------------------

`timescale 1ns / 1ps
`define NCOLS 2 //I and Q inputs will be interleaved
  import cds_rnm_pkg::*;
  import EE_pkg::*;

module ADC_8bit ( Vinp, Vinm, clkp, clkn, fclkp, fclkn, ADCEn, outi, outq, outClkI, outClkQ, VDD, VSS, VREF1, VREF2, VCM );

  input wreal4state Vinp [`NCOLS-1:0];
  input wreal4state Vinm [`NCOLS-1:0];
  input clkp, clkn, fclkp, fclkn;
  input ADCEn;
  input wreal4state VREF1, VREF2, VCM;
  input EEnet VDD, VSS;
  output [7:0] outi;
  output [7:0] outq;
  logic signed [7:0] outi;
  logic signed [7:0] outq;
  output logic outClkI, outClkQ;

  parameter real tconv = 0.005 ; //Conversion time in ns
  parameter real vddMax = 1.8;
  parameter real vddMin = 1.2;
  parameter real vssMax = 0.1;
  parameter real vref1Max = 1.8;
  parameter real vref1Min = 1.0;
  parameter real vref2Max = 0.8;
  parameter real vref2Min = 0.0;
  parameter real vcmMax = 1.2;
  parameter real vcmMin = 0.4;
  parameter real iActive = 800e-6;
  parameter real iStandby = 1e-6;

  integer i, k;
  genvar j;

  reg signed [7:0] latch_reg [`NCOLS-1:0];
  real norm_sample [`NCOLS-1:0];
  real vmax;
  real vmin;
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
  reg adcOn = 0;
  reg clk_div2 = 0;
  real iSupply;
  logic clk, fclk;
  logic supplyOK;

//  Current source to model active core (background) current
   Isrc_ideal #(.tr(1)) coreLoad (
       .P          (VDD),
       .N          (VSS), 
       .ival       (iSupply)
  );

  always @ (VDD.V)
      vddGood = ((VDD.V >= vddMin) && (VDD.V < vddMax));
  assign #(10) vddGoodFilt = vddGood;
  
  always @ (VSS.V or VSS.I or VSS.R)
      vssGood = ((VSS.V <= vssMax) && (VSS.V >= -vssMax));
  assign #(10) vssGoodFilt = vssGood;

 assign supplyOK = vddGoodFilt & vssGoodFilt;

  always @ (VREF1)
      vref1Good = ((VREF1 <= vref1Max) && (VREF1 >= vref1Min));
  assign #(10) vref1GoodFilt = vref1Good;
  assign vmax = (VREF1 - VCM) * 2;  //should always be +ive

  always @ (VREF2)
      vref2Good = ((VREF2 <= vref2Max) && (VREF2 >= vref2Min));
  assign #(10) vref2GoodFilt = vref2Good;
  assign  vmin = (VREF2 - VCM) *2; //should always be -ive

  always @ (VCM)
      vcmGood = ((VCM <= vcmMax) && (VCM >= vcmMin));
  assign #(10) vcmGoodFilt = vcmGood;

  assign Active = (VREF1 < VDD.V) && 
                  (VCM < VREF1) && 
                  (VREF2 < VCM) && 
                  (VSS.V < VREF2) &&
                  vddGoodFilt   &&
                  vssGoodFilt   &&
                  vref1GoodFilt &&
                  vref2GoodFilt &&
                  vcmGoodFilt     ;

  always @ (ADCEn or Active) 
     begin
        if ((ADCEn === 1'b1) && (Active === 1'b1))
            adcOn = 1'b1;
        else
            adcOn = 1'b0;
     end

  always @ (posedge clk)
      clk_div2 = ~clk_div2;
  
  always @ (clk_div2) begin //use pos and neg edges
    if(adcOn) begin
        i = clk_div2;
        norm_sample[i] = (Vinp[i] - Vinm[i])/(vmax - vmin);
        for (k=0;k<8;k=k+1) begin
           @ (posedge fclk);  // wait 8 fclks for conversion time
        end
        latch_reg[i] <= norm_sample[i] * (2**7);
      end

  end
  assign clk = clkp && !clkn;
  assign fclk = fclkp & !fclkn;
  assign outi = (adcOn) ? latch_reg[0] : 8'bz;
  assign #2 outClkI = clk_div2 & adcOn;
  assign outq = (adcOn) ? latch_reg[1] : 8'bz; 
  assign #2 outClkQ =  ~clk_div2 & adcOn;
  assign iSupply = (supplyOK * iStandby) + (adcOn * iActive);

endmodule
