//--------------------------------------------------------------------------------------
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
//  Stepping Ramp signal source
//
//--------------------------------------------------------------------------------------

`timescale 1ns/1ps
import cds_rnm_pkg::* ; 	// import real nets package

module stepSourceTB ( );
  clock C1 (.dout(clk)) ;
  step S1 (.clk(clk), .aout(aout));
endmodule

module step (
  input logic clk ,
  output wreal1driver aout ) ;
  parameter real offset = 0.0 ;
  parameter real step = 1.2 ;
  real aoutval = offset ;
  always @(posedge clk) begin 
     aoutval = aoutval + step ;
end
assign aout = aoutval ;
endmodule

module clock (output logic dout);
logic dval ;
initial begin
        dval = 1'b0;
        #45 $finish;
    end
  always #5 dval =!dval;
assign dout = dval ;
endmodule

