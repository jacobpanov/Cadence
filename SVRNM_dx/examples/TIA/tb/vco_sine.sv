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
//--------------------------------------------------------------------------------------
//
// Sinusoidal Voltage-controlled Current Source
//
//--------------------------------------------------------------------------------------

`timescale 1ns/1ps

`define M_TWO_PI 6.28318530718
// get sine function from C math library:
import "DPI" pure function real sin (input real rTheta);

module vco_sine import cds_rnm_pkg::*; import EE_pkg::*; (vin, out, ampl);

  input wreal1driver vin;          // Input is real value
  output EEnet out;                // Output is sinusoidal waveform
  input wreal1driver ampl;         // amplitude control

  parameter real center_freq=10e6;          // freq when zero input (Hz)
  parameter real vco_gain=15e6;             // freq gain constant in (Hz/V)
  parameter real iMag=100e-6;               // magnitude of output sinusoid in amps with input ampl = 1
  parameter real tinc=2;                    // output sample rate (ps)

real freq, phase;                              // freq value & sine phase
real iOut, iPeak;

always_comb begin                                        // when input changes
  freq = center_freq + vco_gain*vin;          //  compute frequency
  $display("Frequency=%f,vco_gain=%f, vin=%f ",freq, vco_gain,vin);
end

always_comb begin
   iPeak = ampl*iMag;
  $display("amplitude=%f ",iPeak);
end

always #(tinc) begin phase = phase+freq*tinc*1e-9;      // update phase every tinc ps

end

assign iOut = iPeak*$sin(`M_TWO_PI*phase);         // compute output from phase
assign out = '{`wrealZState, iOut, 0};


endmodule
