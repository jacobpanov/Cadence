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
// Test bench for demonstration of real integrator and differentiator
//
//--------------------------------------------------------------------------------------

`timescale 1ns/1ps

module idt_ddt_TB ( );

real IN,IDT,DDT;

src_stim1 Isrc (.OUT(IN)); // stimulus generator

idt_real  Iidt (.IN(IN),.OUT(IDT)); // derivative of input

ddt_real  Iddt (.IN(IN),.OUT(DDT)); // integral of input

endmodule

// Stimulus generator: generate various output waveforms
`define twopi 6.28318530718

module src_stim1 import cds_rnm_pkg::*; (OUT);
output wreal1driver OUT;     // single-ended output with realnet of nettype real
real Freq,Phase;             // sinusoid params
real Vout; 

initial begin
   Vout=0; #300ps        // 0V constant signal for first 300ps
   Vout=0.05; #300ps     // step to 0.05V
   Vout=0.20; #300ps     // step to 0.20V 
   for (Vout=0.2; Vout>-0.1; Vout=Vout-0.005) #20ps;    // ramp down to -0.1V
   for (Vout=-0.1; Vout<0; Vout=Vout+0.005) #40ps;      // ramp up slower to 0V
   Vout = 0; #300ps                // constant at 0V
   Freq=600e6; Phase=0;          // set coefs for sine with freq sweep
   while ($realtime<8ns) begin   // generate ramped sine input
      #20ps Phase = Phase+Freq*20e-12;   // integrate freq to get phase
      if (Phase>1) Phase = Phase-1;    // wraparound per cycle
      Vout = 0.1 * $sin(`twopi*Phase);   // sinusoidal waveform with 0.1 amplitude
      Freq = Freq*1.007;              // slowly increase freq
   end
   #300ps $finish; // constant for 300ps, then stop simulation
end

assign OUT= Vout;

endmodule
