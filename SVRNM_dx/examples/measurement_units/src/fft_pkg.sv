// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2019, Cadence Design Systems, Inc. (unless otherwise noted)
// All rights reserved.

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
//--------------------------------------------------------------------------------------
//
// Performs a Fast Fourier Transform on an array of input samples
//
//--------------------------------------------------------------------------------------

`timescale 1s / 1fs

`ifndef M_TWO_PI
`define M_TWO_PI 6.28318530717958647652
`endif

package fft_pkg;

function real myAbs(input real in);
  return (in < 0) ? -in : in;
endfunction

function logic mySgn(input real in);
  return (in > 0) ? 1'b1 : 1'b0;
endfunction


class fft_fp #(parameter LOG2_NS = 7, parameter NS = 1<<LOG2_NS);
  //  https://rosettacode.org/wiki/Fast_Fourier_transform#SystemVerilog
  //  Subject to GNU Free Documentation License Version 1.2, November 2002
  //
  // Input and output are complex samples where [0] = real and [1] = imag
  // Implementation of Cooley-Tukey algorithm

function automatic void reverseSampleOrder (
   input real buffer_in[0:NS-1][1:0], output real buffer[0:NS-1][1:0]
   );
  logic [LOG2_NS-1:0] ij;
  for (logic [LOG2_NS:0] j=0; j<NS; j++) begin
    ij = {<<{j[LOG2_NS-1:0]}};
    buffer[j][0] = buffer_in[ij][0];
    buffer[j][1] = buffer_in[ij][1];
  end
endfunction

function automatic void transform(input real buffer_in[$][1:0], output real buffer[$][1:0]);
    real buffer_temp[$][1:0];
    integer inSize = buffer_in.size();
    // buffer_temp = buffer_in;
    reverseSampleOrder(buffer_in, buffer_temp);
    for (int N = 2; N <= inSize; N = N << 1) begin
      for (int i = 0; i < inSize; i = i + N) begin
        for (int k =0; k < N/2; k = k + 1) begin
          int evenIndex;
          int oddIndex;
          real theta;
          real wr, wi;
          real zr, zi;
          evenIndex = i + k;
          oddIndex  = i + k + (N/2);
          theta     = (-`M_TWO_PI*k/real'(N));
          // w = exp(-2j*pi*k/N);
          wr = $cos(theta); 
          wi = $sin(theta);
          // x = w * buffer[oddIndex]
          zr = buffer_temp[oddIndex][0] * wr - buffer_temp[oddIndex][1] * wi;
          zi = buffer_temp[oddIndex][0] * wi + buffer_temp[oddIndex][1] * wr;
          // update oddIndex before evenIndex 
          buffer_temp[ oddIndex][0] = buffer_temp[evenIndex][0] - zr;
          buffer_temp[ oddIndex][1] = buffer_temp[evenIndex][1] - zi;
          // because evenIndex is in the rhs
          buffer_temp[evenIndex][0] = buffer_temp[evenIndex][0] + zr;
          buffer_temp[evenIndex][1] = buffer_temp[evenIndex][1] + zi;
        end
      end
    end
    buffer = buffer_temp;
    return;
endfunction
endclass

endpackage
