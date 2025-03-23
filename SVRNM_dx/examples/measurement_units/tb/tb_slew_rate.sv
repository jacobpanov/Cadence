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
// Testbench for slew rate measurement example
//
//--------------------------------------------------------------------------------------


`timescale 1s/1ps

`define SAMPLE_RATE 100e-9
`define SAMPLE_RATE_NS `SAMPLE_RATE*1e9
`define SOURCE_FREQ 2e3
`define AMPLITUDE 3.0

module tb ();
import cds_rnm_pkg::*; 

wreal4state signal;
wreal4state filtSignal;

Clockstim #(.freq (`SOURCE_FREQ), .ampl (`AMPLITUDE)) u_Source (signal);

SRfilt #(.Fc (10e6), .SR (50e3), .Ts (`SAMPLE_RATE_NS)) u_Filt (filtSignal, signal);

slew_rate_checker #(.Vhi (`AMPLITUDE)) u_slew_rate_checker (filtSignal);

initial begin
   #(5e-3)
   $stop;
end

endmodule
