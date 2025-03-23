//systemVerilog HDL for "TIA_example", "TIA" "systemVerilog"
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
// Variable Gain TransImpedance Amplifier
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1ps

module TIA import cds_rnm_pkg::*; import EE_pkg::*; ( 

  inout EEnet vdd,
  inout EEnet vss,
  input wreal1driver vbias1,
  input wreal1driver vbias2,
  input EEnet in,
  output EEnet out,
  input logic [3:0] gain,
  input logic en

 );

 parameter real vddMin = 1.0;   // Volts
 parameter real vddMax = 1.8;   // Volts  
 parameter real vssMax = 0.1;    // Volts
 parameter real onCurrent = 600e-6;  //Amps
 parameter real stdbyCurrent = 1e-6; //Amps
 parameter real AzNom = 50;      // Volts/Amp
 parameter real rOutNom = 1000;  // Ohms
 parameter real rOutOff = 1;     // Ohms
 parameter real rOutHi  = 1e6;   // Ohms
 parameter real ZinOn = 2000;    // Ohms
 parameter real ZinOff = 1;      // Ohms
 parameter real vbias1Nom = 0.25; // % of vdd
 parameter real vbias2Nom = 0.75; // % of vdd
 parameter real vbiasTol = 0.05;  // % of Nom

  reg vddGood;
  reg vssGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  reg vbias1Good;
  reg vbias2Good;
  logic vbiasFilt;
  wire enInt;
  reg tiaOn;
  real vout;
  real rOut;
  real iSupply;
  real Az_calc;
  real i_in;
  real v_in;
  real Zin;

  always begin
      vddGood = ((vdd.V >= vddMin) && (vdd.V < vddMax));
      @ (vdd.V);
  end
  assign #(250e-9) vddGoodFilt = vddGood;
  
  always begin
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
      @ (vss.V);
  end

  assign #(250e-9) vssGoodFilt = vssGood;

  always @ (vbias1 or vdd.V)
      vbias1Good = ( (vbias1 > (vbias1Nom*vdd.V*(1-vbiasTol))) && 
                   (vbias1 < (vbias1Nom*vdd.V*(1+vbiasTol))) );

  always @ (vbias2 or vdd.V)
      vbias2Good = ( (vbias2 > (vbias2Nom*vdd.V*(1-vbiasTol))) && 
                   (vbias2 < (vbias2Nom*vdd.V*(1+vbiasTol))) );
  
  assign #(250e-9) vbiasFilt = ((vbias1Good && vbias2Good)) ? 1'b1 : 1'b0;

  assign #(250e-9) enInt = (en === 1'b1);

  always @ (enInt or vddGoodFilt or vssGoodFilt or vbiasFilt) begin
      if ( (enInt == 1'b1) && (vddGoodFilt === 1'b1) 
           && (vssGoodFilt === 1'b1) && (vbiasFilt === 1'b1) ) begin
          tiaOn = 1;
          Zin = ZinOn;
      end
      else begin
         if ((vddGoodFilt !== 1'b1) || (vssGoodFilt !== 1'b1)) begin
             vout = `wrealZState;
             rOut = rOutHi;
             tiaOn = 0;
             Zin = `wrealZState;
         end
         else if ((enInt == 1'b0) || (vbiasFilt == 1'b0)) begin
             vout = 0.0;
             rOut = rOutOff;
             tiaOn = 0;
             Zin = ZinOff;
         end
     end
  end

  assign iSupply = ((tiaOn == 1'b1) ? onCurrent : 0.0) + 
     ( ((vddGoodFilt !== 1'b1) || (vssGoodFilt !== 1'b1)) ? 0.0 : stdbyCurrent );
  assign out = '{vout,0,rOut};
  assign in  = '{0, 0, Zin};
  assign vdd = '{`wrealZState,-iSupply, 0};
  assign vss = '{`wrealZState,+iSupply, 0};

  always @ (gain or tiaOn) begin
    if ( !($isunknown(gain)) && (gain != 0) && (tiaOn == 1'b1) ) begin              
           Az_calc = AzNom / $countones(gain);
           rOut = rOutNom / $countones(gain);
        end
        else begin
           if (tiaOn == 1'b0) begin
              Az_calc = `wrealZState;
              rOut    = rOutOff;
           end
           else begin           // means gain = 0 or undefined
              Az_calc = 1.0; 
              rOut = rOutHi;
           end         
        end
  end

  always @ (in.V or in.R or tiaOn) begin
     if (tiaOn == 1'b1) begin
        i_in = in.V/in.R;
        vout = Az_calc * i_in;
     end
  end


 


endmodule

