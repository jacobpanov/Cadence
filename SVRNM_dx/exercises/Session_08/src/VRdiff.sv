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

// VRdiff.sv - EEnet differential V+R model for use between two EEnet nodes

// This module connects a resistor and voltage source in series between
// two EEnet nodes.  Nets are driven and the external drive to them is
// computed using the EEIO module (one for each node), which also performs 
// tolerance and iteration limiting so that only significant external
// changes will be passed into this module.

// Given those operations, this module's computation is very simple:
// it measures the external drive on one side, adds the specified voltage
// and resistance to that measurement, and drives the resulting value to 
// the other side.  If external drive is Z, or vc or rc are Z, the resulting
// drive to the other side will also be Z (since arithmetic functions of Z
// always return a Z).  Ideal current drive to one side will directly flow 
// through to the other side.


import EE_pkg::*; 

module VRdiff (inout EEnet P,N, input real vc,rc);

parameter real vtol=1e-5;     // output voltage update tolerance
parameter real itol=1e-9;     // output current update tolerance
parameter real itermax=20;    // max iterations at one timepoint

EEstruct Pdrv,Pext,Ndrv,Next; // structures for passing drive values 

EEIO  #(.vtol(vtol), .itol(itol), .itermax(itermax))
   DP(P, Pdrv, Pext), DN(N, Ndrv, Next);   // Drive & measure P & N nets

assign Ndrv = '{Pext.V-vc, Pext.I, Pext.R+rc};  // compute Ndrv from Pext
assign Pdrv = '{Next.V+vc, Next.I, Next.R+rc};  // compute Pdrv from Next

endmodule

