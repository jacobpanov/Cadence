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
//  LDO Testbench
//
//--------------------------------------------------------------------------------------


`timescale 1s/1ps
import cds_rnm_pkg::*;
import EE_pkg::*;

module tb ();

EEnet VDD, VSS, VOUT;
wreal4state VREF;
real reference = 0.85;
logic EN, loadEn;

LDO u_LDO ( 
  .VDD (VDD), 
  .VSS (VSS), 
  .EN (EN), 
  .VIN (VREF), 
  .VOUT (VOUT)
);

load anaLoad ( 
  .vdd (VOUT), 
  .vss (VSS), 
  .en  (loadEn) 
);


assign VDD = '{4.2, `wrealZState, 0};
assign VSS = '{0, `wrealZState, 0};   
assign VREF = reference;

initial begin
   EN = 1'b0;
   loadEn = 1'b0;
   fork
     #(10us) EN = 1'b1;

/*
   // Uncomment to test Startup
     begin
        #(100ns) EN = 1'b0;
        #(300ns) EN = 1'b1;
        #(400ns) EN = 1'b0;
        #(200ns) EN = 1'b1;
  // Additional glitch
        #(200ns) EN = 1'b0;
        #(50ns)  EN = 1'b1;
     end
*/

/*
  // Uncomment this section to enable the load
     #(50us) loadEn = 1'b1;
     #(120us) EN = 1'b0;
     #(140us) EN = 1'b1;
     #(250us) loadEn = 1'b0;
*/
     #(300us) EN = 1'b0;
   join
   #(50us) $stop;
end

endmodule
