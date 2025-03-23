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
// Dummy Load block for LDO Testbench
//    When enabled and the supply is in range,
//    The block draws 1mA.
//    It has no function otherwise.
//
//---------------------------------------------------------------

`timescale 1s / 1fs


module load import EE_pkg::*; ( vdd, vss, en );

  input logic en;
  inout EEnet vdd;
  inout EEnet vss;

  parameter vddMin = 1.0;
  parameter vddMax = 1.4;
  parameter vssMax = 0.1;
  parameter iActive = 1000e-6;
  parameter iStandby = 1e-6;

  real  iSupply;
  logic vddGoodFilt;
  logic vssGoodFilt;
  reg vddGood;
  reg vssGood;
  reg loadOn;
  logic supplyOK;

//  Current source to model active core (background) current
   Isrc_ideal_gaussian #(.tr(1e-8)) coreLoad (
       .P          (vdd),
       .N          (vss), 
       .ival       (iSupply)
  );

// Supply checks
  always begin
      vddGood = ((vdd.V >= vddMin) && (vdd.V < vddMax));
      @ (vdd.V);
  end
  assign #(250ns) vddGoodFilt = vddGood;
  
  always begin
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
      @ (vss.V);
  end
  assign #(250ns) vssGoodFilt = vssGood;

  assign supplyOK = (vddGoodFilt && vssGoodFilt);
  
  assign enInt = (en === 1'b1) ? 1'b1 : 1'b0;

  always @ (enInt or supplyOK) begin 
     if ((enInt == 1'b1) && (supplyOK === 1'b1))
         loadOn = 1'b1;
     else 
         loadOn = 1'b0;
  end

// Calculate supply current
  assign iSupply = (iStandby * supplyOK) + (loadOn * iActive);

endmodule
