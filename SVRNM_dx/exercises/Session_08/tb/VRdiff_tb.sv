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

//VRdiff_tb.sv - test of differential resistor model operation
// TESTBENCH:
//      +-----------------RDA------------------+
//      |                                      |
//    A |           B              C           | D
//      +----RAB----+---VBC--RBC---+----RCD----+   
//      |                                      |
//     RA                                     RD
//      |                                      |
//     VA                                     VD
//     _|_                                    _|_
//      -                                      -

// V+R models in src dir:  VRdiff0, VRdiff1, VRdiffGD0, VRdiff
// V+R models in EEmod dir:  VRsrcD 

import EE_pkg::*;
`timescale 1ns/1ps

module VRdiff_tb;

EEnet A,B,C,D;                              // four EEnet nets
real VA,RA, RAB, VBC,RBC, RCD, VD,RD, RDA;  // values to drive nets

assign A = '{VA, 0.0, RA};       // V+R drive to nets A and D
assign D = '{VD, 0.0, RD};

VRdiffGD0  // netlist four instances of one of the diffl element models
  AB(A,B,0.0,RAB), BC(B,C,VBC,RBC), CD(C,D,0.0,RCD), DA(D,A,0.0,RDA);

initial begin
  VA=2; VD=0; RDA=`wrealZState;  // no RDA feedback
  RA=1000; RAB=1000; RBC=1000; 
  RCD=1000; RD=1000;             // five equal resistors 
  repeat(10) #10 VA+=0.1;        // ramp VA voltage up
  repeat(9) #10 RA+=1000;        // ramp RA resistance up
  #10 RA=`wrealZState;           // RA to open circuit
  #10 RA=0;                      // RA to short
  #10 RAB=1e5;                   // RAB large resistance
  repeat(4) #10 RAB*=0.1;        // RAB decreasing
  #10 RAB=0;                     // RAB to short
  #10 RA=100;                    // RA to small resistance
  #10 RAB=`wrealZState;          // RAB to open circuit
  #10 RDA=0;                     // RDA to short
  #10 RDA=1e5;                   // RDA to big resistance
  #10 RAB=1000;                  // RAB back to 1K (resistor loop)
  repeat(5) #10 VBC+=0.1;        // ramp VBC up within loop
  #10 RDA=1000;                  // RDA downto 1K (stronger loop)
  repeat(2) #10 RA*=10;          // RA to 1K and 10K (slower convergence)
  #10 RD=10000;                  // RD to 10K (very slow convergence)
  #10 RA=`wrealZState; RD=RA;    // RA=RD=Z Floating loop (nonconvergent)
  #25 $stop;
end

// ITERATION COUNTER
int NiterA;                      // number iterations on net A
real TsaveA;                     // time at iterations
always @(A.V) begin              // whenever voltage at A changes
  if ($realtime>TsaveA) begin    //  if time has advanced
    NiterA=0;                    //   set iteration counter to zero
    TsaveA=$realtime;            //   and save new time
  end
  else NiterA++;                 // otherwise bump iteration counter
end
endmodule

