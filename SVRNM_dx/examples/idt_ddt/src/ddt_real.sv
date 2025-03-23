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
//--------------------------------------------------------------------------------------
//
// Time derivative of sampled-data input signal
//
//--------------------------------------------------------------------------------------

`timescale 1ns/1ps

module ddt_real import cds_rnm_pkg::*; (IN,OUT);

input wreal1driver IN;
output wreal1driver OUT;

parameter real K=1;  // derivative constant (ns)

real T0,IN0;         // previous timepoint
real Vout ; 

initial begin
  T0 = 0;            // initialize to first point 
  IN0 = IN;
  Vout = 0;          // initial output value
end

always @(IN)         // on each change of input
 if ((IN<1e20) && (IN>-1e20)) begin  // skipping X, Z, NaN values
   if ($realtime>T0) // differentiate over timestep
     Vout = K*(IN-IN0)/($realtime-T0);
   IN0 = IN;         // save input and time values
   T0 = $realtime;
 end

assign OUT = Vout ;

endmodule

