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

`timescale 1ns/1ps
`define twopi 6.28318530718

module pga_TB;

  import mymath_pkg::*;

  real OUTP,OUTN, INP,INN;         // real outputs and inputs
  logic[2:0] VCVGA;                // gain control bus
  real VB, IBB, VDD, VSS;          // bias inputs
  logic PD;                        // powerdown control

  parameter real vdd_nom=3, ib_nom=50e-6, vb_nom=0.7; // nominal biases
  parameter real vincm=2;            // nominal input and control CM levels
  parameter real vinlo=0.1,vinhi=1;  // small and large signal input swings
  parameter real fin=10.3e6;	     // input frequency (Hz)
  parameter real ts=6, tt=500;       // sample rate and test time (ns)
  real Vin,Fin;	                     // sinusoidal input amplitude and freq
  real Vsup,Vref,Vbval,Ibbval;	     // bias voltage levels
  real VINdif, VINcm;	             // diffl and common mode input signals
  int i, j;

pga  pga (.OUTP, .OUTN, .INP, .INN, .VCVGA, .VB, .IBB, .VDD, .VSS, .PD);  // PGA instance

always #ts VINdif = Vin* $sin(`twopi*Fin*$realtime/1s);  // input waveform
assign INP = VINcm+VINdif/2;         // drive analog real pins with control variables
assign INN = VINcm-VINdif/2;
assign VSS = Vref;
assign VDD = Vsup;
assign VB  = Vbval;
assign IBB = Ibbval;	

initial begin                        // MAIN TEST PROCEDURE
  j = 0;                             // initialize peak detect instrumental variable
  PD=1'b0; VCVGA=3'b000;             // initially powered up in low-gain mode
  Vin=vinlo; Fin=fin; VINcm=vincm;   // initialize to nominal analog levels
  Vsup=vdd_nom; Vref=0; Vbval=vb_nom; Ibbval=ib_nom; 
  #tt Vin=vinhi/4;                   // check with large input signals
  #tt Vin=vinhi/2;
  #tt Vin=vinhi;
  #tt Vin=vinlo;          
  for (i=0; i<8; i=i+1) #tt VCVGA=i;  // ramp control through all settings
  #tt VCVGA=3'b1x0;                   // check invalid control input
  #tt VCVGA=7; Vin=vinhi/4;	      // check with large input signals
  #tt Vin=vinhi/2;
  #tt Vin=vinhi;
  #tt Vsup=0.5*vdd_nom;	              // improper bias checks: 50% supply
  #tt Vsup=vdd_nom;                
  #tt Vbval = 1.5*vb_nom;	       // 150% of proper bias voltage
  #tt Vbval = vb_nom;
  #tt PD=1'b1;                        // powerdown mode
  #tt Ibbval=ib_nom/5;	              // 20% of proper bias current
  #tt PD=1'b0;                        // powerup (current still too low)
  #tt Ibbval=ib_nom;                  // back to valid bias current
  #tt $display("pga_TB: Testing completed at T=%.2fns",$realtime);
  #1 $stop;	                      // done with testing
end

// Gain Measurement Testbench Instrumentation
  real OUTdiff, peak;              // differential output, peak track
  real samples [16];               // array of reals to hold samples for analysis
  real VOUT, measGAIN;             // Output amplitude, measured gain
  real insamples [16]; 
  real rmin[$], rmax[$];
  real INdiff, inpeak;
  real smin[$], smax[$];
  real VINmeas;

// Create differential output tracking value
assign OUTdiff = ((OUTP - OUTN) !== `wrealXState) ? (OUTP - OUTN) : 0.0; 
assign INdiff  = ((INP - INN) !== `wrealXState) ? (INP - INN) : 0.0;

// Monitor differential output, compute pk-pk value
always @ (OUTdiff) begin
   if (j < 16) 
      j++;
   else
      j = 0;

   samples[j] = OUTdiff;
   insamples[j] = INdiff;
   rmax = samples.max();
   rmin = samples.min();
   smax = insamples.max();
   smin = insamples.min();
   peak = rmax[0] - rmin[0];
   inpeak = smax[0] - smin[0];
   VOUT = peak/2;
   VINmeas = inpeak/2;
end

always @ (VOUT)
//   measGAIN = 20*$log10(VOUT/Vin);
   measGAIN = 20*$log10(VOUT/VINmeas);

/*  Properties and Assertions */
real targGain;

always @ (VCVGA) begin
   if (!$isunknown(VCVGA)) begin
      #100; // settling time
      targGain = 3*VCVGA - 1;
      gainCheck: assert ( (measGAIN < (targGain+0.2)) && (measGAIN > (targGain-0.2)) )
        begin
           //$display("%c[1;32m",27);  // Turn text green
           $display("Measured Gain %f matches Target Gain %f.", measGAIN, targGain);
           //$display("%c[0m",27);   // return to default
        end
      else 
        begin
           //$display("%c[1;31m",27); // Turn text red
           $display("Measured Gain %f does not match Target Gain %f.", measGAIN, targGain);
           //$display("%c[0m",27);   // return to default
        end
   end   
end

property maxGain;
   @ (posedge (OUTdiff > 0)) disable iff (Vsup<2.0) (PD == 1'b0) |-> ##[0:$] (VCVGA == 3'b111);
   // when the PGA is enabled, gain will eventually be set to maximum
endproperty

property invalidGain;
   @ (posedge (OUTdiff > 0)) disable iff (Vsup<2.0) (PD == 1'b0) |-> ##[0:$] ($isunknown(VCVGA));
   // when the PGA is enabled, gain will eventually be set to an illegal state
endproperty

maxGainCheck : assert property(maxGain)
    begin
      //$display("%c[1;34m",27); // turn text blue
      $display("PGA gain set to Max.");
      //$display("%c[0m",27);   // return to default
    end

invalidGainCheck : assert property(invalidGain)
   begin
      //$display("%c[1;34m",27); // turn text blue
      $display("Illegal PGA gain setting attempted");
      //$display("%c[0m",27);   // return to default
    end

endmodule
