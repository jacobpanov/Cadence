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
import EE_pkg::*;

`ifndef TMIN
`define TMIN 1e-9
`endif

`ifndef TMAX
`define TMAX 10e-6
`endif

module top ();

real Vdd,Rin,Rload;
wire CK;
EEnet FIN,FOUT;

// STIMULUS FILE:
doubler_stim  STIM (.CK, .Vdd, .Rin, .Rload );

// FULL EENET VERSION:
VIRsrcG FVI (.P(FIN),  .vval(Vdd), .rval(Rin), .ival(0.0));
VIRsrcG FRL (.P(FOUT), .vval(0.0), .rval(Rload), .ival(0.0));
doubler_Cap_x #(.Tmin(`TMIN), .Tmax(`TMAX)) FDUT ( .OUT(FOUT), .IN(FIN), .CK );

endmodule
