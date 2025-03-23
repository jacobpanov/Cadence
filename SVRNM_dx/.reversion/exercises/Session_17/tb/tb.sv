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
// Test bench for TIA
//
//---------------------------------------------------------------

`timescale 1s/1ps

module tb import cds_rnm_pkg::*; import EE_pkg::*; ( );

  logic enable;
  real ampl, vcoFreq;
  EEnet drive, out;
  EEnet vdd, vss;
  real Vvdd, Vvss, vBias1, vBias2;
  wreal1driver vbias1, vbias2;
  logic [3:0] gain;

  vco_sine sine_iSource (.vin (vcoFreq), .out (drive), .ampl (ampl));

  TIA TIA (
    .vdd (vdd),
    .vss (vss),
    .vbias1 (vbias1),
    .vbias2 (vbias2),
    .in (drive),
    .out (out),
    .gain (gain),
    .en (enable)
  );

  assign vdd = '{Vvdd, 0, 0};
  assign vss = '{Vvss, 0, 0};
  assign vbias1 = vBias1;
  assign vbias2 = vBias2;

  initial begin
     Vvss = 0.01;
     Vvdd = 0.0;
     ampl = 0.0;
     vcoFreq = 0.75;
     enable = 1'b0;
     gain = 4'b0000;
     vBias1 = 0.0;
     vBias2 = 0.0;

     fork
        #(10e-6) begin
           Vvss = 0.0;
           Vvdd = 1.5;
        end
           
        #(20e-6) begin
           vBias1 = 0.25*Vvdd;
           vBias2 = 0.75*Vvdd;
        end

        #(25e-6) begin
           enable = 1'b1;
           gain = 4'b0001;
        end

        #(40e-6) ampl = 5.0;

        #(100e-6) gain = 4'b0011;
        #(150e-6) gain = 4'b0111;
        #(200e-6) gain = 4'b1111;
        #(250e-6) gain = 4'b0000;
        #(300e-6) gain = 4'b0001;
        #(305e-6) gain = 4'b0010;
        #(310e-6) gain = 4'b0100;
        #(315e-6) gain = 4'b1000;
        #(320e-6) vBias1 = 0.35*Vvdd;
        #(340e-6) vBias1 = 0.15*Vvdd;
        #(350e-6) vBias1 = 0.25*Vvdd;
        #(360e-6) vBias2 = 0.85*Vvdd;
        #(380e-6) vBias2 = 0.65*Vvdd;
        #(400e-6) vBias2 = 0.75*Vvdd;
        #(420e-6) Vvdd = 1.9;
        #(440e-6) Vvdd = 0.9;
        #(450e-6) Vvdd = 1.1;
        #(460e-6) vBias1 = 0.25*Vvdd;
        #(460e-6) vBias2 = 0.75*Vvdd;
        #(500e-6) for (int i=0;i<10;i++) 
                  begin 
                     vcoFreq = vcoFreq + 0.1;
                     #(10e-6);
                  end
      
     join

     #100e-6 $finish;
  end

  real Zmeas; 
  real Isamples [32];
  real Vsamples [32];
  real rmin[$], rmax[$];
  real smin[$], smax[$];
  real Vpeak, Ipeak;
  int j;

  always @ (drive.V or drive.R) begin
     if (j < 32) 
       j++;
     else
       j = 0;

     Isamples[j] = drive.V/drive.R;
     Vsamples[j] = out.V;
     rmax = Isamples.max();
     rmin = Isamples.min();
     smax = Vsamples.max();
     smin = Vsamples.min();
     Ipeak = rmax[0] - rmin[0];
     Vpeak = smax[0] - smin[0];
  end

  always @ (Ipeak) begin     
     Zmeas = Vpeak / Ipeak;
  end

  
endmodule
