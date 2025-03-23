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

// Programmable EEnet Sinusoidal Voltage Source

`timescale 1ns/1ps

module sinesrc_tb ();
import EE_pkg::*; 
real vdc,vm,fsin,rval;
EEnet IN,OUT;

sinesrc #(.ptspercyc(12))        VIN (IN,vdc,vm,fsin);        // sine generator
VRsrcD  #(.tr(1e-9))              R1 (IN,OUT,0.0,rval,Imeas); // series resistor
CapGeq  #(.c(10e-12),.tinc(7e-9)) C1 (OUT);                   // load capacitor

initial begin
  vdc=1; vm=0.5; fsin=5e6; // initial setup:
  rval=1e3;          #400  //  fsin=5MHz, Tau=10ns, Fc=16MHz (gain=0.95)
  fsin=10e6; vm=1;   #200  // larger, faster input sinusoid  (gain=0.85)
  fsin=16e6;         #200  // input freq matches corner freq (gain=0.71)
  rval=5e3;          #200  // Tau=50ns, Fc=3.2MHz: significant attenuation
  rval=`wrealZState; #150  // open circuited - capacitor holds
  rval=1e3;          #150  // normal following again
  $stop;
end

// Timestep monitor:
real Tlast,TimeStep;
always @(IN.V,IN.I,IN.R) if ($realtime>Tlast) begin
  TimeStep = $realtime-Tlast;
  Tlast = $realtime;
end

endmodule

