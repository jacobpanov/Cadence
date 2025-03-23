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
// Low Noise RF Amplifier Model for Receiver System
//   Fixed Gain
//   No RF selectivity
//
//---------------------------------------------------------------

`timescale 1s / 1fs

module lna import cds_rnm_pkg::*; import EE_pkg::*; ( rfoutm, rfoutp, vdd, vss, en, rfinm, rfinp );

  output wreal4state rfoutp;
  input wreal4state rfinp;
  input wreal4state rfinm;
  input en;
  inout EEnet vdd;
  output wreal4state rfoutm;
  inout EEnet vss;

  parameter vddMin = 1.0;
  parameter vddMax = 1.8;
  parameter vssMax = 0.1;
  parameter iActive = 800e-6;
  parameter iStandby = 1e-6;
  parameter gaindB = 12;

  reg enInt = 0;
  reg lnaOn;
  reg vddGood;
  reg vssGood;
  real rfDiff;
  logic vddGoodFilt;
  logic vssGoodFilt;
  real iSupply;

//  Current source to model active and standby current
   Isrc_ideal_gaussian #(.tr(1e-11)) coreLoad (
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

   always @ (en)
      if (en === 1'b1)  enInt = 1;
      else enInt = 1'b0;

   always @ (posedge (enInt && (vddGoodFilt == 1'b1) && (vssGoodFilt == 1'b1)))
      begin
          lnaOn = 1;
      end

   always @ ((negedge enInt) or vddGoodFilt or vssGoodFilt)
      begin
          if ((vddGoodFilt !== 1'b1) || (vssGoodFilt !== 1'b1)) begin
             rfDiff = `wrealZState;
             lnaOn = 0;
          end
          else if (enInt == 1'b0) begin
             rfDiff = 0.0;
             lnaOn = 0;
         end
     end

   always @ (rfinp or rfinm)
      begin
         if (lnaOn == 1'b1) begin
            rfDiff = (10**(gaindB/20)) * (rfinp - rfinm);
         end
         else
            rfDiff = `wrealZState;
      end
  assign iSupply = (iStandby * (vddGoodFilt & vssGoodFilt)) + (lnaOn * iActive);
  assign rfoutp = rfDiff/2;
  assign rfoutm = -rfDiff/2;

endmodule
