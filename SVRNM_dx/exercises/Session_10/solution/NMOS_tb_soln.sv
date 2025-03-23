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

// "NMOS_tb.sv" - testbench for NMOSdio module
//
// Test NMOS diode models with three types of input signals:
//   1) low impedance (voltage drive)
//   2) variable impedance (varying drive resistance)
//   3) high impedance (current drive)

`timescale 1ns/1ps

module top;

import EE_pkg::*;
real Vd,Id,Rd;                   // VIR valus to drive into MOS diode model
EEnet DG,DI,DV;                  // output node for 3 versions of diode model

assign DG = '{Vd,Id,Rd};                     // assign values to drive into
NMOSdioG #(.kp(100e-6), .vth(1.0)) dioG(DG); // the I+G format model

assign DI = '{Vd,Id,Rd};         // repeat with ideal-current drive model
NMOSdioI #(.kp(100e-6), .vth(1.0), .itermax(500)) dioI(DI);  

assign DV = '{Vd,Id,Rd};         // repeat with ideal-voltage drive model
NMOSdioV #(.kp(100e-6), .vth(1.0), .itermax(500)) dioV(DV);  

// Compute current flowing from each driver:
real IG,II,IV;
assign IG = Id+(Vd-DG.V)/Rd;
assign II = Id+(Vd-DI.V)/Rd;
assign IV = Id+(Vd-DV.V)/Rd;

// copy iteration flags from models to simplify checking:
int NG,NI,NV;
assign NG = dioG.Niter;   
assign NI = dioI.Niter;   
assign NV = dioV.Niter;   

enum {VarV,VarR,VarI} TestType;  // enumerated flag for printing

initial begin
  TestType=VarV;             // TEST#1: Voltage drive at low resistance
  Vd=3; Id=0; Rd=10;         // start with high voltage (3V @ 10ohms)
  repeat(25) #10 Vd-=0.1;    // ramp voltage down to off region (0.5V)
  repeat(4)  #10 Vd+=1.0;    // faster stepping up & down
  repeat(4)  #10 Vd-=1.0;
  #10 Vd=4;                  // big steps between on & off voltages
  #10 Vd=0; 
  #10 TestType=VarR;         // TEST#2: Variable-resistance drive
  #10 Vd=3; Rd=10;           // begin with low resistaance (3V @ 10ohms)
  repeat(9) #10 Rd*=2;       // and ramp upward, doubling each step
  Rd=1e4;                    // to max of 10Kohms
  repeat(3)  #10 Rd/=10;     // faster stepping down & up
  repeat(3)  #10 Rd*=10;
  #10 Rd=10;                 // big steps between high & low resistance
  #10 Rd=1e6;                  
  #10 TestType=VarI;         // TEST#3: Current drive at high resistance
  #10 Id=1e-6; Vd=0;         // start with low current (1uA @ 1Mohm)
  repeat(10) #10 Id*=2;      // ramp current upward to 1mA
  repeat(3)  #10 Id/=10;     // faster stepping down & up
  repeat(3)  #10 Id*=10;
  #10 Id=0;                  // big steps between on & off currents
  #10 Id=1e-3;
  #10 Id=1e-6;
  #10 $stop;                 // done testing.
end

endmodule
