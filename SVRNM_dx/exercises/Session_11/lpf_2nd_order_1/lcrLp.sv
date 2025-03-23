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

/*
 --------------------------------------------------------------
 A Simple LCR Low Pass Filter - Direct Form State Space Model, in the 
 direct form we set the simulation up to directly address the physical 
 state variables, which are the inductor current(Il) and the voltage 
 across the capacitor (Vout)
 --------------------------------------------------------------
 */

module lcrLp(Vin, Vout);
   
   /*damping ratio for L=100nh, C=10uf*/
`ifdef UD
   parameter real dr = 0.05;   /*Under damped       - damping ratio < 1.00*/  
`endif

`ifdef CD   
   parameter real dr = 1.00;   /*Critically damped  - damping ratio = 1*/
`endif

`ifdef OD
   parameter real dr = 2.5;   /*Over damped        - damping ratio > 1.00*/
`endif
   
   parameter real R  = 0.05/dr;     /*a resistor based on the damping required*/
   parameter real L  = 100.00e-9;   /*a 100 nH inductor*/
   parameter real C  = 10.00e-6;    /*a 10uF capacitor*/


   /*A-Matrix*/
   parameter   a00 =  -1.00/(R*C);
   parameter   a01 =   1.00/C;
   parameter   a10 =  -1.00/L;
   parameter   a11 =   0.00;

   /*B-Matrix*/
   parameter   b00 =   0.00;
   parameter   b01 =   0.00;
   parameter   b10 =   1.00/L;
   parameter   b11 =   0.00;

   /*inputs*/  
   input real Vin;
   output real Vout;

   /*state variable slopes*/
   real        dIl, dVout;

   /*state variables, Vout is declared as a port variable*/
   real        Il;

   /*time step, these are computed from the smallest poles of the system
   
    The smallest poles are -
    Underdamped       - 159154.6  Hz => Tau = 6.9us
    Critically damped - 159154.9  Hz => Tau = 6.9us
    Overdamped        - 762567.14 Hz => Tau = 1.32us
    To cover all three cases choose dt to be 10ns
    
    */
    
   real        dt;
   
   /*Forward Euler implementation of simuation loop*/
   assign dt = 10.00;

   /*equations for differential state vectors*/
   assign dVout = a00*Vout + a01*Il;  
   assign dIl   = a10*Vout + a11*Il + b10*Vin;

 
   always begin
      
      /*update variables*/
      Vout = Vout + dt*1.00e-9*dVout;
      Il   = Il   + dt*1.00e-9*dIl;     
      
      #dt;
      
   end // always @ (*)
  
endmodule // lcrLp


/*associated tb*/
module step(Vs);

   output real Vs;
   
   initial begin
      #500_00 Vs = 1.00;
      #1_000_000 $finish;
   end
   
endmodule // step




module tb;

   real x, y;

   /*step generator*/
   step step (x);
   
   /*lcr filter*/
   lcrLp lcrLp(x, y);

   
endmodule // tb

