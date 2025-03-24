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


// --------------------------------------------------------------
//
//  ADC Model for Exercise
//
// --------------------------------------------------------------

`timescale 1ns/1ps

module adc import cds_rnm_pkg::*; 
  #( int Nbits=8 )                    // output bus width inline declaration
 (		
  output logic signed [Nbits-1:0] DOUT,  
  input wreal1driver AIN,REFH,REFL,
  input logic CK
 );
  parameter real Td=5;			// delay from ck to output (ns)
  real PerBit;     
  bit CKint;

  always_comb                  		// get dV per bit wrt supply
    PerBit = (REFH-REFL)/((1<<(Nbits-1))-1);

  always @(CK) 				// 1,0 passed, X,Z ignored
    if (CK|!CK) CKint=CK;

  always @(posedge CKint)  		// update output on valid posedge
    DOUT <= #(Td) (AIN<REFL)? -((1<<(Nbits-1))) : 
            (AIN>REFH)? ((1<<(Nbits-1))-1) : ((AIN-REFL)/PerBit);

endmodule 

