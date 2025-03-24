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

//SystemVerilog HDL for "realExampLib", "vco_ds_TB" "systemVerilog"
// test bench for digital & sinusoidal VCO models

`timescale 1ns/1ps

module vco_ds_TB ( );

real Vin;        	// input voltage to drive vco
logic Vclk;        	// output from digital vco
real Vsin;             // output from sinusoidal vco
logic [4:0] tune;         // control for digital coarse tuning
integer i;

vco_dig  digvco(Vin, Vclk, tune);	// instantiate the vco's
vco_sine sinvco(Vin, Vsin, tune);

initial begin			// Test procedure:
  tune = 5'h10;                 // Begin with tune at half scale
  Vin = 1;  #300;		// start with input at 1V -> 23MHz
  for (i=16; i<32; i=i+3) begin // step tune up to max
     tune = i; #300;
  end
  for (i=31; i>0; i=i-5) begin // step tune down to min
     tune = i; #300;
  end
  tune = 5'h10;                // Back to center
  Vin = 2;  #200		// 2V -> 39MHz
  Vin = 0;  #200		// 0V -> 9MHz
  while (Vin<2) #10 Vin=Vin+0.020;// ramp 0v to 2v over 1000ns
  #100 $finish;    		// test complete
end

// MEASURE ACTUAL DIGITAL FREQUENCY:
real fdig,tupd=0;  		// measure actual digital frequency:
always @(Vclk) begin		// on leading clock edge
  if (tupd>0) fdig=0.5*1s/($realtime-tupd);	//  compute F=1/period (Hz)
  tupd = $realtime;                     //   and save edge time
end

// MEASURE ACTUAL SINUSOID FREQUENCY:


//ADD YOUR CODE HERE




endmodule
