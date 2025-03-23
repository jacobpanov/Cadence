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
// systemVerilog HDL for "RX", "div2Qgen" "systemVerilog"
//--------------------------------------------------------------------------------------
//
// Divide-by-2 and Quadrature Generation for RX LO injection
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1fs


module div2Qgen import cds_rnm_pkg::*; import EE_pkg::*;
       ( LOim, LOip, LOqm, LOqp, vdd, vss, en, vcom, vcop );

  output LOip;
  output LOim;
  input vcop;
  output LOqp;
  output LOqm;
  input vcom;
  input en;
  inout EEnet vdd;
  inout EEnet vss;

  parameter vddMin = 1.0;
  parameter vddMax = 1.8;
  parameter vssMax = 0.1;
  parameter iActive = 400e-6;
  parameter iStandby = 1e-6;

  logic vcoDiff;
  logic enInt = 0;
  real  iSupply;
  logic vddGoodFilt;
  logic vssGoodFilt;
  reg vddGood;
  reg vssGood;
  reg divOn;
  reg LOiDiff;
  reg LOqDiff;
  real tDiff;
  real iqPhaseErr = 0; //error in degrees. 0 is perfect quadrature
  real iDelay;
  real qDelay;

//  Current source to model active core (background) current
   Isrc_ideal_gaussian #(.tr(1e-9)) coreLoad (
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

   always @ (enInt or vddGoodFilt or vssGoodFilt) begin
      if ((enInt == 1'b1) && (vddGoodFilt === 1'b1) && (vssGoodFilt === 1'b1)) begin
          divOn = 1;
          LOiDiff = 1'b0;
          LOqDiff = 1'b0;
      end
      else if ((vddGoodFilt !== 1'b1) || (vssGoodFilt !== 1'b1)) begin
          LOiDiff = 1'bx;
          LOqDiff = 1'bx;
          divOn = 1'b0;
      end
      else if (enInt == 1'b0) begin
             LOiDiff = 1'b0;
             LOqDiff = 1'b0;
             divOn = 1'b0;
      end
   end

   assign vcoDiff = divOn & (vcop & !vcom);

   always @ (posedge vcoDiff)
       LOiDiff = ~LOiDiff;

   always @ (negedge vcoDiff)
       LOqDiff = ~LOqDiff;

   always @ (posedge LOiDiff) begin
      tDiff = $realtime;
      @ (posedge LOqDiff)
      tDiff = $realtime - tDiff;
      if (iqPhaseErr > 0.0) begin
         iDelay = 0.0;
         qDelay = (iqPhaseErr / 90 ) * tDiff; //advance Q by a fraction of 90 degrees
      end
      else if (iqPhaseErr < 0.0) begin
         iDelay = -(iqPhaseErr / 90 ) * tDiff; //advance I by a fraction of 90 degrees
         qDelay = 0.0;
      end
      else begin
         iDelay = 0.0;
         qDelay = 0.0;
      end
   end

   assign #(iDelay) LOip = LOiDiff;
   assign #(iDelay) LOim = !LOiDiff;

  assign #(qDelay) LOqp = LOqDiff;
  assign #(qDelay) LOqm = !LOqDiff;

  assign iSupply = (iStandby * (vddGoodFilt & vssGoodFilt)) + (divOn * iActive);

endmodule
