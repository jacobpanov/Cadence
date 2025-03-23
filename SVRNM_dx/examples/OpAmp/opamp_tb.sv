// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2019, Cadence Design Systems, Inc. All rights reserved.

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
// Test Bench for Op Amp (EENET FORMAT)
//                       
//                 (N)             (OUT)
//      Vin ---RI---+-------RF-------+
//                  |  |'-._         |
//                  +--|vinm'-._     |        (CO)
//                     |     out:----+---RSW---+
//          Vref ------|vinp_.-'     |         |
//                 (P) |_.-'         RL        CL
//                                  _|_       _|_
//                                   -         -

`timescale 1ns/1ps
import EE_pkg::*;

module opamp_tb;
// Note that with ugf=10MHz, time constant at unity gain is 15.9ns,
// so simulation should be convergent provided tinc<15.9ns.  Some 
// oscillation and nonconvergent points can occur for larger timesteps.
// For comparison to analog model, make sure the same tinc is specified
// in opamp_tba.sv file, since it is also used to set risetimes.

parameter real sr=40e6,ugf=10e6,av=10e3;      // op amp parameters
parameter real c=3e-9,tinc=10e-9,vtol=1e-4;   // other parameters
localparam real tns=tinc*1s;                  // tinc in nanoseconds

real Vin,Vref,Vdd,Vss,RI,RF,RL,RSW;           // adjustable elements
EEnet P,N,OUT;                                // EEnet nodes
real Icl,Irf;                                 // measured currents
real Freq,Vpk,Phs;                            // coefs for sine input

opamp1 #(.sr(sr),.ugf(ugf),.av(av),.vtol(vtol),.tinc(tinc))
                       Op (OUT, P.V,N.V, Vdd,Vss);
VIRsrcG #(.tr(tinc))   Vm (N,      Vin, 0.0, RI );
VIRsrcG #(.tr(tinc))   Vp (P,      Vref,0.0, 0.0);
VIRsrcG #(.tr(tinc))   Rl (OUT,    0.0, 0.0, RL );
VRsrcD #(.tr(tinc))    Rf (N,OUT,  0.0, RF,  Irf);
VRsrcD #(.tr(tinc))    Rs (OUT,CO, 0.0, RSW, Icl);
CapGeq #(.c(c),.tinc(tinc),.vtol(vtol))  Cl (CO);

initial begin
  Vin=0; Vref=0; Vdd=5; Vss=-5; 
  RI=1e3; RF=1e9; RL=1e9; RSW=1e9;    // initially in open loop mode
  #100 Vref=1;    // should slew up at 0.4V/10ns
  #100 Vref=0;    // at 4V, zero drive, decays with Fc=1Khz (near constant)
  #1000 Vref=-0.01; // decaying toward -100 (100v/160us = 1v/1600ns)
  #3200 RF=9e3; Vref=0.1; // Acl=10 from Vref, to 1V out at Fc=1MHz
  #2000 RF=1e3;           // Acl=2 from Vref, to 0.2V out at Fc=10MHz
  #500 Vref=1;            // to 2V out
  #500 repeat(40) #(tns) Vin+=0.05;  // ramp up input voltage (Acl=-1 from Vin)
  #500 Vin=0;             // step input back down, output back to 2V
  #300 RI=1e9; RF=1;      // unity gain feedback, output now follows Vref
  #300 Vref=5;            // slew up to 5V at 40V/us
  #300 Vref=1;            // slew down to 1V
  #300 RL=1e3;            // add load resistance
  repeat(5) #200 RL/=2;   // incrementally lower output resistance
  #200 repeat(5) #200 RL*=2;     // back to moderate load
  #1000 RSW=1;                   // attach capacitive load
  #3000 Vref=0;                  // slewing down to zero with capacitive load
  #3000 Vref=4;                  // slewing back up with capacitive load
  #3000 Vref=0; RF=1e3; RI=1e3;  // loaded response with Av=-1 down to 0V
  #3000 Vin=-0.3; RF=10e3;       // loaded response with Av=-10 up to 3V
  #3000 Vin=-0.01; RF=100e3;     // loaded response with Av=-100 down to 1V
  #8000 RSW=1e9; Vin=0; RI=10e3; // disconnect cap; set for Av=-10 from Vin
  #3000 repeat(90) #50 Vin-=0.01;   // ramp up to saturation at Vdd=5
  #1000 repeat(140) #50 Vin+=0.01;  // ramp down to saturation at Vss=-1
  #1000 Vin=-0.22; RF=90e3;         // Setup for Av=+10 & 2V offset when Vref=0 
  #3000 Freq=125e3; Vpk=0.2; Phs=0; // begin sinusoidal input check
  assign Vref=Vpk*$sin(2*3.14159265*Phs);        // continuous assign to Vref
  while(Freq<20e6) begin
    repeat(3/(Freq*tinc)) #(tns) Phs+=Freq*tinc; // update phase for 3cycles
    Freq *= 2.0**(1.0/3.0);                      // then increase frequency
  end
  #100 $stop;                   // done with test
end

//Magnitude measurement (output center assumed at 2.0 volts center):
real Vhi,Vlo,Mag,Mnom;
always @(Freq) begin              // start when freq changes
  Vhi=2; Vlo=2;                   // set max&min to center
  while (OUT.V<=2) @(OUT.V) #1;   // skip past low halfcycle
  while (OUT.V>=2) @(OUT.V) #1;   // skip past high halfcycle
  while (OUT.V<=2) @(OUT.V) #1;   // skip past low halfcycle
  while (OUT.V>=2) begin          // For high halfcycle:
    if (OUT.V>Vhi) Vhi=OUT.V;     // save max value
    @(OUT.V) #1;                  // and repeat
  end
  while (OUT.V<=2) begin          // For low halfcycle:
    if (OUT.V<Vlo) Vlo=OUT.V;     // save min value
    @(OUT.V) #1;                  // and repeat
  end
  Mnom = 10/$sqrt(1+(Freq/1e6)**2); // compute expected magnitude
  Mag = (Vhi-Vlo)/2/Vpk;          // compute magnitude wrt Vpk
  $display(">   F=%6.3f MHz    Mag=%5.3f V/V   Mnom=%5.3f V/V", 
                  Freq/1e6,        Mag,             Mnom );
end
 
endmodule
