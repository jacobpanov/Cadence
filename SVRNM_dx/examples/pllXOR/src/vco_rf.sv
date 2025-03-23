//systemVerilog HDL for "PLL", "vco_rf" "systemVerilog"
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
//  RF Voltage Controlled Oscillator Model
//    Includes a coarse tuning port, and a
//    High Frequency Modulation Port
//    
//--------------------------------------------------------------------------------------

`timescale 1s / 1fs

module vco_rf import cds_rnm_pkg::*; import EE_pkg::*; ( outn, outp, en, modin, vdd, vss, vtune, courseTune );

  input wreal4state vtune;
  inout EEnet vdd;
  inout EEnet vss;

  input  [5:0] modin;
  input  [6:0] courseTune;
  input  en;

  output outp;
  output outn;

//  wreal vtune, vdd, vss;

  parameter real fNom = 4840e6;
  parameter real Kv = 50e6;
  parameter real modStep = 31250;
  parameter real vddMin = 1.0;
  parameter real vddMax = 1.8;
  parameter real vssMax = 0.1;
  parameter real iActive = 800e-6;
  parameter real iStandby = 1e-6;
  parameter real stdbyPer = 1e-6;
  parameter real startTime = 20; //number of equivalent clock cycles for startup time
  parameter real courseTuneStep = 6e6;

  reg enInt = 0;
  reg [5:0] modInt = 6'h20;
  reg [6:0] courseInt = 7'h40;
  integer signed modFreq;
  real instFreq;
  real tuneFreq; //for debug
  real instPeriod;
  reg vcoOn;
  reg outputOn;
  reg vddGood;
  reg vssGood;
  reg outputReg;
  logic vddGoodFilt;
  logic vssGoodFilt;
  integer startCount;
  real iSupply;
  real vtuneInt;
  logic supplyOK;
  real fNomOffset = 0.0; // nominal frequency make tolerance

//  Current source to model active core (background) current
   Isrc_ideal_gaussian #(.tr(1/1e8)) coreLoad (
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
  
  always @ (modin)
      if ((^modin !== 1'bx) && (^modin !== 1'bz)) modInt = modin;
      else  modInt = 6'h20;

  always @ (courseTune)
      if ((^courseTune !== 1'bx) && (^courseTune !== 1'bz)) courseInt = courseTune;
      else  courseInt = 7'h40;

   always @ (en)
      if (en === 1'b1)  enInt = 1;
      else enInt = 1'b0;

   always @ (vtune)
      begin
      if ((vtune === `wrealZState) || (vtune === `wrealXState) || (vtune < vss.V))
          vtuneInt = 0;
      else if (vtune > vdd.V)
          vtuneInt = vdd.V;
      else
          vtuneInt = vtune;
//      $display("vtune %f", vtune);
//      $display("vdd %f", vdd);
//      $display("vtuneInt %f", vtuneInt);
      end

   always @ (posedge (enInt && (supplyOK == 1'b1)))
      begin
          startCount = 0;
          vcoOn = 1;
          outputReg = 1'b0;
      end

   always @ ((negedge enInt) or vddGoodFilt or vssGoodFilt)
      begin
          if ((vddGoodFilt !== 1'b1) || (vssGoodFilt !== 1'b1)) begin
             outputReg = 1'bx;
             outputOn = 1'b0;
             vcoOn = 1'b0;
          end
          else if (enInt != 1'b1) begin
             outputReg = 1'b0;
             outputOn = 1'b0;
             vcoOn = 1'b0;
          end
      end

   always @ (modInt or vcoOn)
      if (vcoOn === 1'b1)
          modFreq = (modInt - 32) * modStep;

   always #(instPeriod/2)
      begin
          if ((outputOn !== 1'b1) && (vcoOn === 1'b1))
               if (startCount < startTime)
                  startCount = startCount +1;
               else
                  outputOn = 1'b1;

          if (vcoOn == 1'b1) 
             begin
                  instFreq = fNom + ((vtuneInt - vdd.V/2) * Kv) + (modFreq) + ($signed(courseInt-64)*courseTuneStep) + fNomOffset;
                  tuneFreq =  ($signed(courseInt-64)*courseTuneStep);
                  instPeriod = (1/instFreq);
//                  $display("instPeriod %f", instPeriod);
//                  $display("instFreq %f", instFreq);
                  if ((instPeriod === `wrealZState) || (instPeriod < 0)) $stop;
             end
          else
                  instPeriod = stdbyPer; 

          if (outputOn === 1'b1)
                  outputReg = ~outputReg;
      end

  assign iSupply = (iStandby*supplyOK) + (vcoOn*iActive);
  assign outp = outputReg;
  assign outn = !outputReg;

 initial
     begin
        instPeriod = stdbyPer;

     end



endmodule
