//--------------------------------------------------------------------------------------
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
//
//--------------------------------------------------------------------------------------
//
// simple programmable gain amplifier with added bias checks
// FEATURES
//  gain (in dB) controlled by digital control bus
//  supply voltage and bias current and voltage values checked
//  output large signal limiting based on supplies
//  CM output level defined by half of power supply
// LIMITATIONS
//  no other dependencies on bias, CM, or supply voltages modeled
//  no frequency response or slewing limitations modeled
//  dB gain vs. control approximated by linear relationship
// 
//--------------------------------------------------------------------------------------

`timescale 1ns/1ps

module pga import cds_rnm_pkg::*; ( OUTP,OUTN, INP,INN, VCVGA, VB,IBB, VDD,VSS, PD );

import mymath_pkg::*;               // import math functions

output wreal1driver OUTP,OUTN;     // differential output
input wreal1driver INP,INN;        // differential input
input logic[2:0] VCVGA;            // digital control voltage
input wreal1driver VB,IBB;         // required bias inputs
input wreal1driver VDD,VSS;        // power supplies
input logic PD;                    // powerdown control
parameter real dbmin=-1,dbmax=20;  // gain(dB) for VCVGA=000 & 111
real DBinc,Adb,Av;                 // internal vars
real gainErr = 0;                 // gain error in dB
real centerOffset = 0;            // common mode offset in V

initial DBinc=(dbmax-dbmin)/7;     // compute per-bit change to gain

always_comb
if ((^VCVGA)===1'bx) Adb=-60;                // low gain if invalid control
else Adb = dbmin+DBinc*VCVGA + gainErr;      // compute gain in dB

always_comb Av = 10.0**(Adb/20.0);  // convert to V/V

// check device is active (PD low, supply & bias correct):
wire Active = (PD===1'b0) && (VDD>=2.0) && 
               abs(IBB-50e-6)<=20e-6 && abs(VB-0.7)<=0.1;

real Voctr,Vomax,Vodif;             // internal real variables

assign Voctr = Active*(VDD+VSS)/2;	// CM center output level
assign Vomax = max(VDD-VSS,0.001);	// max swing of output

// define saturation limiting and high attenuation when inactive:
assign Vodif = Vomax * $tanh(Av*(INP-INN)/Vomax)*(Active? 1:1e-6);

assign OUTP = Voctr + Vodif/2 + centerOffset;	        // differential drive of output pins
assign OUTN = Voctr - Vodif/2 + centerOffset; 

endmodule


