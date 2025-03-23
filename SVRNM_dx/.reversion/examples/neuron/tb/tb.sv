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
//
// Testbench for Mixed Signal Neuron Model
//    A random weight vector is generated at the start of the simulation.
//    A random input vector is generated every clock cycle. Since it is 
//    generated bit by bit, it will generally be close to 50% 1's.
//    The value prodXOR represents the ideal output, non-normalized.
//    iuAvg is the moving average of VDD current, in uA. Since VDD is
//    1 V, this is also power in uW.
//
// --------------------------------------------------------------

`timescale 1s / 1fs 
import EE_pkg::*;

module tb ();

parameter real clkFreq = 50e6;

class c_inputX;
   rand bit singleX;
endclass

EEnet vdd, vss;
c_inputX inputX=new;
integer i;
integer inputNum, weightNum;

// w's are the weights. They update during training, after that are fixed
// x's are the input patterns to be trained on or recognized

logic [1023:0] x, w;
logic clk = 1'b0;
logic clkp, clkn, en;
logic out;

real product;
integer prodXOR;

// Generate the clock
always # (1/(2*clkFreq)*1s) clk = (en == 1'b1) ? ~clk : 1'b0;

assign clkp = clk;
assign clkn = !clk;

assign vdd = '{1.0, 0, 0};
assign vss = '{0, 0, 0};

assign inputNum = $countones(x) - 512;
assign weightNum = $countones(w) - 512;
assign product = (inputNum/512.0) * (weightNum/512.0);
assign prodXOR = $countones(~(x ^ w)) - 512;


initial begin
   //initialize inputs to 0
   x = '{1024{0}};
   en = 1'b0;

   // initialize weights randomly
   for (i=0;i<1024;i=i+1) begin
      if (inputX.randomize())
         w[i] = inputX.singleX;
   end

   fork
      #(1us) en = 1'b1;
      #(11us) en = 1'b0;
      #(12us) ;
   join
   $stop;
end

always @ (posedge clkp) begin // update x's and maybe w's on positive clk edges,
                      // xORs and xNORs are clocked on negedge, 
                      // comparator latches on posedge
   for (i=0;i<1024;i=i+1) begin
      if (inputX.randomize())
         x[i] = inputX.singleX;
   end
end

msNeuron u_msNeuron (
  .out (out), 
  .vdd (vdd), 
  .vss (vss), 
  .clkn (clkn), 
  .clkp (clkp), 
  .en (en), 
  .w (w), 
  .x (x)
);

// Calculate the average current drain
// Rectangular Window Function for simple averaging
real windowFunction [15:0] = {1.0/16, 1.0/16, 1.0/16, 1.0/16, 
                              1.0/16, 1.0/16, 1.0/16, 1.0/16, 
                              1.0/16, 1.0/16, 1.0/16, 1.0/16, 
                              1.0/16, 1.0/16, 1.0/16, 1.0/16};
// Trapezoidal Window Function weights middle values more.
// real windowFunction [15:0] = {0.25/13, 0.5/13, 0.75/13, 1.0/13, 
//                               1.0/13, 1.0/13, 1.0/13, 1.0/13, 
//                               1.0/13, 1.0/13, 1.0/13, 1.0/13,
//                               1.0/13, 0.75/13, 0.5/13, 0.25/13};
real thisSample;
real lastSample;
real lastTime;
real sampleIn;
real iuAvg;
real iSamples [15:0];
integer j=0, k;
// accumulate samples of current at changes
always @ (vdd.I) begin
   thisSample += lastSample*($realtime-lastTime) ; // scale the sample by the time since the last sample
   lastSample = -vdd.I;
   lastTime = $realtime;
end

// periodically average in the accumulated samples
// choose a period that is not commensurate with the clock
always #(24ns) begin
   iuAvg = 0.0;
   thisSample += lastSample*($realtime-lastTime) ; // include any input since last input change
   sampleIn = (thisSample)/24e-9; // scale to 24 nsec
   iSamples[j]  +=   sampleIn - iSamples[j]; // Add new sample, subtract old one
   foreach (iSamples[k]) begin
      iuAvg = (iuAvg+iSamples[(k+j)%16]*windowFunction[k]);
   end
   j = (j+1)%16; // j sequences through 0 to 15 and repeats
   iuAvg = 1e6*iuAvg; // scale to uAmps
   thisSample = 0.0; // clear the accumulator
   lastTime = $realtime; // reset the timestamp
end



endmodule
