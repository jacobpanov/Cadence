// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2020, Cadence Design Systems, Inc. All rights reserved.

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
// Test bench for tx bias demonstration
//
//---------------------------------------------------------------

`timescale 1s / 1ps

module tb ();

import cds_rnm_pkg::*; 
import EE_pkg::*;

real vddVal, iRefVal;
logic [3:0] trim;
logic en = 1'b0;
EEnet vdd, vss, inBias;
wreal4state pbias [1:0];

txBias u_txBias (
    .vdd    (vdd),
    .vss    (vss),
    .en     (en),
    .pbias  (pbias),
    .trim   (trim),
    .inBias (inBias) );

div2Tx u_div2Tx (
  .txip     (txip),
  .txim     (txim),
  .vcop     (vcop),
  .vcom     (vcom),
  .en       (en),
  .vdd      (vdd),
  .vss      (vss),
  .ibias    (pbias[0]) );

txPreAmp u_txPreAmp (
  .inp      (txip),
  .inm      (txim),
  .vdd      (vdd),
  .vss      (vss),
  .ibias    (pbias[1]),
  .outp     (),
  .outn     (),
  .gain     (4'b1000),
  .tune     (4'b1000),
  .en       (en) );

vcoSource u_vcoSource (
  .vcom    (vcom),
  .vcop    (vcop)  );
 
assign vdd = '{vddVal, 0, 0};
assign vss = '{0, 0, 0};
assign inBias = '{`wrealZState, iRefVal, 0};

initial begin
  #1us vddVal = 1.5;
  #1us trim = 4'b1000;
  #1us en = 1'b1;
  #5us iRefVal = 5e-6;
  #100us begin
     for (int i = 0; i<15; i++)
        #10us trim = i;
  end
  #100us en = 1'b0;
  #5us   iRefVal = 0.0;
  #1us   vddVal = 0.0;
  #10us  $finish;
end
endmodule
