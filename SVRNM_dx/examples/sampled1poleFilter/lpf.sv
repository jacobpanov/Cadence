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
// First-Order Simple Low Pass Filter

`timescale 1ns/1ps
`define twopi 6.28318530718

module lpf import cds_rnm_pkg::*; (OUT, IN, poleTrim, gainTrim);

 output wreal1driver OUT;    // output of filter
 input wreal1driver IN;      // input to filter
 input [3:0] poleTrim;  // Pole adjust control
 input [3:0] gainTrim;  // Gain adjust control
 real Fp;               // corner frequency (Hz)
 real Av;               // voltage gain (V/V)

 parameter real Ts = 1; // input sample rate (ns)
 parameter real poleStep = 50e3; // Fp change per step
 parameter real poleFmin = 50e3;  // Default pole location for control = 0
 parameter real gainStep = 1.0/16; // gain change per step

 real K,d0,d1,n0,n1,x0,x1,y0,y1; 

always begin
  if (!($isunknown(poleTrim))) begin	  // check if poleTrim is valid
    Fp = poleFmin + poleTrim * poleStep;   // Scale by step size
    K = 2/(Ts*Fp*`twopi/1s); 
    n0 = 1 ; n1 = 1 ;   // compute proper numerator coefficients
    d0 = 1+K; d1 = 1-K; // compute proper denominator coefficients
  end
  else begin // invalid poleTrim 
    $display("WARNING (%M) pole control undefined.");
    Fp = poleFmin; K=0; d0=1e6; d1=0;	// heavily attenuate
  end
  @(poleTrim);     // wait for Fp to change
end

always begin
  if (!($isunknown(gainTrim))) begin
    Av = gainTrim * gainStep;
  end
  else begin
    $display("WARNING (%M) gain control undefined.");
    Av = 0.0;
  end 
  @(gainTrim);
end

// MAIN CALCULATION LOOP 
always @(IN) begin	
  if ($realtime==0) begin	// At DC op point, output=input.
    x0 = (Av*IN<1e20)? Av*IN:0;	// if initially NaN, just use zero
    x1 = x0; y0 = x0; y1 = x0;   // static, set all values
  end
  else begin	// delay line implementation
    x1=x0; 	// input delayed by 1 unit
    x0 = (Av*IN<1e20)? Av*IN:0;  // Assign input filtered for NaN
    y1=y0;	// output delayed by 1 units
    y0=(x0*n0 + x1*n1 - y1*d1)/d0; // compute new output
  end
end

assign OUT = y0;	// pass computed y0 to output pin

endmodule
