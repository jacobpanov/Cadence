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
// EEnet LDO model
// -- Regulates the ouput to 2 * VIN
// -- Max load 2 mA
// 
//--------------------------------------------------------------------------------------


`timescale 1ns/1ps
import cds_rnm_pkg::*;
import EE_pkg::*;


module LDO ( VDD, VSS, EN, VIN, VOUT );

//Ports
   input        EN;
   input wreal4state  VIN;
   inout EEnet  VDD,VSS;
   inout EEnet  VOUT;


//Parameter Declarations
   parameter real VDD_MAX=5.1;
   parameter real VDD_MIN=2.5;
   parameter real VDO = 100e-3; //max drop-out
   parameter real iMax = 2e-3; // max load
   parameter real iStandby = 1e-9;
   parameter real iActive = 25e-6;
   parameter real rOutInit = 1e3;
   parameter real rOutOff  = 1e9;
   parameter real activePeriod = 0.5; // Reduced from 10ns
   parameter real KsMid = 1000;
   parameter real KsNom = 300;
   parameter real startDelay = 1e-6;
   parameter real vTol = 1e-3;


//Internal Signals
   real VSS_MIN;
   real VSS_MAX;
   real VIN_MIN;
   real VIN_MAX;
   real VOUT_int;
   real R1=2.0;
   real R2=2.0;
   reg ldoOn = 0;
   reg ldoOnTemp;
   real rOutInst;   // instantaneous calculated value of rOut
   real iOutInt;   //internal measurement of output drive current
   real VDDnow;
   real VSSnow;
   real rOutMin;
   real iSupply;
   logic clk = 0;
   real samplePeriod;
   real iLeak;
   real rLeak;   // Internal load on output (feedback network, etc)
   wire Supply;
   real Ks;
   real vOffset = 0.0; //input offset

//  ADD events
   event startClk, stopClk;

   initial begin
     VSS_MIN=-100e-3;
     VSS_MAX=100e-3;
     VIN_MIN=0.0;
     VIN_MAX=5.0;
     rOutInst = rOutOff; // default start-up condition is OFF
     rOutMin = VDO / iMax;
     samplePeriod = activePeriod;
     rLeak = 10; // pull-down on output in OFF state
     Ks = KsNom;
   end


   always @(VDD.V) begin
      VDDnow = VDD.V;
   end

   always @(VSS.V) begin
      VSSnow = VSS.V;
   end
 

//  Variable resistor to model output pass device
   VRsrcD #(.tr(0), .vtol(1e-6), .itol(1e-7)) outputR (
       .P          (VDD), 
       .N          (VOUT),
       .vval       (),
       .rval       (rOutInst),
       .imeas      (iOutInt)
   );

// Variable pull-down resistor to stabilize and shut down output.
// Must be variable for OFF condition
   VRsrcD #(.tr(0), .vtol(1e-4), .rz(1e9), .itol(1e-8)) leakage ( 
       .P          (VOUT),
       .N          (VSS), 
       .vval       (),
       .rval       (rLeak),
       .imeas      (iLeak)
  );

//  Current source to model active core (background) current
   Isrc_ideal #(.tr(0)) coreLoad (
       .P          (VDD),
       .N          (VSS), 
       .ival       (iSupply)
  );


// Output capacitor smoothes out bumps on abrupt load changes
  CapGeq  #(.c(100e-12), .tinc(1e-9), .rs(250)) outputCap (
       .P          (VOUT)
  );


//SV_Wreal Model
  always @ (EN or Supply) 
     begin
        if ((EN === 1'b1) && (Supply == 1'b1)) begin
            ldoOnTemp = 1'b1;
            -> startClk;
        end
        else begin
            ldoOnTemp = 1'b0;
            -> stopClk;
        end
     end

   always @ (ldoOnTemp) begin
      if (ldoOnTemp === 1'b1)
         #(startDelay*1s) ldoOn = (ldoOnTemp === 1'b1) ? 1'b1 : 1'b0;
      else begin
         ldoOn = 1'b0;
         -> stopClk;
      end
   end

   always @ (ldoOn)
     if (ldoOn == 1'b1)
        rOutInst = rOutInit;
     else
        rOutInst = rOutOff;

   assign #6 Supply = ((VDDnow >= VDD_MIN) && (VDDnow <= VDD_MAX) && (VSSnow <= VSS_MAX) && (VSSnow >= VSS_MIN)); 
   assign    iSupply = (Supply * iStandby) + (ldoOn * iActive) ;

   always @ (EN or ldoOn) begin
     if ((EN === 1'b1) && (ldoOn == 1'b1)) begin
        rOutMin=VDO/iMax;
        Ks=KsMid;  // Increase the gain for faster startup
        rLeak=10000;
        rOutInst=10000;  // pre-set the output R for faster convergence
        #(3600)Ks=KsNom; 
    end
    else   //Off
       rLeak=0;
   end

/* // Replace always-on clock with switched block below
   always
      #(samplePeriod / 2)  clk <= ~clk;      
*/

   always
   fork
   begin : clkGen
      clk = 1'b0;
      @startClk forever
          #(samplePeriod / 2)  clk <= ~clk;      
   end
   @stopClk disable clkGen;
   join

//  Compare actual VOUT with target voltage
//  and enable or disable clock accordingly
   always @ (VOUT_int or VOUT.V) begin
       if ((myAbs(VOUT.V - VOUT_int) > vTol) && (ldoOn == 1'b1))
            -> startClk;     
       else
            -> stopClk;
   end


   always @ ( posedge clk or ldoOn or VIN or R1 or R2)
      begin
         VOUT_int = (VIN + vOffset)*((R1+R2)/(R2)); 
           // feedback to drive VOUT closer to target
         rOutInst = (ldoOn == 1'b1) ? (((Ks * (VOUT.V - VOUT_int) + rOutInst) > rOutMin) ?  // If the calculated new rOut is > the min,
                 (Ks * (VOUT.V - VOUT_int) + rOutInst) : rOutMin) : rOutOff  ;   // then set the new rOut, otherwise set Min or OFF
      end

function real myAbs (real inVal);
   return (inVal >= 0.0) ? inVal : -inVal;
endfunction

endmodule

