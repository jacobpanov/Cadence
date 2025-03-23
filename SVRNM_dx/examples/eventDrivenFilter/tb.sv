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
// Testbench for event driven example
//
//--------------------------------------------------------------------------------------


`timescale 1s/1ps

`define SAMPLE_RATE 100e-9
`define SAMPLE_RATE_NS `SAMPLE_RATE*1e9
`define SWEEP_RATE (2e-6/`SAMPLE_RATE)*1e3

module tb ();
import cds_rnm_pkg::*; 

wreal4state signal;
wreal4state filtSignal1, filtSignal2, filtSignal3;
logic en1, en2, en3, en4;

signalSource #(.Ts (`SAMPLE_RATE)) u_Source (en1, signal);
signalSource2 #(.Ts (`SAMPLE_RATE)) u_Source2 (en2, signal);
signalSource3 #(.ampl (2), .fMin (1e3), .fMax (100e3), .Ts (`SAMPLE_RATE), .sweepRate (2e4)) u_Source3 (en3, signal);
signalSource3 #(.ampl (0.2), .fMin (1e3), .fMax (100e3), .Ts (`SAMPLE_RATE), .sweepRate (2e4)) u_Source4 (en4, signal);


SRfilt #(.Fc (200e3), .SR (25e3), .Ts (`SAMPLE_RATE_NS)) u_Filt1 (filtSignal1, signal);

SRfilt #(.Fc (100e3), .SR (50e3), .Ts (`SAMPLE_RATE_NS)) u_Filt2 (filtSignal2, signal);

SRfilt #(.Fc (50e3), .SR (100e3), .Ts (`SAMPLE_RATE_NS)) u_Filt3 (filtSignal3, signal);

initial begin
   en1 = 1'b1;
   en2 = 1'b0;
   en3 = 1'b0;
   en4 = 1'b0;
   #(4e-3);
   en1 = 1'b0;
   #(1e-6);
   en2 = 1'b1;
   #(0.5e-3);
   en2 = 1'b0;
   #(1e-6);
   en3 = 1'b1;
   #(3.5e-3);
   en3 = 1'b0;
   #(1e-6);
   en4 = 1'b1;
   #(3.5e-3);
   en4 = 1'b0;
   #(0.5e-3);
   $stop;
end

endmodule
