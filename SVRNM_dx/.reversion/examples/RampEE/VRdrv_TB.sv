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

// Test VRdrv driver block with various drive effects

`timescale 1ns/1ps

module VRdrv_TB();
import EE_pkg::*;

EEnet N1,N2,N3;              // nets to be driven
real vval,rval,tr,vl,il,rl;  // controls for drivers and load signals

VRdrv1              D1( N1, vval, rval, tr);  // single-step risetime
VRdrv2 #(.ts(1ns))  D2( N2, vval, rval, tr);  // simple sampled ramp
VRdrv3 #(.ts(1ns))  D3( N3, vval, rval, tr);  // alterable ramp+ext event valid

assign N1 = '{vl,il,rl};     // drive all nets with same load signals
assign N2 = '{vl,il,rl};
assign N3 = '{vl,il,rl};
int T;
initial begin
  repeat(2) begin            // DRIVE SIGNAL:
    T=0; tr=5ns; vval=0; rval=100;       // initially 0V+100ohms with 5ns risetime
    vl=0; il=0; rl=900;      #10         //   into a 900ohm load
    T=1; vval=2;             #10         // ramp voltage up
    T=2; rval=2100;          #10         // ramp resistance up
    T=3; vval=3; rval=600;   #10         // ramp V up, R down
    T=4; tr=3.5ns; vval=1; rval=0; #10   // faster ramp to lower ideal Vsrc
    T=5; tr=0.6ns; vval=2;   #2.3        // fast (single-step) ramp up
    T=6; tr=15ns; vval=0;    #17.7       // slow ramp down (ends not at sample points)
    T=7; tr=15ns; vval=3; rval=1350; #10 // start slow V&R ramp up 
    T=8; vval=0;             #20;        // interrupt at 2/3, ramp V back
  end
  $stop;                     // done after two reps.
end

initial begin                // ADDITIONAL EVENTS AT OUTPUT:
  #110;                             // no events in first rep of changes, then:
  #2 il=1e-9; #1.7 il=0;            // 1: add 2 events during first ramp
  #6.3 repeat(10) #0.7 il=1e-9-il;  // 2: add repeating events during next ramp
  #4.3 repeat(10) #0.26 il=1e-9-il; // 3: add bunch of fast events mid-ramp
  #6   repeat(36) #1.63 il=1e-9-il; // add slower external events through rest
end

endmodule

