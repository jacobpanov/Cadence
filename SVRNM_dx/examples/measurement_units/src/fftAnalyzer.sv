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
//--------------------------------------------------------------------------------------
//
// Performs a Fast Fourier Transform on an array of input samples
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1fs

`ifndef M_TWO_PI
`define M_TWO_PI 6.28318530717958647652
`endif

module fftAnalyzer (
   input  real IN
   );

  import fft_pkg::*;

  parameter real sampleFreq = 16e6;   // FFT sample rate
  parameter integer windowSize = 128; // FFT Sample Window
  parameter integer LOG2_WS = 7; // log2 of window size

  integer phMeasCount = 0; // window sample counter
  logic sampleClk = 1'b0;  // sample Clock
  integer i;               // flag indicates FFT ready

  // generate sample clock
  always #(1/(2*sampleFreq)) sampleClk = ~sampleClk;


  // Computation of FFTs
  real  SampleBuffer[0:windowSize-1][1:0];
  real  xFFT[0:windowSize-1][1:0];
  real  xFFTmag[0:windowSize-1], xFFTph[0:windowSize-1];
  integer ii;
  fft_fp #(.LOG2_NS(LOG2_WS),.NS(windowSize)) fft;

  always @ (posedge sampleClk) begin
     SampleBuffer[phMeasCount] = {0.0,IN};
     if (phMeasCount >= (windowSize-1)) begin
        fft.transform(SampleBuffer, xFFT);
        phMeasCount = 0;
        i = 1;
        for (ii=0; ii<windowSize; ii=ii+1) begin
           xFFTmag[ii] = $sqrt(xFFT[ii][1]**2 + xFFT[ii][0]**2)/(windowSize/2); // with normalization
           xFFTph[ii]  = (xFFT[ii][0] != 0) ? $atan2(xFFT[ii][1] , xFFT[ii][0]) : 0.0;
        end
     end
     else begin
        phMeasCount = phMeasCount + 1;
        i = 0;
     end
  end

  initial begin
     phMeasCount = 0;
  end  // initial

endmodule
