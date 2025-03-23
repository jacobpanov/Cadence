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
// Stimulus for rxBB Test Bench
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1ps
import cds_rnm_pkg::*;
import EE_pkg::*;

`ifndef M_TWO_PI
`define M_TWO_PI 6.28318530717958647652
`endif

module rxBB_stimulus (
   input  logic [7:0] outi ,
   input  logic [7:0] outq ,
   input  logic outClki,
   input  logic outClkq,

   output  EEnet vdd,
   output  EEnet vss,
   output logic en,
   output logic refEn,
   output logic [3:0] gain, 
   output logic [3:0] bwTrim, 
   output logic [3:0] refTrim1, 
   output logic [3:0] refTrim2,
   output wreal4state inip, 
   output wreal4state inim, 
   output wreal4state inqp, 
   output wreal4state inqm,
   output wreal4state vref,
   output logic [7:0] dcoci,
   output logic [7:0] dcocq,
   output logic sampleClkp,
   output logic sampleClkn,
   output logic fastClkp,
   output logic fastClkn
   );

  parameter real fNom = 500e3;
  parameter real vCM = 0.75;
  parameter real vrefVal = 0.720;
  parameter real sampleFreq = 16e6;
  parameter integer fastRatio = 10;
  parameter real vSup = 1.5;
  parameter real lsbSize = 0.0064;

  real iDiff;
  real qDiff;
  real iAmpl;
  real qAmpl;
  real iFreq;
  real qFreq;
  real vGnd;

  real Iout_int, Qout_int;
  logic clk = 1'b0;
  logic fastClk = 1'b0;
  logic sampleClk = 1'b0;
  logic clkEn;
  integer clkCount = 0;
  integer i;

  assign inip = vCM + iDiff/2;
  assign inim = vCM - iDiff/2;
  assign inqp = vCM + qDiff/2;
  assign inqm = vCM - qDiff/2;

  assign dcoci = 8'h00;
  assign dcocq = 8'h00;
  assign vref = vrefVal;
  assign vdd = '{vSup,`wrealZState, 0};
  assign vss = '{vGnd, `wrealZState, 0};

  assign sampleClkp = sampleClk;
  assign sampleClkn = !sampleClk;
  assign fastClkp = fastClk;
  assign fastClkn = !fastClk;

  always #(20e-9) clk = ~clk;

  always @ (posedge clk) begin
     iDiff = iAmpl * $sin(`M_TWO_PI * iFreq * $realtime);
     qDiff = qAmpl * $cos(`M_TWO_PI * qFreq * $realtime);
  end

  always @ (posedge outClki) begin
     Iout_int = $signed(outi - 127) * lsbSize;
  end

  always @ (posedge outClkq) begin
     Qout_int = $signed(outq -127) * lsbSize;
  end

  always # (1/(2*sampleFreq*fastRatio)) begin
    fastClk = (~fastClk) && clkEn;
  end

  always @ (posedge fastClk) begin
     clkCount = clkCount + 1;
     if (clkCount == $floor(fastRatio/2)) begin
        sampleClk = (~sampleClk) && clkEn;
        clkCount = 0;
     end
  end

  initial begin
     vGnd  = 0.001;
     iAmpl = 0;
     qAmpl = 0;
     iFreq = fNom;
     qFreq = fNom;
     gain = 4'b1111;
     bwTrim = 4'b1000;
     refTrim1 = 4'b1000;
     refTrim2 = 4'b0100;
     en = 1'b0;
     refEn = 1'b0;
     clkEn = 1'b0;
  fork
     #(1e-6)  refEn = 1'b1;
     #(20e-6) clkEn = 1'b1;
     #(30e-6) en = 1'b1;
     #(60e-6) iAmpl = 0.1;
     #(60e-6) qAmpl = 0.1;

     #(60e-6) begin
        for (i=15; i>=0; i=i-1) begin
           gain = i;
           #(5e-6);
        end
        gain = 4'b1000;
     end
     #(150e-6) begin
        for (i=15; i>=0; i=i-1) begin
           bwTrim = i;
           #(20e-6);
        end
        bwTrim = 4'b1000;
    end
    #(500e-6) begin
        for (i=15; i>=0; i=i-1) begin
           refTrim1 = i;
           #(10e-6);
        end
        refTrim1 = 4'b1000;
    end
    #(700e-6) begin
        for (i=0; i<16; i=i+1) begin
           refTrim2 = i;
           #(10e-6);
        end
       refTrim2 = 4'b1000;
    end
    #(1350e-6) begin
       iAmpl = 0;
       qAmpl = 0;
       #(10e-6) en = 1'b0;
       refEn = 1'b0;
       clkEn = 1'b0;
    end
  join
  #(150e-6) $stop;
  end  // initial

endmodule
