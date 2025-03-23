// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2017, Cadence Design Systems, Inc. All rights reserved.

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

 // VRsrc is a differential voltage source with series resistance from P to N.
// Inputs vval and rval define the voltage and resistance.
// Output imeas returns value of the current flowing (PtoN) in the source.
// 
// This model reflects the impedance on one side of the block to be seen on the 
// other side, taking into account that its own impedance is incorporated into 
// the impedance values present within the nodes at either end.  The $SIE_input
// constuct is used to measure the effective external network on each side.
//

// Updated: 2017-5-11 (ronv) Using $SIE_input and adding risetime option

`timescale 1ns/1ps
import EE_pkg::*;

// Shorthand for standard real constants:
`define Z `wrealZState
`define X `wrealXState

module Vvar_ideal(P,N,vval,imeas);
inout EEnet P,N;
input real vval;
output real imeas;


parameter real tr=0;          // risetime for analog changes (seconds)
parameter real vtol=1e-6;     // voltage tolerance for iterations.
parameter real itermax=10;    // max iterations at one timepoint.
parameter real Kinc=1e-6;     // fractional change at start of ramp

real Vval,Rval;               // limited versions of vval,rval inputs
EEnet Pext,Next;              // external drive values
real VPdrv,RPdrv,VNdrv,RNdrv; // voltage & resistance output drives
bit newP,newN;                // flag whether to update P & N drivers
real VPo,RPo,VNo,RNo;         // tolerance & iteration limited output drivers
real Imeas;                   // current flowing through this element
real Tdrv=0;                  // time of most recent driver updates
integer Niter=0;              // number iterations at this timepoint
real trt;                     // risetime value in timescale units
real vktol;                   // voltage tolerance dependent on Niter

initial begin  // block starts in "off" mode, effective values are as measured:
  VPdrv=0;
  RPdrv=`Z;
  VNdrv=0;
  RNdrv=`Z;   
  vktol=1e-14;        // voltage tolerance (adjusts with Niter)
  trt=0;              // no risetime at time zero
  #(1step) trt=tr*1s; // risetime converted to timescale
  Rval = 0;
end

// System calls to measure external drive seen at each pin:
reg sie;
initial sie = $SIE_input(P,Pext);
initial sie = $SIE_input(N,Next);

// Update Vval & Rval, including optional risetime and special cases:
always begin
  if (vval<1e12 ) begin       // normal drive
    if (trt>0) begin                                 // if risetime included:
      if (Rval===`Z)       Rval=1e10;                //  leaving high-Z region
      else if (vval!=Vval) Vval += Kinc*(vval-Vval); //  bump V slightly
    end
    if (trt == 0)
       Vval = vval; 
    else
       Vval <= #(trt) vval;      // change to new values after risetime
  end    
  else if ((vval===`Z)) begin  // going to high Z case
    if (trt == 0)
       Vval = 0;
    else
       Vval <= #(trt) 0;                         // V not used when R=Z
  end
  @(vval);
end

always begin      ////////  P->N PROCESSING  ////////
  if (Rval===`Z || Pext.R===`Z) begin  // high-Z drive
    VNdrv <= 0;
    RNdrv <= `Z;
  end
  else begin                           // normal drive
    VNdrv <= Pext.V-Vval;
    RNdrv <= Pext.R+Rval;
  end
  @(Pext.V,Pext.R,Vval,Rval);          // repeat on change to P or input
end

always begin      ////////  N->P PROCESSING  ////////
  if (Rval===`Z || Next.R===`Z) begin  // high-Z drive
    VPdrv <= 0;
    RPdrv <= `Z;
  end
  else begin                           // normal drive
    VPdrv <= Next.V+Vval;
    RPdrv <= Next.R+Rval;
  end
  @(Next.V,Next.R,Vval,Rval);          // repeat on change to N or input
end

always @(VPdrv,RPdrv,VNdrv,RNdrv) begin
  if ($realtime>Tdrv) begin         // if new timepoint
    Tdrv=$realtime;                 //  save time value
    Niter=0;                        //  init counter
    vktol=1e-14;                    //  first iterations update on any change
  end
// Update on R change or nontrivial V change: 
  if (Niter==3) vktol=vtol;  // only update change of >vtol after 3 iterations
  newN = (RNdrv!==RNo || abs(VNdrv-VNo)>vktol); 
  newP = (RPdrv!==RPo || abs(VPdrv-VPo)>vktol);
  Niter++;                           // bump iteration counter
  if (newP|newN) begin               // if any signficant change
    if (Niter<=itermax) begin        // and if within normal iterations
      if (newP) begin
        VPo <= VPdrv;     // update P node driver
        RPo <= RPdrv;
      end
      if (newN) begin
        VNo <= VNdrv;     // update N node driver
        RNo <= RNdrv;
      end                 // Compute measured current flow:
      if (RPdrv+Pext.R>0) Imeas <= (Pext.V-VPdrv)/(Pext.R+RPdrv);
      else                Imeas <= 0;     // this case should never occur!
    end
    else if (Niter==itermax+1) $display(  // message when past iteration limit
       "<EE> ERROR: VRsrc instance %M node%s unconverged at T=%.0fns", 
                 (newP&newN)? "s P&N" : (newP)?" P" : " N",  $realtime);
  end
end

assign P = '{VPo, 0, RPo};      // drive output pins
assign N = '{VNo, 0, RNo};

assign imeas = Imeas;               // return current flow (P to N)

endmodule
