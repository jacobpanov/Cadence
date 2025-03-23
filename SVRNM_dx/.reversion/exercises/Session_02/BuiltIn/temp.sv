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

// built-in-nettype-example.sv
import cds_rnm_pkg::*;
nettype  wrealsum  realnet; //Renaming and declaring Built-in nettype wrealsum as realnet

module top;
  realnet w;
  
  driver1 d1(w);
  driver2 d2(w);
  receiver1 r1(w);
endmodule

module receiver1(input realnet rec_1); 
   always @(rec_1)
     $display($time , ," sum = %f", rec_1);
endmodule

module driver1(output realnet dr_1);
  real r;
  assign dr_1 = r;
  initial begin
    r = 2.2;
    #20 r = `wrealZState;
  end
endmodule

module driver2 (output realnet dr_2);
  real r;
  assign dr_2 = r;
  initial begin    
    r = `wrealZState;
    #10 r = 1.1;
  end
endmodule


