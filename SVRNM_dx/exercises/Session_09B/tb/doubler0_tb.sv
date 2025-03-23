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

module top import EE_pkg::*; ();

  real Vdd,Rin,Rload,Vaout;
  wire CK;
  EEnet FINa,FOUTa,FINb,FOUTb,FINc,FOUTc,CIN,COUT;

  // STIMULUS FILE:
  doubler_stim  STIM (.CK, .Vdd, .Rin, .Rload );
  // Header to go with the table generated below:
  initial #0.1 $display(
   ">  Per  cken  Rload   Rin   ANALOG  EE@30n  EE@60n  EE@90n  CYCAVG   Time");
  // Print setup info and results right after measurment event from stimulus file:
  always @(STIM.Meas) #0.1 $display(
   "> %4.0fns  %d  %6.1fK %4.1f   %6.4f  %6.4f  %6.4f  %6.4f  %6.4f  %7.2fus",
      STIM.Per, STIM.cken, Rload/1e3, Rin, Vaout, 
        FOUTa.V, FOUTb.V, FOUTc.V, COUT.V, $realtime/1e3);


  // ANALOG ELECTRICAL VERSION (VerilogAMS):
  EVIRsrcG AVI (.P(AIN),  .vval(Vdd), .rval(Rin));
  EVIRsrcG ARL (.P(AOUT), .vval(0.0), .rval(Rload));
  doubler_full ADUT ( .OUT(AOUT), .IN(AIN), .CK );

  bit ckm;  // measurement clock: generate event on any output change
  always @(FOUTa.V,FOUTb.V,FOUTc.V,COUT.V) ckm <= !ckm;  
  EVmeas AVM  (.Ain(AOUT), .CK(ckm), .Vmeas(Vaout)); // measure analog output


  // FULL EENET VERSION, 3 CHOICES OF SAMPLE PERIOD:
  VIRsrcG FVIa (.P(FINa),  .vval(Vdd), .rval(Rin), .ival(0.0));
  VIRsrcG FRLa (.P(FOUTa), .vval(0.0), .rval(Rload), .ival(0.0));
  doubler0_full #(.Ts(30e-9)) FDUTa ( .OUT(FOUTa), .IN(FINa), .CK );

  VIRsrcG FVIb (.P(FINb),  .vval(Vdd), .rval(Rin), .ival(0.0));
  VIRsrcG FRLb (.P(FOUTb), .vval(0.0), .rval(Rload), .ival(0.0));
  doubler0_full #(.Ts(60e-9)) FDUTb ( .OUT(FOUTb), .IN(FINb), .CK );

  VIRsrcG FVIc (.P(FINc),  .vval(Vdd), .rval(Rin), .ival(0.0));
  VIRsrcG FRLc (.P(FOUTc), .vval(0.0), .rval(Rload), .ival(0.0));
  doubler0_full #(.Ts(90e-9)) FDUTc ( .OUT(FOUTc), .IN(FINc), .CK );

  // CYCLE-AVERAGED EENET VERSION:
  VIRsrcG CVI (.P(CIN),  .vval(Vdd), .rval(Rin), .ival(0.0));
  VIRsrcG CRL (.P(COUT), .vval(0.0), .rval(Rload), .ival(0.0));
  doubler0e #(.Ts(500e-9)) CDUT ( .OUT(COUT), .IN(CIN), .CK );

endmodule
