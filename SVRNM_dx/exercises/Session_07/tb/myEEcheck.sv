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

// "myEEcheck.sv" - test multiple EEnet components driving single net

module myEEcheck;   // test for simple EEnet element models 

real V1,R1,R2,I3;   // terms to drive elements with
real Vmeas,Imeas;   // measured voltage & current (node A to ground)
EE_pkg::EEnet A;    // net to be driven
EE_pkg::EEnet B;

myVRdrvG  Vsrc(A, V1,R1, Imeas);  // V+R source
myRes     Res (A, R2, Vmeas);     // resistor
myIsrc    Isrc(A, I3);            // current source

myVIR  VR(B, V1, 0.0 ,R1, Imeas1);
myVIR  IR(B, 0.0, I3, R2, Imeas2);

initial begin
  V1=2; R1=1e3; R2=4e3; I3=1e-3;  // Drivers: 2V+1Kohms, 4Kohms, 1mA
  #50 V1=1;                       // step voltage down to 1V
  #50 repeat(10) #10 V1-=0.1;     // ramp voltage down to 0V
  #50 repeat(4)  #10 R2/=2;       // ramp resistor down to 250ohms
  #50 repeat(6)  #10 I3-=0.5e-3;  // ramp current down to -2mA
  #50 repeat(10) #10 V1+=0.3;     // ramp voltage up to 3V 
  #50 V1=`wrealZState;            // set VR driver to open circuit
  #50 V1=3;                       // set VR driver back to 3V
  #50 R2=3e3;                     // set resistor to 3Kohms
  #50 R1=0;                       // change to ideal voltage source 
  #50 repeat(4)  #10 I3+=1e-3;    // ramp current up to +2mA
  #50 $stop;                      // done with testing
end
endmodule

