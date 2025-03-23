// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2018, Cadence Design Systems, Inc. All rights reserved.

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

// Swit_TB - Compare EEnet Capacitor options for rapid time constant change

//  Testbench topology:
//     _______________        
//    |       |       |
//   R=1K     |      Swit (Ron=10,Tr=100ps)
//    |    C=100pF    |
//   V=3v     |      V=1v    
//   _|_     _|_     _|_
//
//  When the switch closes, the capacitor rapidly discharges.
//  Charging time constant is 100ns, discharging is 1ns.

module Swit_TB;

import EE_pkg::*;
EEnet A,As,B,Bs,C,Cs;  // EEnet nets
reg en;                // enable for switch control
real EV;               // voltage at analog net "E"
int NA,NB,NC,NE;       // update counter for each net

// EENET USING VARIABLE STEPSIZE:
assign A = '{3,0,1000};
CapGx    #(.c(1e-10),.reltol(0.01),.vtol(1e-4),.ic(0)) ACap(A);
SwitD    #(.tr(1e-10))  ASw (A,As,en);
assign As = '{1,0,0};
always @(A.V) NA++;

// EENET USING BIGSTEP APPROXIMATION (5ns stepsize):
assign B = '{3,0,1000};
CapGeq   #(.c(1e-10),.tinc(5e-9),.ic(0)) BCap(B);
SwitD    #(.tr(1e-10))  BSw (B,Bs,en);
assign Bs = '{1,0,0};
always @(B.V) NB++;

// EENET USING FIXED TIMESTEP (1ns works, 5ns fails):
assign C = '{3,0,1000};
CapGeq1  #(.c(1e-10),.tinc(5e-9),.ic(0)) CCap(C);
SwitD    #(.tr(1e-10))  CSw (C,Cs,en);
assign Cs = '{1,0,0};
always @(C.V) NC++;

// ANALOG ELECTRICAL REALIZATION:
EVIRdc   #(.v(3),.r(1000))   EVi (E);
ECapG    #(.c(1e-10),.ic(0)) ECap(E);
ESwitD   #(.tr(1e-10))       ESw (E,Es,en);
EVIRdc   #(.v(1))            EVs (Es);
EVmeas Em (E,CK,EV);
always @(EV) NE++;


// ENABLE CONTROL
initial begin
  en=0;
  #500 en=1;
  #50 en=0;
  #100 $stop;
end

endmodule

