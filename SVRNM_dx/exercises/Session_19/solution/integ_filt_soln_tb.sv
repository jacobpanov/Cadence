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
// Simple integrator with feedback to create first order time constant 
//
//    _____ +[sum] _______ [Wc/s] _______
//   IN        -     ERR           |  OUT
//             ^                   |
//             |___________________|
//
// --------------------------------------------------------------

`timescale 1ns/1ps

module integ_filt_tb;
import cds_rnm_pkg::*;

parameter real Wc = 6.283*10e6/1e9; // Fc=10MHz converted to rad/ns (Tau=16ns)
parameter real Ts = 5;              // sample period (ns)

wreal1driver IN,ERR,OUT;

real VIN;   // input signal to drive into system
real VSAMP; // data-driven sampled version of VIN
always #(Ts) VSAMP = VIN + (VIN==VSAMP? 1e-12 : 0);
 
assign IN = VSAMP;
assign ERR = IN-OUT;
idt_real #(.K(Wc),.IC(0.0),.maxiter(50)) integ(.IN(ERR),.OUT(OUT));

initial begin
  VIN=0;     #50                    // start at IC, decay toward 0v
  VIN=2;     #80                    // charge to 2v
  VIN=0;     #80                    // decay to 0
  repeat(30) #(Ts) VIN+=0.1;        // slow ramp to 3v
  repeat(10) #(Ts) VIN-=0.3;        // faster ramp back to 0v
  #40 $stop;                        // done with test
end

endmodule

