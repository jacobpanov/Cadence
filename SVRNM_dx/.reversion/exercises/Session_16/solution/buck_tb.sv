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
//
// buck mode DC/DC converter testbench
//               CK
//            ...|......................
//    Iin->   : _v_    IL->  L         :  Iout->
//    __________---___ _____ooo___ ______________ 
//   |   [IN] :      _|_[M]      _|_   : [OUT]   |   
//  Vs        :   dio/_\        C---   :        RL 
//   |        :       |           |    :         |  
//   v        :       v           v    :         v
//            :........................:
// Clock (CK):  frequency [Freq], period [Per], duty cycle [Duty]
// Inductor [L], Capacitor [C]
// Diode:  on voltage [Vd], on resistance [Rd]
// Switch: on resistance [Rsw], switch time [Tsw]

module buck_tb;
import EE_pkg::*;

// Adjustable characteristics of the buck converters:
parameter real L=1e-3, C=0.2e-6, Ts=1e-6,  // inductor, capacitor, sample period
               Tsw=100e-9, Tr=20e-9,       // switch & testbench risetimes
               Rsw=0.1, Rd=0.1, Roff=2e6;  // switch & diode on & off resistances

EEnet IN,OUT;

real VS,RS,Freq,Duty,RL;      // input, clock, and load characteristics
real Per,th,tl;               // [ns] period, hi & low times
reg CK=0;
real VEOUT;

always_comb if (Freq>0) begin // compute period and low & high delays 
  Per=1s/Freq;
  th=Duty*Per;
  tl=Per-th;
end

always begin                  // GENERATE CLOCK WAVEFORM
  if      (th==0) begin CK=0; @(th); end        // wait here when duty=0
  else if (tl==0) begin CK=1; @(tl); end        // wait here when duty=1
  else            begin #(tl) CK=1'b1; #(th) CK=1'b0; end // normal clock 
end

// Simulation speed with EEnet using Ts=1us is about 40x faster than analog
// (Comment out one of the two code segments below to test either separately).

// EENET CIRCUIT:
VIRsrcG #(.tr(Tr))  Vsup  (IN,  VS, 0.0, RS);   // input voltage source
buck_conv #(.L(L),.C(C),.Ts(Ts),.Tsw(Tsw),.Roff(Roff),.Rsw(Rsw),.Rd(Rd))
                    Buck (OUT, IN, CK);         // buck converter
VIRsrcG #(.tr(Tr))  Rload (OUT, 0.0, 0.0, RL);  // load on output

// ANALOG CIRCUIT:
EVIRsrcG #(.tr(Tr))  Esup  (EIN, VS, 0.0, RS);  // electrical voltage source
Ebuck_conv #(.L(L),.C(C),.Tsw(Tsw),.Roff(Roff),.Rsw(Rsw),.Rd(Rd))
                     Ebuck (EOUT,EIN, CK);      // electrical buck model
EVIRsrcG #(.tr(Tr))  Eload (EOUT,0.0, 0.0, RL); // electrical load
EVmeas       Emeas (EOUT, 1'b0, VEOUT);         // electrical voltage measurer

// MEASURE & PRINT TASK:
real VOLee, VOLan, VOHee, VOHan;       // hi&lo output voltage cycle levels
real VO_EE, VO_AN;                     // average cycle voltage
real VO_PCTERR, SUMSQ;                 // output error percent & sum of squares
real RIP_EE, RIP_AN, RIP_PCTERR;       // ripple for each, and percent error
int NTESTS;                            // number of tests performed

task Checkit;
  #1 repeat(500us/Per-1) @(posedge CK);// skip to last clock before 500us
  VOLee=OUT.V;                         // save starting voltage value
  VOLan=VEOUT;
  repeat(4) #(th*0.20) begin           // pick minimum in half-cycle
    if (OUT.V<VOLee) VOLee=OUT.V;
    if (VEOUT<VOLan) VOLan=VEOUT;
  end
  @(negedge CK);                       // go to trailing edge
  VOHee=OUT.V;                         // save starting voltage value
  VOHan=VEOUT;
  repeat(4) #(tl*0.20) begin           // pick maximum in half-cycle
    if (OUT.V>VOHee) VOHee=OUT.V;
    if (VEOUT>VOHan) VOHan=VEOUT;
  end
  VO_EE = (VOLee+VOHee)/2;             // compute average voltage
  RIP_EE = (VOHee-VOLee)/2;            // compute ripple voltage
  VO_AN = (VOLan+VOHan)/2;
  RIP_AN = (VOHan-VOLan)/2;
  VO_PCTERR = 100*(VO_EE/VO_AN-1);     // percent error of output voltage
  RIP_PCTERR = 100*(RIP_EE/RIP_AN-1);  // percent error of ripple voltage
  NTESTS++;                            // number tests performed
  SUMSQ += VO_PCTERR*VO_PCTERR;        // sum of squares of pct voltage error
// Print summary of info for test:
  $display("\n>> T=%5.0fus  RL=%4.0f  F=%6.0f  DC=%4.2f",
               $realtime/1us,  RL,      Freq,     Duty);
  $display("     VO:   AN: %6.4f  EE: %6.4f  VO Err: %5.2f%%",
                           VO_AN,     VO_EE,         VO_PCTERR );
  $display("     Vrip: AN: %6.4f  EE: %6.4f  Rip Err: %3.0f%%",
                           RIP_AN,    RIP_EE,        RIP_PCTERR );
endtask

// TEST PROCEDURE:
initial begin
  VS=0; RS=0; RL=100;              // initial setup, turned off, load attached
  #100us Duty=0.5; Freq=100e3;     // start the clock (50% duty cycle)
  #100us repeat(60) #5us VS+=0.05; // ramp on the input voltage
  Checkit; RL=10;                  // switch through various load values
  Checkit; RL=30;          // NOTE: for RL step from 30 to 300ohm, there is
  Checkit; RL=300;         // negative inductor current at switch turnoff,
                           // resulting in large voltage spike at diode!
  Checkit; RL=1000;                // very light load (discontinuous conduction)
  Checkit; RL=30;                  // back to normal load
  Checkit; Duty=0.8;               // Duty cycle set to 80% (2.7V)
  Checkit; Duty=0.2;               // 20% (0.6V)
  Checkit; RL=300;                 // switch to light load
  Checkit; Duty=0.8;               // 80% (2.7V) 
  Checkit; Duty=0.5;               // 50% (1.5V)
  Checkit; Duty=0;                 // turn off (no clock so don't check!)
  #500us   Duty=0.5;               // turn on with lighter load
  Checkit; Freq=200e3;             // higher freq clock
  Checkit; RL=15;                  // heavy load
  Checkit; Freq=50e3;              // lower freq clock
  Checkit; $display("\n>>>> Summary:  VO RMS Err = %5.2f%%\n", $sqrt(SUMSQ/NTESTS) );
  #100 $stop;                      // done testing
end

endmodule

