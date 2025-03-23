//systemVerilog HDL for "SAR_ADC", "sarSamplingMux" "systemVerilog"
//--------------------------------------------------------------------------------------
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
//  Sample and Hold with 2-channel multiplexing for use in SAR ADC model
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1ps

module sarSamplingMux import cds_rnm_pkg::*; import EE_pkg::*; (
   iinp, iinm, qinp, qinm, vdd, vss, vcm, en, clkp, clkm, outp, outm );
  parameter real vddMin = 1.0;
  parameter real vddMax = 1.8;
  parameter real vssMax = 0.1;
  parameter real vcmMax = 1.2;
  parameter real vcmMin = 0.4;
  parameter real iActive = 50e-6;
  parameter real iStandby = 1e-6;

 
  input wreal4state iinp, iinm, qinp, qinm, vcm;
  output wreal4state outp, outm;
  inout  EEnet vdd, vss;
  input logic en, clkp, clkm;
  

  real inDiff;
  reg  enInt = 0;
  reg  muxOn;
  reg vddGood;
  reg vssGood;
  logic vddGoodFilt;
  logic vssGoodFilt;  
  reg vcmGood;
  logic vcmGoodFilt;
  real  iSupply;
  logic supplyOK;
  real  outDiff;
  integer i;
  logic clk;
  reg clk_div2;
  real iOffset = 0.0;
  real qOffset = 0.0;
  reg  sampChan = 0; // 0 = I, 1 = Q


  initial begin
     clk_div2 = 1'b0;
  end

  always @ (vdd.V)
      vddGood = ((vdd.V >= vddMin) && (vdd.V < vddMax));
  assign #(250e-9) vddGoodFilt = vddGood;
  
  always @ (vss.V)
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
  assign #(250e-9) vssGoodFilt = vssGood;

  always @ (vcm)
      vcmGood = ((vcm <= vcmMax) && (vcm >= vcmMin));
  assign #(250e-9) vcmGoodFilt = vcmGood;

  assign supplyOK = vddGoodFilt   &&
                    vssGoodFilt   &&
                    vcmGoodFilt     ;

   always @ (en)
      if (en === 1'b1)  enInt = 1;
      else enInt = 1'b0;

   always @ (enInt or supplyOK )
      begin
         if ((enInt == 1'b1) && (supplyOK === 1'b1)) begin
            muxOn = 1'b1;
            outDiff = 0.0;
         end
         else begin
            if (supplyOK !== 1'b1) begin
               outDiff = `wrealZState;
               muxOn = 1'b0;
            end
            else begin
               outDiff = 0.0;
               muxOn = 1'b0;
            end
         end
      end

/*
// Changing to get a 1/2 rate clock at input
  always @ (posedge clk)
     if (muxOn === 1'b1)
        clk_div2 = ~clk_div2;
     else
        clk_div2 = 1'b0;
*/

  always @ (clk) begin //use pos and neg edges
    if(muxOn) begin
        if (clk == 1) begin
           inDiff = (iinp - iinm) + iOffset;
           sampChan = 0;
        end
        else begin
           inDiff = (qinp - qinm) + qOffset;
           sampChan = 1;
        end
    end
  end

  always @ (inDiff) begin
     if (muxOn == 1'b1)
        outDiff = inDiff;
     else if (supplyOK == 1'b1)
        outDiff = 0.0;
     else 
        outDiff = `wrealZState;
  end
       
  assign clk = clkp && !clkm;
  assign iSupply = (vddGoodFilt * iStandby) + (muxOn * iActive);
  assign outp = vcm + (outDiff / 2);
  assign outm = vcm - (outDiff / 2);

endmodule
