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
 A Simple LCR Low Pass Filter - Controlled Canonical(CC) Form State Space Model, in the
 CC form we set the simulation up based on extracting abstract state variabled from the
 transfer function to state space transformation. Note the physical state variable, the
 inductor current and capacitor voltage are in a sense "hidden" in the abstract state
 variables, see the lab write up on how you might relate the physical and abstract state
 variables by a series of matrix row operations. The thing to note is that the A matrix
 for the abstract state variable form ends up looking like this -
  -                         -
  | 0   1   0   0     ....0 |
  | 0   0   1   0     ....0 |
  | .   .   .   .     ....0 |
  | .   .   .   .     ....1 |
  | cn  cn-1  cn-2  . ....ck|
  -                         -
 where ci's are coefficient values as explained in the presentation. On close observation 
 note that this matrix (of dimension n x n) has the form -
 
  [0 I]
  [-c-]
 
 
 where 0  is a null column vector (n-1 x 1)
      -c- is a row of coeficients (1   x n)
       I  is the identify matrix  (n-1 x n-1)
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
   parameter   a00 =   0.00;
   parameter   a01 =   1.00;
   parameter   a10 =  -1.00/(L*C);
   parameter   a11 =  -1.00/(R*C);

   /*B-Matrix*/
   parameter   b00 =   0.00;
   parameter   b01 =   0.00;
   parameter   b10 =   0.00;
   parameter   b11 =   1.00;

   /*inputs*/
   input real Vin;
   output real Vout;

   /*state variable slopes*/
   real        dx1, dx2;

   /*state variables variables*/
   real        x1, x2;

   /*input variables*/
   real        u1, u2;

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
   assign dx1   = a00*x1 + a01*x2 + b00*u1 + b01*u2;
   assign dx2   = a10*x1 + a11*x2 + b10*u1 + b11*u2;

   /*output equation*/
   assign Vout = (1.00/(L*C))*x1;

   /*inout equations*/
   assign u1 = 0.00;
   assign u2 = Vin;

   always begin

      /*update variables, Euler form*/
      x1   = x1   + dt*1.00e-9*dx1;
      x2   = x2   + dt*1.00e-9*dx2;

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

