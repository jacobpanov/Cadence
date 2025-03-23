//systemVerilog HDL for "PLL", "refClkGen" "systemVerilog"
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
//  Reference Clock Generator Model
//  Parameters can adjust start-up time and Frequency
// 
//--------------------------------------------------------------------------------------

`timescale 1s / 1fs

module refClkGen import cds_rnm_pkg::*; import EE_pkg::*; ( clk, clkb, vdd, vss, en );

  parameter real Frequency = 16e6;
  parameter real iActive = 200e-6;
  parameter real iStandby = 1e-6;
  parameter real startTime = 200; //number of equivalent clock cycles for startup time
  parameter real stdbyPer = 1e-6;
  parameter real vddMin = 1.0;
  parameter real vddMax = 2.2;
  parameter real vssMax = 0.1;

  input en;
  inout EEnet vdd;
  output clk;
  inout EEnet vss;
  output clkb;

  real instPeriod;
  reg vddGood;
  reg vssGood;
  reg outputReg;
  logic vddGoodFilt;
  logic vssGoodFilt;
  reg clkOn;
  reg enInt = 0;
  integer startCount;
  real iSupply;
  reg outputOn;
  real instFreq;
  logic supplyOK;
  real  fOffset = 0.0; //freq error ppm/1e6

//  Current source to model active core (background) current
   Isrc_ideal_gaussian #(.tr(1/1e7), .tol(1e-8)) coreLoad (
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

   always @ (posedge ((enInt === 1'b1) && (supplyOK === 1'b1)))
      begin
          startCount = 0;
          clkOn = 1;
          outputReg = 1'b0;
      end

   always @ ((negedge enInt) or vddGoodFilt or vssGoodFilt)
      begin
          if ((vddGoodFilt !== 1'b1) || (vssGoodFilt !== 1'b1)) begin
            outputReg = 1'bx;
            outputOn = 1'b0;
            clkOn = 1'b0;
          end
          else if (enInt == 1'b0) begin
            outputOn = 1'b0;
            clkOn = 1'b0;
          end
      end

   always #(instPeriod/2)
      begin
          if ((outputOn !== 1'b1) && (clkOn === 1'b1))
               if (startCount < startTime)
                  startCount = startCount +1;
               else
                  outputOn = 1'b1;

          if (clkOn == 1'b1) 
             begin
                  instFreq = Frequency*(1+fOffset);
                  instPeriod = (1/instFreq);
             end
          else
                  instPeriod = stdbyPer; 

          if (outputOn === 1'b1)
                  outputReg = ~outputReg;
      end

  assign iSupply = (iStandby * supplyOK) + (clkOn * iActive);
  assign clk = outputReg;
  assign clkb = !outputReg;

 initial
     begin
        instPeriod = stdbyPer;

     end


endmodule
