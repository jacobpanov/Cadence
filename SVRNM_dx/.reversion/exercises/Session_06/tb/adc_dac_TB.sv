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

// --------------------------------------------------------------
//
// ADC and DAC test bench
//
// --------------------------------------------------------------

`timescale 1ns/1ps

module adc_dac_TB ( );
  real AIN,REFH,REFL; logic CK=0;
  logic[7:0] DOUT8; logic[3:0] DOUT4;
  real AOUT8; 
  initial begin 					// real input controls
    AIN=0; REFH=3; REFL=0;				// initial input settings
    while (AIN < 3.05)  #20 AIN = AIN + 3.0/255;	// slow input ramp up
    while (AIN > -0.05) #20 AIN = AIN - 0.06;	 	// faster ramp down
    while (AIN < 1.5)   #20 AIN = AIN + 0.15;	 	// ramp up very fast
    while (REFH > 1.3)  #20 REFH = REFH - 0.03; 	// ramp reference down  
    #100 $stop;  					// done testing
  end

  initial begin 					// clock generator
    CK=0; 						// init clock level
    repeat (550) #10 CK=!CK;				// clock @ 20ns
    repeat (8) begin #10 CK=1'b1; #10 CK=1'bx; end	// invalid clock
    repeat (8) begin #10 CK=1'b0; #10 CK=1'b1; end	// OK clock
    repeat (8) begin #10 CK=1'bx; #10 CK=1'b0; end	// invalid clock
    repeat (600) #10 CK=!CK; 				// OK clock
  end

  adc #(.Nbits(8)) adc8(DOUT8, AIN,REFH,REFL, CK);	// 8-bit ADC
  adc #(.Nbits(4)) adc4(DOUT4, AIN,REFH,REFL, CK);	// 4-bit ADC
  dac #(.Nbits(8)) dac8(AOUT8, DOUT8, REFH,REFL);	// 8-bit DAC
endmodule

