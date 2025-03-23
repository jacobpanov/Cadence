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
// Test bench for IQ mixer model
//
//--------------------------------------------------------------------------------------
`timescale 1s/1ps

module mixerIQ_tb import cds_rnm_pkg::*; import EE_pkg::*;  (  ); 

real Vvdd, Vvss;
logic en = 1'b0;
wreal4state rfp, rfm, ifip, ifim, ifqp, ifqm;
logic vcop, vcom;
EEnet vdd, vss;
 
vcoSource IvcoStim ( .vcop( vcop ), .vcom( vcom ) );
 
rfSource #(.amplitude(10e-3), .carrierFreq(2440e6)) 
   IrfStim ( .rfp( rfp ), .rfm(rfm ) );
 
div2Qgen u_qDiv ( .LOqm( LOqm ), 
  .vcop( vcop ), .vcom( vcom ), .LOip( LOip ), .vss( vss ), .LOim( LOim ), 
  .LOqp( LOqp ), .en( en ), .vdd( vdd ) );
 
mixerIQ u_MIX ( .LOqm( LOqm ), .ifqp( ifqp ), .rfp( rfp ), .LOip( LOip ), 
   .vss( vss ), .ifim( ifim ), .LOim( LOim ), .ifip( ifip ), .LOqp( LOqp ), 
   .en( en ), .vdd( vdd ), .ifqm( ifqm ), .rfm( rfm ) );

initial begin
   Vvdd = 1.5; Vvss = 0.01;
   #(1e-9) Vvss = 0.0;
   #(1e-6) en = 1'b1;

   #(100e-6) $finish;
end

assign vdd = '{Vvdd, 0, 0};
assign vss = '{Vvss, 0, 0};

endmodule
