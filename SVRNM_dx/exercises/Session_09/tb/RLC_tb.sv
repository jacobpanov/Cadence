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

// "RLC_tb" - simple RLC circuit test
import EE_pkg::*;

module RLC_tb;

parameter real C=10e-12, L=10e-6, Tr=1e-9 Ts=2.5e-9;
EEnet A,B;         // EEnet circuit nets
real Vin,Rs;       // V and R variables driving RLC circuit
real Ian,Iee;      // currents in analog & EEnet circuits
real PERan,PERee;  // measured oscillation periods

// Electrical RLC circuit implementation:
EVIRsrcG #(.tr(Tr))  VRe (Ae, Vin,0.0,Rs);   // Electrical model for VIR drive
induc    #(.l(L),.ic(0)) L1e (Ae,Be);        // VerilogAMS inductor
cap_gnd  #(.c(C),.ic(0)) C1e (Be);           // VerilogAMS grounded capacitor 

// EEnet RLC circuit implementation:
VIRsrcG #(.tr(Tr))   VR (A, Vin,0.0,Rs);     // EEnet VIR driver with risetime

//>>>>>  ADD EENET-BASED INDUCTOR AND CAPACITOR INSTANCES HERE! 

IndDeq0 #(.l(L), .ic(0), .tinc(Ts))  L1 (A,B);   // EEnet inductor model
CapGeq0 #(.c(C), .ic(0), .tinc(Ts))  C1 (B);     // EEnet capacitor model



// Move currents to local variables:
assign Ian = VRe.Imeas;
assign Iee = VR.Imeas;

// Test procedure:
initial begin
  Vin=2; Rs=3000; #200     // initially well damped
  Vin=0; Rs=1000; #200     // moderate damping
  Vin=2; Rs=200;  #300     // lightly damped
  Vin=0; Rs=10;   #100     // barely damped
  fork                     // start two tasks to
    getPeriod(Ian,PERan);  //  measure periods of current oscillations
    getPeriod(Iee,PERee);
  join_none                // continue without waiting for completion
  #200 $strobe(            // print reported periods and difference
   "MEASURED PERIODS:  Analog %5.2fns  EEnet %5.2fns  Diff %5.2fns (%5.2f%%)",
        PERan,          PERee,      PERee-PERan, (PERee/PERan-1)*100 );
  #1 $stop;                // end simulation
end

// Task to compute period of a real signal:
task automatic getPeriod(ref real A,Per);
 real To,Ao,Tx0,Tx1;
 begin
   wait (A<0);                                      // wait until it's low
   while (A<0) begin Ao=A; To=$realtime; @(A); end  // save last low point
   Tx0 = $realtime - ($realtime-To)*A/(A-Ao);       // interpolate Tx0 on high
   wait (A<0);                                      // wait until low again
   while (A<0) begin Ao=A; To=$realtime; @(A); end  // save last low point
   Tx1 = $realtime - ($realtime-To)*A/(A-Ao);       // interpolate Tx1 on high
   Per = Tx1-Tx0;                                   // compute period
 end
endtask

endmodule 

