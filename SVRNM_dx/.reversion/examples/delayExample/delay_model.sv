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

`timescale 1ns/10ps 

module delay_model (
input logic in,
output wire yinertial, reg yblocking, ytransport 
) ;

//Stimulus
reg a ;  assign in = a;
initial begin //Test Pattern
     a = 0 ;
     #2 a = 1 ;
     #8 a = 0 ;
     #8 a = 1 ;
     #2 a = 0 ;
     #8 a = 1 ;
     #2 a = 0 ;
     #2 a = 1 ;
     #8 a = 0 ;
     #2 a = 1 ;
     #2 a = 0 ;
     #2 a = 1 ;
     #8 $finish ;    
end

//Inertial Delay
assign #5 yinertial = in ;

// Behaviour of Blocking and Transport delays
   always @(in) begin
        ytransport <= #5 in;
   end

   always @(in) begin 
      #5 yblocking = in;
   end

endmodule

