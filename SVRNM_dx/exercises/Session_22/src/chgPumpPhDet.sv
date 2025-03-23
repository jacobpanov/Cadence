//systemVerilog HDL for "PLL", "chgPumpPhDet" "systemVerilog"
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
// Charge Pump based tri-state phase detector model
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1fs
import cds_rnm_pkg::*;
import EE_pkg::*;

module chgPumpPhDet ( out, vdd, vss, refinm, refinp, resetb, vcoinm, vcoinp );

  input logic refinp;
  input logic refinm;
  input logic vcoinp;
  input logic vcoinm;
  input logic resetb;
  output EEnet out;
  inout EEnet vdd;
  inout EEnet vss;

  parameter real vddMin = 1.4;
  parameter real vddMax = 1.8;
  parameter real vssMax = 0.1;
  parameter real iActive = 200e-6;
  parameter real iStandby = 1e-6;
  parameter real iPump = 50e-6;
  parameter real uDelay = 1e-12;

  logic refInDiff;
  logic vcoInDiff;
  reg enInt = 0;
  reg pdOn;  
  reg vddGood;
  reg vssGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  real iSupply;
  logic supplyOK;
  real iOffset = 0.0; // up/down mismatch
  real iError = 0.0;  // deviation from nominal, applies equally to up and down
  logic up, dn, ffReset;
  reg  upReg, dnReg, ffResetReg;
  real iPumpUp, iPumpDn;
  real vOut, vVdd, vVss;

  EEnet intNode;  // Internal node to dump current to
  EEnet intVSS;   // Internal low-impedance ground

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
          upReg = 1'b0;
          dnReg = 1'b0;
      end

   always @ ((negedge enInt) or vddGoodFilt or vssGoodFilt)
      begin
          if ((vddGoodFilt !== 1'b1) || (vssGoodFilt !== 1'b1)) begin
             upReg = 1'bx;
             dnReg = 1'bx;
             pdOn = 1'b0;
          end
          else if (enInt != 1'b1) begin
             upReg = 1'b0;
             dnReg = 1'b0;
             pdOn = 1'b0;
          end
      end

   always @ ((posedge refInDiff) or (posedge ffReset)) begin 
      upReg = (ffReset == 1'b1) ? 1'b0 : 1'b1;
   end

   always @ ((posedge vcoInDiff) or (posedge ffReset)) begin
      dnReg = (ffReset == 1'b1) ? 1'b0 : 1'b1;
   end

  assign iSupply = (iStandby * supplyOK) + (pdOn * iActive);
  assign refInDiff = refinp | !refinm;
  assign vcoInDiff = vcoinp | !vcoinm;
  assign #(uDelay) up = upReg & enInt;
  assign #(uDelay) dn = dnReg & enInt;
  assign #(uDelay) ffReset = up & dn;
  assign vOut = out.V;
  assign vVdd = vdd.V;
  assign vVss = vss.V;

  //Pump Up with hyperbolic rolloff near vdd and shutoff above that:
  assign iPumpUp = (up === 1'b1) ? ((vOut < vVdd) ? (iPump + iOffset + iError) * ($tanh((vVdd - vOut)/0.25)) : 0.0) : 0.0;

  //Pump Down with hyperbolic rolloff near vss and shutoff below that:
  assign iPumpDn = (dn === 1'b1) ? ((vOut > vVss) ? (iPump + iOffset + iError) * ($tanh((vOut - vVss)/0.25)) : 0.0) : 0.0;

  assign intNode = '{out.V, 0, 0};
  assign intVSS  = '{vss.V, 0, 0}; //low impedance node

  // Pump the output port
  assign out = '{`wrealZState, (iPumpUp - iPumpDn), 0};

  //  Current source to model active core (background) current
   Isrc_ideal_gaussian #(.tr(1e-6)) coreLoad (
       .P          (vdd),
       .N          (vss), 
       .ival       (iSupply)
  );



endmodule
