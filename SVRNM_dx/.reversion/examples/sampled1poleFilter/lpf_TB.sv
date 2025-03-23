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

`timescale 1ns/1ps
`define twopi 6.28318530718

module lpf_TB ( );

real OUT; real IN, Fin, Vdc, Vpk, Phs=0;
logic [3:0] poleTrim, gainTrim;

lpf #(.Ts(10)) LPF(OUT,IN, poleTrim, gainTrim);	    // filter Instance to be tested

initial begin                                       // test procedure 
  poleTrim=4'h9; gainTrim=4'hF;                     // single pole at 5MHz, unity (max) gain
  Fin=1e6;Vdc=0;Vpk=1;	                            // 1MHz input signal
  #2000                                             // run for 2 cycles
  Fin=5e6;   #1200                                  // Fin matches poleTrim (expect 0.7 out)
  gainTrim=4'h8;   #1200                            // mid gain
  gainTrim=4'h1;   #1200                            // lower gain
  gainTrim=4'hB;   #1200                            // higher gain
  Vdc=1;    #2400                                   // DC shift of input signal
  Vdc=0;    #2400                                   // back to zero DC level
  Fin=10e6; #1200                                   // now at 2*poleTrim (>0.35 out)
  gainTrim=4'hF;  #1200                             // max gain
  Fin=16e6;  #1200                                  // now at 1.6*poleTrim (0.26 out)
  poleTrim=4'hF;   #1200                            // change poleTrim=Fin/2 (0.35 out)
  poleTrim=4'h3;                                    // change poleTrim to 3
  Fin=1e6;   #2000	                            // down to 1MHz input 

  while (Fin<100e6) begin 
    #(1e9/Fin) Fin = (Fin*1.08) ;                   // slow freq ramp
  end
  #200 $finish ;                                    // done with simulation
end

// Sine Input generation
always begin	// Generate sinusoidal input signal
  IN = Vdc + Vpk * $sin(`twopi*Phs);	// compute new value
  #10 Phs = Phs+10*Fin/1e9;	  // update phase after time delay
  if (Phs>=1) Phs = Phs-1; // keep phase in range 0 to 1
end

// Measuring output peak magnitude 
real vhi,vlo, Vpk_out; reg up=0;	// variables for peak detector

always @(OUT) begin	// Measure peak (vhi-vlo)/2 each cycle:
  if (OUT<Vdc) begin	// if input is low
    if (up) begin // if it was high, it just crossed
      Vpk_out=(vhi-vlo)/2;  // compute peak difference
      up=0; vlo=OUT; // put in low state & reset min value
    end
    if (OUT<vlo) vlo=OUT;  // save low peak
  end

  else begin // else input is high
    if (!up) begin	// if it was low, it just crossed
      Vpk_out=(vhi-vlo)/2;  // compute peak difference
      up=1; vhi=OUT;	// put in high state & reset max value
    end
    if (OUT>vhi) vhi=OUT;  // save high peak
  end
end

endmodule
