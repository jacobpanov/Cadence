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
// Divide-by-2 for Transmitter direct launch
//
//---------------------------------------------------------------

`timescale 1s / 1fs


module div2Tx import cds_rnm_pkg::*; import EE_pkg::*; ( 
  output txip,
  output txim,
  input vcop,
  input vcom,
  input en,
  inout EEnet vdd,
  inout EEnet vss,
  input wreal4state ibias);

  parameter vddMin = 1.0;
  parameter vddMax = 2.0;
  parameter vssMax = 0.1;
  parameter iActive = 400e-6;
  parameter iStandby = 1e-6;
  parameter real iBiasMax = 2e-6;
  parameter real iBiasMin = 500e-9;

  logic vcoDiff;
  logic enInt = 1'b0;
  real iSupply;
  logic supplyOK;
  logic vddGoodFilt;
  logic vssGoodFilt;
  reg vddGood;
  reg vssGood;
  reg divOn;
  reg TxDiff;
  logic ibiasGood, ibiasGoodFilt;

//  Current source to model active core (background) current
   Isrc_ideal_gaussian #(.tr(1e-8)) coreLoad (
       .P          (vdd),
       .N          (vss), 
       .ival       (iSupply)
  );

  always @ (vdd.V or en)
      vddGood = (vdd.V >= vddMin) && (vdd.V <= vddMax);
  assign #(250e-9) vddGoodFilt = vddGood;
  
  always @ (vss.V or en)
      vssGood = (vss.V <= vssMax) && (vss.V >= -vssMax);
  assign #(250e-9) vssGoodFilt = vssGood;
  assign supplyOK = vddGoodFilt && vssGoodFilt && ibiasGoodFilt;

  // Monitor ibias and raise flag when good
  // <<< Your code here >>>
  // (( Be sure to update supplyOK expression as well ))
  always @ (ibias)
      ibiasGood = (ibias <= iBiasMax) && (ibias >= iBiasMin);
  assign #(250e-9) ibiasGoodFilt = ibiasGood;

   always @ (en)
      if (en === 1'b1)  enInt = 1;
      else enInt = 1'b0;

   always @ (enInt or supplyOK)
      begin
         if ((enInt == 1'b1) && (supplyOK === 1'b1)) begin
            divOn = 1;
            TxDiff = 1'b0;
         end

         else begin
            if (supplyOK !== 1'b1) begin
                TxDiff = 1'bx;
                divOn = 0;
            end
            else begin
                TxDiff = 1'b0;
                divOn = 0;
            end
         end
      end

   always @ ((negedge enInt) or vddGoodFilt or vssGoodFilt)
      begin
          if ((vddGoodFilt !== 1'b1) || (vssGoodFilt !== 1'b1)) begin
             TxDiff = 1'bx;
             divOn = 1'b0;
          end
          else begin
             TxDiff = 1'b0;
             divOn = 1'b0;
          end
      end

   assign vcoDiff = divOn & (vcop & !vcom);

   always @ (posedge vcoDiff)
       TxDiff = ~TxDiff;


   assign txip = TxDiff;
   assign txim = !TxDiff;

  assign iSupply = (iStandby * (vddGoodFilt & vssGoodFilt)) + (divOn * iActive);

endmodule
