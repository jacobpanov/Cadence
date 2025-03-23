//systemVerilog HDL for "PLL", "divider2" "systemVerilog"
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
// Enhanced PLL loop divider model with high-speed ADC clock output
// Also latches divide value with rising edge of divided output
// Divide range is from divMin to divMin+31
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1fs

module divider2 import cds_rnm_pkg::*; import EE_pkg::*; ( outm, outp, vdd, vss, div, en, inm, inp, adcClkp, adcClkm );

  parameter real vddMin = 1.0;
  parameter real vddMax = 1.8;
  parameter real vssMax = 0.1;
  parameter real iActive = 300e-6;
  parameter real iStandby = 1e-6;
  parameter real divMin = 284;
  parameter real adcClkRatio = 10.0;

  input  [4:0] div;
  input inp;
  input inm;
  input en;
  inout EEnet vdd;
  output outp;
  output outm;
  inout EEnet vss;
  output logic adcClkp, adcClkm;

  reg enInt = 0;
  reg divOn;  
  reg vddGood;
  reg vssGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  wreal4state iSupply;
  integer divRatio;
  logic inDiff;
  reg outDiff;
  integer divCount;
  logic supplyOK;
  integer adcDivRatio;
  integer adcDivCount;
  reg     adcOutDiff;

//  Current source to model active core (background) current
   Isrc_ideal_gaussian #(.tr(1e-10)) coreLoad (
       .P          (vdd),
       .N          (vss), 
       .ival       (iSupply)
  );

  always @ (vdd.V)
      vddGood = ((vdd.V >= vddMin) && (vdd.V < vddMax));
  assign #(250e-9) vddGoodFilt = vddGood;
  
  always @ (vss.V)
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
  assign #(250e-9) vssGoodFilt = vssGood;

  assign supplyOK = vddGoodFilt && vssGoodFilt;

   always @ (en)
      if (en === 1'b1)  enInt = 1;
      else enInt = 1'b0;

   always @ (enInt or supplyOK) begin
      if ((enInt == 1'b1) && (supplyOK === 1'b1)) begin
          divOn = 1;
          outDiff = 1'b0;
          adcOutDiff = 1'b0;
          divCount = 0;
          adcDivCount = 0;
      end
      else if (supplyOK !== 1'b1) begin
          outDiff = 1'bx;
          adcOutDiff = 1'bx;
          divOn = 1'b0;
      end
      else if (enInt != 1'b1) begin
          outDiff = 1'b0;
          adcOutDiff = 1'b0;
          divOn = 1'b0;
       end
   end 

   always @ (divOn) begin
      // Make sure div ratios are always not x
      divRatio = (^div !== 1'bx) ? div + divMin : divMin;
      adcDivRatio = $floor(divRatio / adcClkRatio);
   end

  always @ (posedge outDiff)
  // essentially, latch the div value at the beginning of a new count
  // and don't let it change until the next count
      if ((enInt === 1'b1) && (^div !== 1'bx) && (^div !== 1'bz)) begin
         divRatio = div + divMin;
         adcDivRatio = $floor(divRatio / adcClkRatio);
      end
      else begin
         divRatio = divMin;
         adcDivRatio = $floor(divRatio / adcClkRatio);
      end

  assign iSupply = (iStandby * supplyOK) + (divOn * iActive);
  assign inDiff = inp | !inm;
  assign outp = outDiff;
  assign outm = !outDiff;
  assign adcClkp = adcOutDiff;
  assign adcClkm = !adcOutDiff;

  always @ (posedge inDiff)
     begin
        if (enInt === 1'b1)
           begin
               if (divCount > (divRatio - 2)) //if count target reached, 
                  begin
                     outDiff = ~outDiff;      //toggle output and
                     divCount = 0;            //reset count
                  end
               else if ((divCount >= ((divRatio/2)-1)) && (divCount < (divRatio/2) )) // if half count reached,
                  begin
                     outDiff = ~outDiff;          // toggle output and
                     divCount = divCount + 1;     // increment count
                  end
              else  divCount = divCount + 1;     // otherwise, just increment

              if (adcDivCount > (adcDivRatio -2)) // if adc count reached,
                  begin
                     adcOutDiff = ~adcOutDiff;    //toggle output and
                     adcDivCount = 0;             //reset count
                  end
               else if ((adcDivCount >= ((adcDivRatio/2)-1)) && (adcDivCount < (adcDivRatio/2) )) // if half count reached,
                  begin
                     adcOutDiff = ~adcOutDiff;      // toggle output and
                     adcDivCount = adcDivCount + 1; // increment count
                  end
              else  adcDivCount = adcDivCount + 1;     // otherwise, just increment
           end
     end


endmodule
