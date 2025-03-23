//systemVerilog HDL for "SAR_ADC", "sarComparator" "systemVerilog"
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
// Clocked latching comparator for use in SAR ADC model
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1ps
import cds_rnm_pkg::*;
import EE_pkg::*;

module sarComparator ( inp, inm, clkp, clkn, vdd, vss, en, out );

  parameter real vddMin = 1.0;
  parameter real vddMax = 1.8;
  parameter real vssMax = 0.1;
  parameter real iActive = 50e-6;
  parameter real iStandby = 1e-6;
  parameter real updateDelay = 0.25e-9; // delay i ns

  input wreal4state inp, inm;
  inout EEnet vdd, vss;
  input logic clkp, clkn;
  input logic en;
  output logic out;

  reg enInt = 0;
  reg compOn;
  reg vddGood;
  reg vssGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  real  iSupply;
  logic supplyOK;
  reg outReg;
  logic clk;

  always @ (vdd.V)
      vddGood = ((vdd.V >= vddMin) && (vdd.V <= vddMax));
  assign #(250e-9) vddGoodFilt = vddGood;
  
  always @ (vss.V)
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
  assign #(250e-9) vssGoodFilt = vssGood;
  assign supplyOK = vddGoodFilt && vssGoodFilt;

   always @ (en)
      if (en === 1'b1)  enInt = 1;
      else enInt = 1'b0;

   always @ (enInt or supplyOK)
      begin
         if ((enInt == 1'b1) && (supplyOK === 1'b1)) begin
           compOn = 1;
           outReg = 1'b0;
         end
    
         else begin
            if (supplyOK !== 1'b1) begin
               outReg =  1'bx;
               compOn = 0;
            end
            else begin
               outReg = 1'b0;
               compOn = 0;
            end
         end
     end

  always @ (posedge clk) begin
     if (compOn == 1'b1)
        outReg = (inp >= inm);
     else
        outReg = (supplyOK == 1) ? 1'b0 : 1'bx;
  end

  assign iSupply = (iStandby * supplyOK) + (compOn * iActive);
  assign #(updateDelay) out = outReg;
  assign clk = clkp & !clkn;

endmodule
