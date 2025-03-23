//--------------------------------------------------------------------------------------
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
// Testbench with PWM source for averaging sampler
//
//--------------------------------------------------------------------------------------

`timescale 1ns/1ps

module samp_avg_TB ( );

real IN, OUTsimp, OUTavg;   		// input data and output from samplers
real Vlo, Vhi, Tlo, Thi;      	        // cycle params of input signal

always begin				// PWM signal generator
  IN = Vlo; #Tlo; 			// real valued clock input with specified params
  IN = Vhi; #Thi;			// Stays low for Tlo, then high for Thi and repeats
end

initial begin
  Vlo=0; Vhi=1;			// switch input between 0 and 1 volt
  Tlo=2.7; Thi=2.7; #40		// symmetric input pulse (ns)
  Tlo=3.4; Thi=2.3; #40		// asymmetric pulse (ns)
  Tlo=3.2; Thi=0.5; #40		// narrow pulse (ns)
  $stop;			// done testing
end

samp     #(.Ts(1)) Ssimp(IN,OUTsimp);	// simple sampler Instantiation
samp_avg #(.Ts(1)) Savg (IN,OUTavg );	// averaging sampler Instantiation

endmodule

