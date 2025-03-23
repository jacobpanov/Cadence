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

// Simple definition of differential element with tolerance limiting:
// Computes incoming signal at each net assuming it must be finite positive 
//  resistance values, adjusts by vc+rc to drive other side.
// Includes tolerance control to stop iterating when measured external change
//  becomes sufficently small.
// But still no handling of special cases (R=0,R=Z,V=X), and no iteration limit
//  (nonconvergence can result in infinite iterations).

import EE_pkg::*; 
module VRdiff1 (inout EEnet P,N, input real vc,rc);
parameter real vtol=1e-6;
parameter real rtol=0.1;

 real RPn,VPn,RNn,VNn;               // computed external V & R values
 real RPx,VPx,RNx,VNx;               // external V & R to use (after tol check)
 real VPdrv,RPdrv,VNdrv,RNdrv;       // output drive values

always @(P.V,P.R) begin              // On change of P net:
  RPn = P.R*RPdrv/(RPdrv-P.R);       //  compute external R driving P net 
  VPn = P.V + RPn*(P.V-VPdrv)/RPdrv; //  compute external V driving P net 
  if (abs(VPn-VPx)>vtol || 
       abs(RPn-RPx)>rtol) begin      // if sufficient change,
    VPx = VPn;                       //  update external drive values
    RPx = RPn;
  end
end

always @(N.V,N.R) begin              // On change of N net:
  RNn = N.R*RNdrv/(RNdrv-N.R);       //  compute external R driving N net 
  VNn = N.V + RNn*(N.V-VNdrv)/RNdrv; //  compute external V driving N net
  if (abs(VNn-VNx)>vtol ||
       abs(RNn-RNx)>rtol) begin      // if sufficient change,
    VNx = VNn;                       //  update external drive values
    RNx = RNn;
  end
end

always_comb begin               // On change of any drive coefficients:
  VNdrv = VPx-vc;               //  drive voltage to N side with vc offset
  RNdrv = RPx+rc;               //  drive resistance to N side with rc
  VPdrv = VNx+vc;               //  drive voltage to P side with vc offset
  RPdrv = RNx+rc;               //  drive resistance to P side with rc
end

assign N = '{VNdrv,0,RNdrv};    // apply computed drive to nets
assign P = '{VPdrv,0,RPdrv};

endmodule

