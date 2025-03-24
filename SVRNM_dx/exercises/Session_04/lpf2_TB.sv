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

//Programmable Second Order Filter Testbench

`timescale 1ns/1ps
`define twopi 6.28318530718

module lpf2_TB ( );

real IN,OUT;       // filter input & output
real Av;           // coefs passed to filter
logic [3:0] Trim;  // Filter trim control
real Fin,Vdc,Vpk;  // controls for input signal
real Phs=0;        // phase for sine generator
parameter real Ts=7;       // fixed timestep size (ns)
real idealH_f;     // Calculate ideal freq response

 // INSTANTIATE THE FILTER TO BE TESTED
lpf2 #(.Ts (Ts*1e-9), .fpole0 (3e6), .fpole1 (5e6), .trimStep (250e3)) lpf2 (OUT, IN, Trim, Av);

// Sine Input Generation
always begin
  IN = Vdc + Vpk*$sin(`twopi*Phs);  // compute input from levels & phase
  #Ts Phs = Phs+Ts*Fin/1e9;       // update phase after delay
  if (Phs>=1) Phs -= 1;           // keep phase in range 0 to 1
  idealH_f = Av / $sqrt( ((1 + (Fin/3e6)**2)) * ((1 + (Fin/5e6)**2)) );

end


// Test Procedure
initial begin         // test procedure
  Trim=4'h7; Av=1;   // Trim at mid, unity gain
  Fin=1e6;Vdc=0;Vpk=1;// 1MHz input signal
  #2000               // Run for 2 cycles
  Fin=5e6;  #1200      // Fin matches Fp (expect 0.5 out)
  Av=3;     #1200      // Higher gain
  Av=0.2;   #1200      // Lower gain
  Av=1;     #1200      // Back to unity gain
  Vdc=1;    #4000      // DC shift of input signal
  Trim = 4'hF; #2000   // Trim to Max
  Vdc=0;    #1200      // back to zero DC level
  
  // Sweep the value of Trim from max (15) to min (0)
  // hold at each value for 600ns

  for (int i = 15; i >= 0; i = i - 1) begin
    Trim = i;
    #600;
  end

  #600;
  Trim = 4'h7;        // back to middle
  Fin=3e6; #1500      // now at fpole1
  Fin=5e6; #1500      // now at fpole2
  Trim = 4'h0;  #1500     // 
  Trim = 4'hF;  #1500     // 
  Trim = 4'h8; 
  Fin=1e5;  #2000     // Down to 100kHz input and center trim
  while (Fin<30e6) #(1e9/Fin) Fin=Fin*1.08; // slow freq ramp
  #200 $stop;         // done with simulation
end


// Measuring output peak magnitude 

real vhi,vlo;      // peak detector low/high measured
real Vpk_out;      // output of detector = (vhi-vlo)/2
reg up=0;          // state of detector
real measGain;


// PEAK DETECTOR: Compute (vhi-vlo)/2 for each cycle of output:
always @(OUT) begin
  if (OUT<Vdc) begin   // if input is low
    if (up) begin      // if it was high, it just crossed
      Vpk_out=(vhi-vlo)/2;  // compute peak difference
      vlo=OUT;         // reset min value
      up=0;            // put in low state
    end
    if (OUT<vlo) vlo=OUT;  // save low peak
  end
  else begin           // else input is high
    if (!up) begin     // if it was low, it just crossed
      Vpk_out=(vhi-vlo)/2;  // compute peak difference
      vhi=OUT;         // reset max value
      up=1;            // put in hgh state
    end
    if (OUT>vhi) vhi=OUT;  // save high peak
  end
end

// Compute the Gain
always @(Vpk_out) begin
  if (Vpk_out > 0.0)
     measGain = 20 * $log10(Vpk_out/Vpk);
  else
     measGain = -100.0;
end


 
endmodule
