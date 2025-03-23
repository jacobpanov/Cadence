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

// Testbench to demonstrate Tsum UDN example

`timescale 1ns/1ps
import Tsum_pkg::*;

module top;
  wTsum w;
  drv1 a1(w);
  drv2 a2(w);
  drv3 a3(w);
  rcvr rx(w);
  initial #10 $stop;
endmodule

module drv1 (output wTsum d1);
  assign d1 = T'{1.0, 0.5, 2};
endmodule

module drv2 (output wTsum d2);
  assign #2 d2 = T'{1.6, 3.0, 5};
endmodule

module drv3 (output wTsum d3);
  assign #5 d3 = T'{1.4,`wrealXState,4};
endmodule

module rcvr (input wTsum din);
  always @(din.A,din.B,din.N)
   $display("Time=%.1f  Val=%p", 
               $realtime, din);
endmodule




