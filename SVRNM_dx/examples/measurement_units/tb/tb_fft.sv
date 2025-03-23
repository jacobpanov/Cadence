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
// Testbench for fft analyzer example
//
//--------------------------------------------------------------------------------------


`timescale 1s/1ps

`define SAMPLE_RATE 100e-9
`define SAMPLE_RATE_NS `SAMPLE_RATE*1e9
`define SOURCE_FREQ 600e3
`define AMPLITUDE 3.0

module tb ();
import cds_rnm_pkg::*; 

wreal4state signal;
wreal4state filtSignal;
integer count = 0;
integer ofile, ofile1;

sine_src #(.Freq (`SOURCE_FREQ), .ampl (`AMPLITUDE), .sampleRate (25*`SOURCE_FREQ)) u_Source (signal);

SRfilt #(.Fc (10e6), .SR (5e6), .Ts (`SAMPLE_RATE_NS)) u_Filt (filtSignal, signal);

fftAnalyzer #(.sampleFreq (25*`SOURCE_FREQ)) u_fftAnalyzer0 (signal);

fftAnalyzer #(.sampleFreq (25*`SOURCE_FREQ)) u_fftAnalyzer1 (filtSignal);

initial begin
   #(200e-6)
   $finish;
end

always @ (posedge u_fftAnalyzer0.i) begin
   count++;
   if (count == 12)  begin  // Grab one frame of FFT, arbitrarily #12
      // Generate Frequency Axis
      real freqPoints[0:127];
      foreach (freqPoints[i]) freqPoints[i] = i*(25*`SOURCE_FREQ)/128;
      ofile = $fopen("fft0.txt","w");
      foreach(u_fftAnalyzer0.xFFTmag[i]) 
         $fwrite(ofile,"%f   %f \n",freqPoints[i],u_fftAnalyzer0.xFFTmag[i]);
      $fwrite(ofile, "\n");
      $display("FFT0 data written to fft0.txt \n");
      $fclose(ofile);
      ofile1 = $fopen("fft1.txt","w");
      foreach(u_fftAnalyzer1.xFFTmag[i]) 
         $fwrite(ofile1,"%f   %f \n",freqPoints[i],u_fftAnalyzer1.xFFTmag[i]);
      $fwrite(ofile1, "\n");
      $display("FFT1 data written to fft1.txt \n");
      $fclose(ofile1);
   end
end


endmodule
