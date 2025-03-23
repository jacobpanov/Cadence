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
//  Shell for demonstrating VAMS sub-module
//--------------------------------------------------------------------------------------


`timescale 1ns/1ps

module resDemo import cds_rnm_pkg::*; import EE_pkg::*; ( 
  inout PLUS, 
  inout MINUS, 
  output EEnet VOUT, 
  output wreal4state iRes
  );

  //Internal Signals
  real rVal;
  real Pres;
  real Nres;

  initial begin
    rVal = 100;
    #5us rVal = 500;
    #5us rVal = 2000;
  end

  assign  VOUT = '{(Pres-Nres),0.0,rVal};

  resVAMS #(.Tsample(5)) resVAMS (PLUS, MINUS, iRes, Pres, Nres, rVal);

endmodule

