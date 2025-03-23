// --- Begin Copyright Block -----[ do not move or remove ]------
//Copyright (c) 2020, Cadence Design Systems, Inc. All rights reserved.

/*************************************************************************************************************
The model contained herein is the proprietary and confidential information of Cadence, 
and is supplied subject to, and may be used only by Cadence's customer in accordance with 
a previously executed license and maintenance agreement between Cadence and that customer. 
This model is intended for use with products only from Cadence Design Systems, Inc.  
The use or sharing of any models from this library or any of its modified/extended form 
is strictly prohibited with any non-Cadence products.  

ALL MATERIALS FURNISHED BY CADENCE HEREUNDER ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
AND CADENCE SPECIFICALLY DISCLAIMS ANY WARRANTY OF NONINFRINGEMENT, FITNESS FOR A PARTICULAR 
PURPOSE OR MERCHANTABILITY. CADENCE SHALL NOT BE LIABLE FOR ANY COSTS OF PROCUREMENT OF SUBSTITUTES,
LOSS OF PROFITS, INTERRUPTION OF BUSINESS, OR FOR ANY OTHER SPECIAL, CONSEQUENTIAL OR INCIDENTAL DAMAGES,
HOWEVER CAUSED, WHETHER FOR BREACH OF WARRANTY, CONTRACT, TORT, NEGLIGENCE, STRICT LIABILITY OR OTHERWISE.
***************************************************************************************************************/
//  A SystemVerilog model using a $table_model function

`timescale 1ns / 100ps     


module inv_table import cds_rnm_pkg::*; ( a, y );
output wreal1driver y;  // OUTPUT IS WREAL
input wreal1driver a;   // INPUT IS WREAL

parameter real td=0.5e-9;  // INVERTER PROPAGATION DELAY IN SECONDS <=== PICK NON-ZERO VALUE <===
parameter FILENAME = "table2d.dat" ;   // DATA FILE CONTAINING THE TABLE MODEL DATA. 
 
real y_reg;                      // INTERNAL VARIABLES 
real delay_ns= td*1s;    // <=== DELAY IN NANOSECONDS <===

initial begin
y_reg = $table_model(a, FILENAME , "I, 1LL" );  //CALLING THE TABLE MODEL FUNCTION AT THE INITIAL STEP
//                                  I - ignore the index column
//                                  1LL - linear interpolation, linear extrapolation from top and bottom
end

always @(a) begin
#delay_ns y_reg = $table_model(a, FILENAME , "I, 1LL" );  //CALL THE TABLE MODEL FUNCTION 
end

assign y = y_reg;     //ASSIGNING THE OUTPUT OF TABLE MODEL FUNCTION TO OUTPUT

endmodule
