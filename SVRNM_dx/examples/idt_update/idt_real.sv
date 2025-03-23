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
// Time integral of sampled-data input signal
// This format supports iterative updates of the input signal at 
// a timepoint, as can occur when used in a feedback scenario.

`timescale 1ns/1ps


module idt_real import cds_rnm_pkg::*; (
  input wreal1driver IN, 
  output wreal1driver OUT
);

parameter real K=1;  // [1/ns] integration constant
parameter real IC=0; // [V] initial output value at time zero
parameter real maxiter=10; // max iterations at one timepoint

real T0,IN0,V0;      // values at previous timestep
real Tn,INn,Vout;    // values on most recent iteration
int Niter;           // iteration counter

initial begin
  Tn=0; INn=IN; Vout=IC;        // initialize values at time zero
end

always @(IN)                    // on each change of input,
 if (IN<1e20) begin             // (ignore all X, Z, NaN points)
   if ($realtime==0) INn=IN;    // at T=0, just update IN value
   else begin                   // otherwise update output
     if ($realtime>Tn) begin    // if new forward step
       T0=Tn; IN0=INn; V0=Vout; // save previous point
       Niter=0;                 // start iteration counter
     end 
     else Niter++;              // increment iteration counter
     if (Niter<=maxiter)        // limit iterations at a timepoint
       Vout = V0 + (K/2)*(IN+IN0)*($realtime-T0);  // integrate
     INn = IN;                  // save input for this iteration
     Tn = $realtime;
   end
 end

assign OUT = Vout;              // drive output value to net

endmodule

