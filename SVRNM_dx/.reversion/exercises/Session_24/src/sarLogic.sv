//systemVerilog HDL for "SAR_ADC", "sarLogic" "systemVerilog"
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
// Behavioral Model of SAR logic for SAR ADC
//   The high speed fClk must be at least 9X sampleClk
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1ps

module sarLogic import EE_pkg::*; ( 
   sampleClkP, sampleClkN, fClkP, fClkN, dacIn, 
   compOutP, compOutN, vdd, vss, en, outI, outQ, 
   cClkp, cClkn, outClkI, outClkQ, muxClkp, muxClkn );

  parameter real vddMax = 1.8;
  parameter real vddMin = 1.0;
  parameter real vssMax = 0.1;
  parameter real iActive = 100e-6;
  parameter real iStandby = 1e-6;
  parameter real cmpDelay = 1.5e-9;

  input logic sampleClkP, sampleClkN, fClkP, fClkN, compOutP, compOutN, en;
  output logic [7:0] outI, outQ, dacIn;
  inout EEnet vdd, vss;
  output logic cClkp, cClkn, outClkI, outClkQ, muxClkp, muxClkn;

  real iSupply;
  logic sClk;
  logic fClk;
  logic cClk;
  integer i;
  logic [7:0] outTemp;
  reg sarOn;
  reg vddGood;
  reg vssGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  logic supplyOK;
  reg enInt = 0;
  reg [7:0] dacInNext;
  reg sClk_div2;

  initial begin
     sClk_div2 = 1'b0;
  end

  always @ (vdd.V)
      vddGood = ((vdd.V >= vddMin) && (vdd.V < vddMax));
  assign #(250e-9) vddGoodFilt = vddGood;
  
  always @ (vss.V)
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
  assign #(250e-9) vssGoodFilt = vssGood;

  assign supplyOK = vddGoodFilt && vssGoodFilt ;

   always @ (en)
      if (en === 1'b1)  enInt = 1;
      else enInt = 1'b0;

   always @ (enInt or supplyOK)
     begin
        if ((enInt == 1'b1) && (supplyOK === 1'b1)) begin
          sarOn = 1'b1;
          outTemp = 8'h00;
        end
        else begin
          if (supplyOK !== 1'b1) begin
             outTemp = 8'hXX;;
             sarOn = 0;
          end
          else begin
             outTemp = 8'h00;
             sarOn = 0;
          end
       end
     end

  assign sClk = sarOn && (sampleClkP & !sampleClkN);
  assign fClk = sarOn && (fClkP & !fClkN);
  assign muxClkp = sarOn && sClk_div2;
  assign muxClkn = sarOn && !sClk_div2;
  

// Since DAC is updated on negedge and comparator is sampled on posedge, need a
// Comparator clock that is in between!
  always @ (fClk) begin
       #(cmpDelay);
       cClk = ~fClk;
  end
  assign cClkp = cClk;
  assign cClkn = !cClk;

// if the ADC is off, immediately assign the temp to both outputs.
// otherwise, if the sample clock is low then only outI gets updated,
  assign outI = (sarOn !== 1'b1) ? outTemp : ( (sClk_div2 == 1'b0) ? outTemp : outI );
  assign #(2e-9) outClkI = ((sarOn === 1'b1) && (sClk_div2 == 1'b0));
// and if sample clock is high then only outQ gets updated.
  assign outQ = (sarOn !== 1'b1) ? outTemp : ( (sClk_div2 == 1'b1) ? outTemp : outQ );
  assign #(2e-9) outClkQ = ((sarOn === 1'b1) && (sClk_div2 == 1'b1));

  always @ (posedge sClk) sClk_div2 = ~sClk_div2;

// Main SAR control loop:
  always @ (posedge fClk) begin
     if ((i > 0) && (i <= 8)) begin
        if (compOutP == compOutN)
           dacInNext[8-i] = compOutP; //doesn't matter which one, since they are equal
        else 
           dacInNext[8-i] = compOutP & !compOutN; // somewhat arbitrary resolution
        if (i < 8) // set the next lsb to a 1 to prep for next cycle:
           dacInNext[7-i] = 1'b1;
     end
  end

  always @ (negedge fClk) begin
  // this one should always go first...
     if (i < 8) begin
        dacIn = dacInNext;
        i = i + 1;
     end
  end

  always @ (sClk_div2) begin
     i = 0;
     outTemp = dacIn;
     dacInNext = 8'h80;
  end

endmodule
