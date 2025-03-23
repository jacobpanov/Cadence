//systemVerilog HDL for "PLL", "xorPhDet" "systemVerilog"
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
// XOR Phase Detector for PLL
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1fs
import cds_rnm_pkg::*;
import EE_pkg::*;

module xorPhDet ( out, vdd, vss, refinm, refinp, resetb, vcoinm, vcoinp );

  input refinp;
  input refinm;
  output out;
  input vcoinp;
  input resetb;
  inout EEnet vdd;
  input vcoinm;
  inout EEnet vss;

  parameter real vddMin = 1.4;
  parameter real vddMax = 1.8;
  parameter real vssMax = 0.1;
  parameter real iActive = 300e-6;
  parameter real iStandby = 1e-6;

  logic refInDiff;
  logic vcoInDiff;
  reg outReg;
  reg enInt = 0;
  reg pdOn;  
  reg vddGood;
  reg vssGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  real iSupply;
  logic supplyOK;

  always @ (vdd.V)
      vddGood = ((vdd.V >= vddMin) && (vdd.V < vddMax));
  assign #(250e-9) vddGoodFilt = vddGood;
  
  always @ (vss.V)
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
  assign #(250e-9) vssGoodFilt = vssGood;

  assign supplyOK = vddGoodFilt && vssGoodFilt;

   always @ (resetb)
      if (resetb === 1'b1)  enInt = 1;
      else enInt = 1'b0;

   always @ (posedge (enInt && (supplyOK == 1'b1)))
      begin
          pdOn = 1;
          outReg = 1'b0;
      end

   always @ ((negedge enInt) or vddGoodFilt or vssGoodFilt)
      begin
          if ((vddGoodFilt !== 1'b1) || (vssGoodFilt !== 1'b1)) begin
             outReg = 1'bx;
             pdOn = 1'b0;
          end
          else if (enInt != 1'b1) begin
             outReg = 1'b0;
             pdOn = 1'b0;
          end
      end

   always @ (refInDiff or vcoInDiff)
      outReg = refInDiff ^ vcoInDiff;

  assign iSupply = (iStandby * supplyOK) + (pdOn * iActive);
  assign refInDiff = refinp | !refinm;
  assign vcoInDiff = vcoinp | !vcoinm;
  assign out = outReg & enInt;

//  Current source to model active core (background) current
   Isrc_ideal_gaussian #(.tr(1e-7)) coreLoad (
       .P          (vdd),
       .N          (vss), 
       .ival       (iSupply)
  );

endmodule
