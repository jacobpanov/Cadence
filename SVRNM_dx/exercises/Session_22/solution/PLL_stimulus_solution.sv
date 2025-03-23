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
// Test bench stimulus for PLL schematic simulation
// Sequence for 2 complete lock cycles, second one with modulation
//
//--------------------------------------------------------------------------------------

`timescale 1s/1ps
import cds_rnm_pkg::*;
import EE_pkg::*;
// import the package containing the filter randomization class
import modelError::*;

module PLL_stimulus
             (output logic PLL_EN,
              output logic [6:0] vcoTune, 
              output logic REFCLK_EN,
              output logic RESETN,
              input  logic PLLLOCK,
              output logic LFPREEN,
              output logic [5:0] MOD,
              output logic [3:0] LFTRIM,
              output logic [4:0] DIV,
              output logic PWREN  );


  // create an object of the filter randomization class
  c_modelOffset modelOffset = new;
  logic randOK;
  integer i,j;
  reg init = 1'b0;

  assign VREFIN = 0.72;
  assign LFPREEN = init;

  initial begin
     REFCLK_EN = 1'b0;

     PLL_EN = 1'b0;
     PWREN = 1'b0;
     DIV = 5'h10;
     vcoTune = 7'h4E;
     RESETN = 1'b1;
     MOD  = 5'b00000;

     // Procedurally randomize the filter offset and VCO offset 
     //   and assign it to the elements
     randOK = modelOffset.randomize();
     tb.u_PLLtop.ILF.fPoleError = modelOffset.filterOffset;
     $display("Set filterOffset = %f (ratio)", modelOffset.filterOffset);
     tb.u_PLLtop.IVCO.fNomOffset = modelOffset.vcoOffset;
     $display("Set vcoOffset = %f (Hz)", modelOffset.vcoOffset);

    fork
       #(1e-6) PWREN = 1'b1;
       #(8e-6) RESETN = 1'b0;
       #(9e-6) RESETN = 1'b1;
       #(25e-6) REFCLK_EN = 1'b1;
       #(35e-6) PLL_EN = 1'b1;
       #(35e-6) LFTRIM = 4'b1000;
       #(35e-6) DIV = 5'h18;
       #(40e-6) init = 1'b1;
       #(44e-6) init = 1'b0;

   // Assert the expected current load on the source
       #(120e-6) begin assert ((-tb.u_tbPwrRamp.iLoad < 1.8e-3) && (-tb.u_tbPwrRamp.iLoad > 1.3e-3))
           $display("Current Drain %f at time %f OK", -tb.u_tbPwrRamp.iLoad, $realtime);
           else $display("Current Drain %f out of spec at time %f", -tb.u_tbPwrRamp.iLoad, $realtime);
       end
       #(280e-6) PLL_EN = 1'b0;
       #(290e-6) REFCLK_EN = 1'b0;

       #(300e-6) PWREN = 1'b0;

   join

   $finish;
   
  end

  // Concurrent assertion to monitor PLLLOCK
  sequence holdLock;
    // PLLLOCK should be 1 continuously until PLL_EN falls
     $past(PLLLOCK == 1'b1) [*] ##0 $fell(PLL_EN == 1'b1);
    // Requires $past here since PLLLOCK and PLL_EN both end 
    // on the same clock cycle.
  endsequence

  property pllLocked;
   // Clock on differential refClk. PLL_EN triggers the assertion
     @ (posedge tb.u_PLLtop.refclkp & ~tb.u_PLLtop.refclkm) $rose(PLL_EN) |->  ##[0:1000] $rose(PLLLOCK == 1'b1) ##1 holdLock;
   // Look for a 1 on PLLLOCK within 1000 clocks (62.5 us)
  endproperty 

  PllLockCheck: assert property (pllLocked)
     $display("PLL Lock Check Passed at time %f", $realtime);
     else
     $display("PLL Lock Check Failed at time %f", $realtime);

endmodule

