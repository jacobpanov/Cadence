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
// Test bench stimulus for PLL schematic simulation
// Sequence for 2 complete lock cycles, second one with modulation
//
//---------------------------------------------------------------

`timescale 1s/1ps
import cds_rnm_pkg::*;
import EE_pkg::*;

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

       #(280e-6) PLL_EN = 1'b0;
       #(290e-6) REFCLK_EN = 1'b0;

       #(300e-6) PWREN = 1'b0;

   join
   $finish;
   
  end

endmodule

