//systemVerilog HDL for "RX", "dualBBA" "systemVerilog"
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
// I and Q channel baseband amplifiers with 1 pole filter
//   16 gain states
//   16 filter trim settings
//   input for DC Offset Correction
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1ps

`ifndef M_TWO_PI
`define M_TWO_PI 6.28318530717958647652
`endif

module dualBBA import cds_rnm_pkg::*; import EE_pkg::*; ( 
   inim, inip, inqm, inqp, vdd, vss, en, outim, outip, 
   outqm, outqp, bwTrim, gain, dcocip, dcocim, dcocqp, dcocqm );

  output wreal4state outqp;
  output wreal4state outqm;
  output wreal4state outip;
  input wreal4state inqp;
  input wreal4state inqm;
  input wreal4state inim;
  input wreal4state inip;
  output wreal4state outim;
  input en;
  inout EEnet vdd;
  inout EEnet vss;
  input [3:0] bwTrim;
  input [3:0] gain;
  input wreal4state dcocip, dcocim, dcocqp, dcocqm;
  

  parameter real fPole = 2.5e6;
  parameter real fStep = 25e3;
  parameter real AvdB = 6;
  parameter real fSample = 5e7;
  parameter real vddMin = 1.0;
  parameter real vddMax = 1.8;
  parameter real vssMax = 0.1;
  parameter real iActive = 800e-6;
  parameter real iStandby = 1e-6;
  parameter real stdbyPer = 10e-6;
  parameter real gainStepdB = 3;

  real  dataXi [0:1];
  real  dataYi [0:1];
  real  dataXq [0:1];
  real  dataYq [0:1];
  real w0;
  wire enInt;
  reg pmaOn;
  reg vddGood;
  reg vssGood;
  real iInDiff;
  real qInDiff;
  real iOutDiff;
  real qOutDiff;
  logic vddGoodFilt;
  logic vssGoodFilt;
  wreal4state iSupply;
  reg sampleClk=0;
  real samplePeriod;
  real AvNum;
  wreal4state vCM;
  real AvdB_calc;
  real fPoleOffset = 0.0;

//  Current source to model active core (background) current
   Isrc_ideal_gaussian #(.tr(1e-6)) coreLoad (
       .P          (vdd),
       .N          (vss), 
       .ival       (iSupply)
  );

  initial begin
     samplePeriod = stdbyPer;
     w0 = `M_TWO_PI * (fPole + fPoleOffset);
     dataXi[1] = 0;
     dataXi[0] = 0;
     dataYi[1] = 0;
     dataYi[0] = 0;
     dataXq[1] = 0;
     dataXq[0] = 0;
     dataYq[1] = 0;
     dataYq[0] = 0;
     AvNum = 10**(AvdB/20);
  end

  always @ (vdd.V)
      vddGood = ((vdd.V >= vddMin) && (vdd.V < vddMax));
  assign #(250e-9) vddGoodFilt = vddGood;
  
  always @ (vss.V)
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
  assign #(250e-9) vssGoodFilt = vssGood;

   assign enInt = (en === 1'b1);

   always @ (enInt or vddGoodFilt or vssGoodFilt) begin
      if ( (enInt == 1'b1) && (vddGoodFilt === 1'b1) && (vssGoodFilt === 1'b1) )
          pmaOn = 1;
      else begin
         if ((vddGoodFilt !== 1'b1) || (vssGoodFilt !== 1'b1)) begin
             qOutDiff = `wrealZState;
             iOutDiff = `wrealZState;
             pmaOn = 0;
         end
         else if (enInt == 1'b0) begin
             qOutDiff = 0;
             iOutDiff = 0;
             pmaOn = 0;
         end
     end
  end

  always @ (bwTrim or enInt)
     begin
        if ( !($isunknown(bwTrim)) && (enInt == 1'b1) )
           w0 = `M_TWO_PI * (fPole + ( $signed(bwTrim - 7)*fStep ) + fPoleOffset);
        else
           w0 = `M_TWO_PI * (fPole + fPoleOffset);
     end

  always @ (gain or enInt)
     begin
        if ( !($isunknown(gain)) && (enInt == 1'b1) ) begin
           AvdB_calc = AvdB + ( $signed(gain - 7) * gainStepdB );
           AvNum = 10 ** ( AvdB_calc / 20 );
        end
        else AvNum = 10**(AvdB/20);
           
     end

  always @ (pmaOn)
     if (pmaOn == 1'b1)
        samplePeriod = 1/fSample;
     else
        samplePeriod = stdbyPer;

  always #(samplePeriod/2)
     sampleClk = ~sampleClk;

  always @ (posedge (sampleClk && enInt))
     begin
        dataXi[1] = dataXi[0];
        dataXi[0] = ((iInDiff !== `wrealZState) && (iInDiff !== `wrealXState)) ? iInDiff : 0 ; 
        dataYi[1] = dataYi[0];
        dataYi[0] = (dataXi[0] + dataXi[1] -dataYi[1]*(1-(2/(samplePeriod*w0)))) / (1+(2/(samplePeriod*w0))); 

        dataXq[1] = dataXq[0];
        dataXq[0] = ((qInDiff !== `wrealZState) && (qInDiff !== `wrealXState)) ? qInDiff : 0 ; 
        dataYq[1] = dataYq[0];
        dataYq[0] = (dataXq[0] + dataXq[1] -dataYq[1]*(1-(2/(samplePeriod*w0)))) / (1+(2/(samplePeriod*w0))); 

        iOutDiff = (pmaOn == 1'b1) ? ((vdd.V-vss.V) * $tanh( dataYi[0] * AvNum / (vdd.V-vss.V)) ) : ((vddGoodFilt & vssGoodFilt) ? 0 : `wrealZState) ;
        qOutDiff = (pmaOn == 1'b1) ? ((vdd.V-vss.V) * $tanh( dataYq[0] * AvNum / (vdd.V-vss.V)) ) : ((vddGoodFilt & vssGoodFilt) ? 0 : `wrealZState) ;
     end

    assign iInDiff = pmaOn * ((inip - inim) + (dcocip - dcocim)) ;
    assign qInDiff = pmaOn * ((inqp - inqm) + (dcocqp - dcocqm)) ;

    assign vCM = (vdd.V-vss.V)/2;
    assign outip = vCM + (iOutDiff/2);
    assign outim = vCM - (iOutDiff/2);
    assign outqp = vCM + (qOutDiff/2);
    assign outqm = vCM - (qOutDiff/2);


    assign iSupply = (iStandby * (vddGoodFilt & vssGoodFilt)) + (pmaOn * iActive);


endmodule
