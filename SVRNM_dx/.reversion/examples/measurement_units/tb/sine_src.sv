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
// Fixed frequency sinusoidal source with paramterized sample rate
//
//--------------------------------------------------------------------------------------

`timescale 1s/1ps

`ifndef M_TWO_PI
`define M_TWO_PI 6.28318530717958647652
`endif

module sine_src import cds_rnm_pkg::*; (output wreal4state SRC);
  parameter real sampleRate = 16e6;
  parameter real Freq = 500e3;
  parameter real ampl = 1.0;

  real ts = 1/(sampleRate);  // sample period
  real outInt;                 // internal buffer

  always #ts outInt = ampl * $sin(`M_TWO_PI*Freq*$realtime);

  assign SRC = outInt;

endmodule
