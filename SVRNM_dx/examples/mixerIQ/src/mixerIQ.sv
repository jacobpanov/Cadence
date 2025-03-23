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
// I and Q Balanced Commutating Mixer Model for Receive path
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1fs
import cds_rnm_pkg::*;
import EE_pkg::*;

module mixerIQ ( ifim, ifip, ifqm, ifqp, vdd, vss, LOim, LOip, LOqm, LOqp, en,
rfm, rfp );

  input LOip;
  input LOim;
  input wreal4state rfm;
  input wreal4state rfp;
  input LOqp;
  output wreal4state ifqp;
  output wreal4state ifqm;
  input LOqm;
  output wreal4state ifip;
  output wreal4state ifim;
  input en;
  inout EEnet vdd;
  inout EEnet vss;

  parameter vddMin = 1.0;
  parameter vddMax = 1.8;
  parameter vssMax = 0.1;
  parameter iActive = 80e-6;
  parameter iStandby = 1e-6;
  parameter amplNom = 250e-3;

  reg enInt = 0;
  reg mixOn;
  reg vddGood;
  reg vssGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  real ifOutIp;
  real ifOutIm;
  real ifOutQp;
  real ifOutQm;
  real iSupply;
  real vCM;

//  Current source to model active core (background) current
   Isrc_ideal #(.tr(0)) coreLoad (
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
          mixOn = 1;
          ifOutIp = 0.0;
          ifOutIm = 0.0;
          ifOutQp = 0.0;
          ifOutQm = 0.0;
      end

   always @ ((negedge enInt) or vddGoodFilt or vssGoodFilt)
      begin
          if ((vddGoodFilt !== 1'b1) || (vssGoodFilt !== 1'b1)) begin
          ifOutIp = `wrealZState;
          ifOutIm = `wrealZState;
          ifOutQp = `wrealZState;
          ifOutQm = `wrealZState;
          mixOn = 1'b0;
          end
          else if (enInt == 1'b0) begin
          ifOutIp = 0.0;
          ifOutIm = 0.0;
          ifOutQp = 0.0;
          ifOutQm = 0.0;
          mixOn = 1'b0;
          end

      end

   always @ (LOip or LOim or LOqp or LOqm or rfp or rfm)
   begin
      if (mixOn == 1'b1)
      begin
         ifOutIp = (LOip * rfp) + (LOim * rfm);
         ifOutIm = (LOim * rfp) + (LOip * rfm);

         ifOutQp = (LOqp * rfp) + (LOqm * rfm);
         ifOutQm = (LOqm * rfp) + (LOqp * rfm);
      end
   end

  assign vCM = (mixOn == 1'b1) ? (vdd.V-vss.V)/2 : 0;

  assign ifip = vCM + ifOutIp;
  assign ifim = vCM + ifOutIm;
  assign ifqp = vCM + ifOutQp;
  assign ifqm = vCM + ifOutQm;

  assign iSupply = (iStandby * (vddGoodFilt & vssGoodFilt)) + (mixOn * iActive);
endmodule
