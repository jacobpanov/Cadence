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

`timescale 1ns / 100ps


//****** TOP TESTBENCH ****************

module table_model_TB () ;
import cds_rnm_pkg::*;

wreal1driver a, y ;

inv_table I1 (a, y ) ;    // INSTANTIATION OF INVERTER TABLE MODULE
step V1 (clk, a );        // INSTANTIATION OF STEP SOURCE MODULE AS INPUT 
clk C1 (clk);             // INSTANTIATION OF CLOCK GENERATOR FOR STEP SOURCE 

initial 
    #2500 $finish ;        // SIMULATION TIME 
    
endmodule



// ***** STEP SOURCE MODULE ************

module step import cds_rnm_pkg::*; (clk, x );
input logic clk;
output wreal1driver x;  

parameter real offset=0.0;
parameter real step=0.01;

real  xval;

initial 
	xval=offset;

always @(posedge clk) begin
	xval = xval + step  ;	
end

assign x = xval;
endmodule


//******* CLOCK GENERATOR MODULE *********

module clk(clk);
output clk;
logic clk;

 initial clk=0;

 always #10 clk = ~clk;

endmodule

