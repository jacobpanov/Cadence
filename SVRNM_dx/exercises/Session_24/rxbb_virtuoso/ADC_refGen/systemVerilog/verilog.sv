//systemVerilog HDL for "SAR_ADC", "ADC_refGen" "systemVerilog"
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
// Voltage reference generator for SAR ADC model
//
//--------------------------------------------------------------------------------------

`timescale 1ns / 1ps
import cds_rnm_pkg::*;
import EE_pkg::*;

module ADC_refGen (vdd, vss, VCM, VREF1, VREF2, trim1, trim2, en );

  parameter real vddMax = 1.8;
  parameter real vddMin = 1.0;
  parameter real vssMax = 0.1;
  parameter real trim1Step = 0.025;
  parameter real trim2Step = 0.015;
  parameter real turnOn = 10e-6;
  parameter real iActive = 200e-6;
  parameter real iStandby = 1e-6;
  parameter real vrefNom = 600e-3;

  inout EEnet vdd;
  inout EEnet vss;

  input logic [3:0] trim1;
  input logic [3:0] trim2;
  input logic en;

  output wreal4state VREF1, VREF2, VCM;

  reg vddGood;
  reg vssGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  reg adcOn = 0;
  real iSupply;
  integer signed trim1_int = 0;
  integer signed trim2_int = 0;
  real vcm_int, vref1_int, vref2_int;

//  Current source to model active core (background) current
   Isrc_ideal_gaussian #(.tr(5e-8)) coreLoad (
       .P          (vdd),
       .N          (vss), 
       .ival       (iSupply)
  );

  always @ (vdd.V)
      vddGood = ((vdd.V >= vddMin) && (vdd.V < vddMax));
  assign #(500) vddGoodFilt = vddGood;
  
  always @ (vss.V)
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
  assign #(500) vssGoodFilt = vssGood;

  assign Active =  vddGoodFilt && vssGoodFilt;

  always @ (en or Active)
     if ((en === 1'b1) && (Active === 1'b1)) adcOn = 1'b1;
     else adcOn = 1'b0;

  always @ (trim1)
     if ((^trim1 !== 1'bz) && (^trim1 !== 1'bx))
        trim1_int = trim1 - 8;
     else
        trim1_int = 0;

  always @ (trim2)
     if ((^trim2 !== 1'bz) && (^trim2 !== 1'bx))
        trim2_int = trim2 - 8;
     else
        trim2_int = 0;

  always @ (posedge adcOn)
     begin
        #(turnOn * 1e9);
        if (adcOn == 1'b1) begin // make sure it is still on before providing refs
           vcm_int = (trim1_int * trim1Step) + (vdd.V - vss.V)/2;
           vref1_int = vcm_int + vrefNom + (trim2_int * trim2Step);
           vref2_int = vcm_int - vrefNom - (trim2_int * trim2Step);
        end
     end

  always @ (negedge adcOn)
     begin
        if (Active == 1'b1)
           begin
              vcm_int = 0;
              vref1_int = 0;
              vref2_int = 0; 
          end
       else
           begin
              vcm_int = `wrealZState;
              vref1_int = `wrealZState;
              vref2_int = `wrealZState; 
          end
     end

  always @ (trim2_int or trim1_int or vdd.V or vss.V)
     begin
        #(5);
        vcm_int = (trim1_int * trim1Step) + (vdd.V - vss.V)/2;
        vref1_int = vcm_int + vrefNom + (trim2_int * trim2Step);
        vref2_int = vcm_int - vrefNom - (trim2_int * trim2Step);
     end

  assign VCM = vcm_int;
  assign VREF1 = vref1_int;
  assign VREF2 = vref2_int;
  assign iSupply = (Active * iStandby) + (adcOn * iActive);

endmodule
