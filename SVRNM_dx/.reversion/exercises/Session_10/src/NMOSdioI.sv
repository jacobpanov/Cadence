// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2017, 2020 Cadence Design Systems, Inc. All rights reserved.

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

// NMOSdioI is a model for a diode-connected n-channel MOSFET's voltage versus
// current behavior.  This is an EEnet based model that assumes applied external 
// low impedance drive, so it computes the current from the node voltage.
// It includes controls to allow it to iterate toward a solution (and complain
// if the iterations do not converge).
// Basic active NMOS transfer characteristic: 
//    Id = (Kp/2)*(Vgs-Vth)**2

// Updated: 2017-06-30 (ronv) 
// Prepared for Exercise 2020-02-20  (danielcr)

`timescale 1ns/1ps
import EE_pkg::*;

module NMOSdioI import EE_pkg::*; (D);
inout EEnet D;      // Drain&Gate pin of diode-connected NMOS (S is grounded)

parameter real kp=100e-6;      // gain constant in mosfet equation [A/V**2]   
parameter real vth=0.8;        // threshold voltage 
parameter real roff=1e8;       // off resistance
parameter real vtol=1e-4;      // voltage tolerance
parameter integer itermax=10;  // max iterations allowed at one timepoint

real Id,Vd;              // Measured voltage & computed current
int Niter;               // number iterations at present timepoint
real Tprev;              // time at previous iteration

always @(D.V) if (abs(D.V-Vd)>vtol) begin // when nontrivial node change
  if ($realtime>Tprev) begin    // if new timepoint,
    Niter=0; Tprev=$realtime;   //  reset iteration counter
  end
  else Niter++;                 //  else bump iteration counter
  if (D.V>vth) begin            // if above threshold voltage
    Vd = D.V;                                    // update voltage
    if (Niter<=itermax) Id = kp/2*(Vd-vth)**2;  // and compute current
    else $display(             // past iter limit - print message
    "*WARNING* NMOSdioI %M exceeded iterations: T=%.1fns  Vn=%.3fV  Vd=%.3fV",
                                                 $realtime,   D.V,   Vd);
  end
  else begin                        // not conducting - just leakage
    Vd = vth;                       // park voltage measure at vth when off
    Id = 0;                         // off state (roff to ground)
  end
//- $display("dioI:  %5.0fns #%2d  Vn=%8.4f  Vd=%8.4f  Id=%9.3g",
//-                $realtime, Niter,  D.V,      Vd,       Id); 
end

assign D = '{0,-Id,roff};           // Drive I as sink with just off resistor

endmodule

     
