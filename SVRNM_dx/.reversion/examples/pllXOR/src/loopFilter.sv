//systemVerilog HDL for "PLL", "loopFilter" "systemVerilog"
//--------------------------------------------------------------------------------------
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
//  Loop Filter model for PLL 
//  Has 2 real-valued trimmable poles
//  Prorates the input based on time since last change
//  Use with xor Phase Detector model
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1fs
import cds_rnm_pkg::*;
import EE_pkg::*;

`ifndef M_TWO_PI
`define M_TWO_PI 6.28318530717958647652
`endif

module loopFilter ( out, vdd, vss, en, in, lock, preChg, trim );

  parameter real vddMin = 1.0;
  parameter real vddMax = 1.8;
  parameter real vssMax = 0.1;
  parameter real iActive = 50e-6;
  parameter real iStandby = 1e-6;
  parameter real prechargeTime = 10e-6;
  parameter real sampleRate = 100e6;
  parameter real scaleFactor = 1e5;
  parameter real fpole0 = 150e3;
  parameter real fpole1 = 500e3;
  parameter real trimStep = 50e3;


  input in;
  output wreal4state out;
  input en;
  inout EEnet vdd;
  inout EEnet vss;
  output logic lock;
  input logic preChg;
  input logic [3:0] trim;

  reg enInt = 0;
  reg filtOn;
  reg warmOn;
  reg preOn;  
  reg vddGood;
  reg vssGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  real iSupply;

  real lastPosedge;
  real lastNegedge;
  real sampIn;
  real outInt;
  real outCharge;
  real outSample;
  real data [0:2];  // input pipeline for filter
  real y_data [0:2]; // output pipeline for filter
  real period;
  real w0, w1;  //pole frequencies in radians
  real normConst;
  real numConst;
  real num_0;
  real denom_0;
  logic supplyOK;
  logic clk;
  real fPoleError = 0.0; // pole 0 make error in %
  event startFiltClk, stopFiltClk;

//  Current source to model active core (background) current
   Isrc_ideal_gaussian #(.tr(1e-6)) coreLoad (
       .P          (vdd),
       .N          (vss), 
       .ival       (iSupply)
  );

  always @ (vdd.V)
      vddGood = ((vdd.V >= vddMin) && (vdd.V < vddMax));
  assign #(300e-9) vddGoodFilt = vddGood;
  
  always @ (vss.V)
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
  assign #(300e-9) vssGoodFilt = vssGood;

  assign supplyOK = vddGoodFilt && vssGoodFilt;

   always @ (en)
      if (en === 1'b1)  enInt = 1;
      else enInt = 1'b0;

   always @ (posedge (enInt && (supplyOK === 1'b1)))
      begin
          clk = 0;
          outCharge = vdd.V/2;
          outInt = vdd.V/2;
          sampIn = vdd.V/2;
           -> startFiltClk;   //Turn the filter clk on
          //w0 = fpole0 * `M_TWO_PI ;
          //w1 = fpole1 * `M_TWO_PI ;
          //normConst = 1/( (w0*(period**2)+(2*period))* w1 + (2*period*w0) + 4 ); // could use $pow(a,b);
          //numConst = w0*w1*(period**2);
          data[0:2] = '{vdd.V/2, vdd.V/2, vdd.V/2};
          y_data[0:2] = '{vdd.V/2, vdd.V/2, vdd.V/2};
          warmOn = 1'b1;
      end

   always @ ( (enInt && (supplyOK === 1'b1)) or trim) begin
      if ( enInt && (supplyOK === 1'b1) && (^trim !== 1'bx) && (^trim !== 1'bz)) begin
          w0 = (fpole0 + ($signed(trim-7) * trimStep / 4) * (1 + fPoleError)) * `M_TWO_PI ;
          w1 = (fpole1 + ($signed(trim-7) * trimStep) * (1 + fPoleError)) * `M_TWO_PI ;
          normConst = 1/( (w0*(period**2)+(2*period))* w1 + (2*period*w0) + 4 ); // could use $pow(a,b);
          numConst = w0*w1*(period**2);
      end
   end


   always @ ((negedge enInt) or supplyOK)
      begin
          if (supplyOK !== 1'b1) begin
             outInt = `wrealZState;
             filtOn = 1'b0;
             preOn  = 1'b0;
             warmOn = 1'b0;
             lock = 1'bx;
             -> stopFiltClk;
          end
          else if (enInt == 1'b0) begin
             outInt = 0.0;
             filtOn = 1'b0;
             preOn  = 1'b0;
             warmOn = 1'b0;
             lock = 1'b0;
             -> stopFiltClk;
          end
      end

  always @ (posedge warmOn) begin
          #(200e-9);
          if ((enInt == 1'b1) && (supplyOK === 1'b1)) filtOn = 1'b1;
  end

  always @ (preChg) begin
     if (preChg === 1'b1) begin
          outCharge = vdd.V/2;
          preOn = 1'b1;
          outInt = vdd.V/2;
          sampIn = vdd.V/2;
      end
      else if (preChg === 1'b0) begin
          outInt = outCharge;
          outCharge = 0;
          preOn = 1'b0;
          lastPosedge = $realtime;
          lastNegedge = $realtime;
          sampIn = outInt;
      end
  end
   
  // This block generates the filter clock. It is activated and deactivated
  // via the two events startFiltClk and stopFiltClk.
  always
  fork
  begin : filtClkGen
     clk = 1'b0; // Starts at 0
     @startFiltClk forever
        #(period) clk = ~clk;
  end
  @stopFiltClk disable filtClkGen;
  join

  always @ (posedge in)
     begin
         lastPosedge = $realtime;
         outSample = out;
         if ( (outSample < (vdd.V*0.75)) && (outSample > (vdd.V*0.25)) && (preOn == 1'b0) ) lock = 1'b1;
         else lock = 1'b0;
     end

  always @ (negedge in)
     begin
         lastNegedge = $realtime;
     end

  always @ (posedge clk)
     begin
        if ( (($realtime - lastPosedge) < period) || (($realtime - lastNegedge) < period) )  // if and edge of in happened since the last sample,
           begin
             if (in === 1'b1)
                sampIn = ( (vdd.V * ($realtime - lastPosedge)) + (vss.V * (lastPosedge - ($realtime - period))) ) / period ;
             else
                sampIn = ( (vss.V * ($realtime - lastNegedge)) + (vdd.V * (lastNegedge - ($realtime - period))) ) / period ;
           end
           else  //if no edge occurred since last sample,
             sampIn = in * vdd.V; // just sample the input scaled by vdd

        data[2] = (data[1] !== 1'bz) ? data[1] : 0.0 ;
        data[1] = (data[0] !== 1'bz) ? data[0] : 0.0 ;
        // Keep X/Z states out of data pipeline...
        data[0] = ((outCharge !== `wrealZState) && (outCharge !== `wrealXState) && (outCharge > 0)) ? outCharge : (sampIn === `wrealZState) ? 0 : sampIn;

        y_data[2] = (y_data[1] !== 1'bz) ? y_data[1] : 0.0;
        y_data[1] = (y_data[0] !== 1'bz) ? y_data[0] : 0.0;
        num_0 = numConst*data[0]*normConst + (2*numConst*data[1]*normConst) + (numConst*data[2]*normConst);
        denom_0 = (((2*(period**2))*w0*w1 - 8) * normConst * y_data[1]) + ( (((period**2)*w0 - (2*period))*w1 - (2*period*w0) + 4) * normConst * y_data[2] );
        y_data[0] = num_0 - denom_0;
        
        outInt = enInt * (((y_data[0] !== 1'bx) && (y_data[0] !== 1'bz)) ? y_data[0] : outInt);
     end


  assign out = (outCharge * preOn) +  (1-preOn) * ((outInt > vdd.V) ? vdd.V : (outInt < vss.V) ? vss.V : (outInt));
  assign iSupply = (iStandby * supplyOK) + (filtOn * iActive);
  initial
     begin
       period = 1/(2*sampleRate);
       sampIn = 0;
       lock = 1'b0;
     end
endmodule
