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

// Simple definition of differential element with no special cases considered:
// Computes incoming signal at each net assuming it must have finite positive 
//  resistance values, adjusts by vc+rc to drive other side.
// No tolerance control, so this will tend to oscillate due to minor
//  differences (in the 1e-16 range) for external drive value reevaluations.

import EE_pkg::*; 
module VRdiff0 (inout EEnet P,N, input real vc,rc);

 real RPx,VPx,RNx,VNx;               // computed external V & R values 
 real VPdrv,RPdrv,VNdrv,RNdrv;       // output drive values

always @(P.V, P.R, vc, rc) begin     // on change of P net or vc or rc value:
  RPx = P.R*RPdrv/(RPdrv-P.R);       //  compute external R driving P net 
  VPx = P.V + RPx*(P.V-VPdrv)/RPdrv; //  compute external V driving P net 
  VNdrv = VPx-vc;                    //  drive voltage to N side with vc offset
  RNdrv = RPx+rc;                    //  drive resistance to N side adds rc
end

always @(N.V, N.R, vc, rc) begin     // on change of N net or vc or rc value:
  RNx = N.R*RNdrv/(RNdrv-N.R);       //  compute external R driving N net 
  VNx = N.V + RNx*(N.V-VNdrv)/RNdrv; //  compute external V driving N net
  VPdrv = VNx+vc;                    //  drive voltage to P side with vc offset
  RPdrv = RNx+rc;                    //  drive resistance to P side adds rc
end

assign N = '{VNdrv,0,RNdrv};   // apply drive to nets
assign P = '{VPdrv,0,RPdrv};

endmodule

