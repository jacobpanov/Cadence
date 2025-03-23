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
// Voltage and Current Reference Generator for Transceiver System
//
//--------------------------------------------------------------------------------------


`timescale 1ns/1ps
import cds_rnm_pkg::*;
import EE_pkg::*;

module BIAS2 (VDD, VSS, EN, VTRIM, ITRIM1, ITRIM5, VREF, IBIAS1u, IBIAS5u);
   
   inout EEnet VDD, VSS;          // supplies
   input logic EN;                // enable
   input logic [4:0] VTRIM;       // voltage trim
   input logic [4:0] ITRIM1;      // 1uA current trim
   input logic [4:0] ITRIM5;      // 5uA current trim
   output wreal4state VREF;       // reference voltage
   output EEnet IBIAS1u[5:0];     // 1uA ref currents
   output EEnet IBIAS5u[3:0];     // 5uA ref currents

   parameter real vddMin = 2.5;     // minimum vdd for operation
   parameter real vddMax = 5.1;     // maximum vdd for operation
   parameter real vssMax = 0.1;     // max variation for vss
   parameter real vrefNom = 500e-3; // ideal nominal vref
   parameter real iref1Nom = 1e-6;  // ideal nominal 1uA iref
   parameter real iref5Nom = 5e-6;  // ideal nominal 5uA iref
   parameter real vtrimStep = 15e-3;   // trim step size for vref
   parameter real itrim5Step = 200e-9; // trim step size for 5uA iref
   parameter real itrim1Step = 20e-9;  // trim step size for 1uA iref
   parameter real iStandby = 1e-6;     // standby current 
   parameter real iActive  = 80e-6;    // normal active current
   parameter real startDelay = 2e-6;   // in sec
   parameter real minGlitchWidthNS = 100; // glitch filter width in ns


   integer vtrimInt;    // internal copies of logic controls
   integer itrim1Int;
   integer itrim5Int;
   real vrefVal;        // internal calculated
   real iref1Val;       // values
   real iref1Src [5:0];
   real iref5Val;
   real iref5Src [3:0];
   real iSupply;
   reg vddGood;
   logic vddGoodFilt;
   reg vssGood;
   logic vssGoodFilt;
   logic supplyOK;
   logic clk = 0;
   integer k,l;
   genvar i,j;
   reg refOn;
   real vrefOffset = 0;      // offsets to be set randomly
   real iref1SysOffset = 0;  // at run-time
   real iref5SysOffset = 0;
   real iref1MM [5:0] = '{0, 0, 0, 0, 0, 0};   // individual current output
   real iref5MM [3:0] = '{0, 0, 0, 0};         // mismatches

   initial begin
      refOn = 1'b0;

   end

   //  Current source to model active core (background) current
   Isrc_ideal #(.tr(1e-10)) coreLoad (
       .P          (VDD),
       .N          (VSS), 
       .ival       (iSupply)
  );

// generate 6 1uA bias sources
// Instances of Isrc for the current ref outputs
  for (i=0;i<6;i=i+1) begin
      Isrc #(.dv(0.5), .rp(1e+9)) iBiasSrc1u (VDD, IBIAS1u[i], iref1Src[i]);
  end

// generate 4 5uA bias sources
  for (j=0;j<4;j=j+1) begin
      Isrc #(.dv(0.5), .rp(1e+9)) iBiasSrc5u (VDD, IBIAS5u[j], iref5Src[j]);
   end


   always_comb begin
   // compute value for 6 independent 1uA irefs
   for (k=0;k<6;k=k+1) begin
        iref1Src[k] = refOn * (iref1Val + iref1SysOffset + iref1MM[k]);
   end
   end

   always_comb begin
   // compute value for 4 independent 5uA irefs
   for (l=0;l<4;l=l+1) begin
        iref5Src[l] = refOn *(iref5Val + iref5SysOffset + iref5MM[l]);
   end
   end

// Supply check blocks ...
   always begin
      vddGood = ((VDD.V >= vddMin) && (VDD.V <= vddMax));
      @ (VDD.V);
   end
   assign #(minGlitchWidthNS) vddGoodFilt = vddGood;
  
// needs to execute at least once per simulation
   always begin
      vssGood = (VSS.V <= vssMax) &&  (VSS.V >= -vssMax);
      @ (VSS.V);
   end
   assign #(minGlitchWidthNS) vssGoodFilt = vssGood;

   assign supplyOK = vddGoodFilt && vssGoodFilt; 

// VREF output assignment ...
   assign VREF = vrefVal * refOn;

   always @ (posedge ((EN === 1'b1) && supplyOK)) begin
      #(startDelay*1e9) refOn = (EN && supplyOK);
   end

   always @ (negedge ((EN === 1'b1) && supplyOK))
      refOn = 1'b0;

   // vtrim has inverted sense to insure startup
   // when value is 0
   always @ (VTRIM) begin
      if ((^VTRIM !==1'bz) && (^VTRIM !== 1'bx))
         vtrimInt = (32 - VTRIM);
      else vtrimInt = 0;
   end

   // Treat itrims as signed values
   always @ (ITRIM1) begin
      if ((^ITRIM1 !==1'bz) && (^ITRIM1 !== 1'bx))
         itrim1Int = $signed(ITRIM1);
      else itrim1Int = 0;
   end

   always @ (ITRIM5) begin
      if ((^ITRIM5 !==1'bz) && (^ITRIM5 !== 1'bx))
         itrim5Int = $signed(ITRIM5);
      else itrim5Int = 0;
   end

   // Compute Vref value from trim and step size parameter
   always @ (vtrimInt)
      vrefVal = vrefNom + (vtrimInt * vtrimStep) + vrefOffset;

   // Compute iref values from trim and step size
   always @ (itrim1Int or refOn)
      iref1Val = (refOn == 1'b1) ? (iref1Nom + (itrim1Int * itrim1Step)) : 0;

   always @ (itrim5Int or refOn)
      iref5Val = (refOn == 1'b1) ? (iref5Nom + (itrim5Int * itrim5Step)) : 0;

   assign iSupply = (supplyOK * iStandby) + (refOn * iActive);


endmodule
