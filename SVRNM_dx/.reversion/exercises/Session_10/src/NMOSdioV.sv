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

// NMOSdioV is a model for a diode-connected n-channel MOSFET's voltage versus
// current behavior.  This is an EEnet based model that assumes applied 
// external current, so it computes the voltage based on measured current.
// It includes controls to allow it to iterate toward a solution (and complain
// if the iterations do not converge).
// Basic active NMOS transfer characteristic: 
//    Id = (Kp/2)*(Vgs-Vth)**2
// This model inverts that relationship to define voltage vs current:
//    Vd = sqrt(2*Id/Kp)+Vth
// Output voltage drops to zero at high impedance when near-zero current.

// Updated: 2017-06-30 (ronv) 
// Prepared for Exercise 2020-02-20  (danielcr)

// NMOSdioV: output as ideal voltage source based on measured current.

`timescale 1ns/1ps

module NMOSdioV import EE_pkg::*; (D);
inout EEnet D;      // Drain&Gate pin of diode-connected NMOS (S is grounded)

parameter real kp=100e-6;      // gain constant in mosfet equation [A/V**2]   
parameter real vth=0.8;        // threshold voltage 
parameter real vtol=1e-4;      // voltage computation tolerance
parameter real vmax=5;         // max output diode voltage (limits when bad I)
parameter integer itermax=10;  // max iterations allowed at one timepoint

real Id,Vd;              // Measured current & computed drain-source voltage
real Vo=0;               // Output drive voltage
int Niter;               // number iterations at present timepoint
real Tprev;              // time at previous iteration

always @(D.I) begin                  // whenever current changes
  Id = D.I;                          // external current into block
  if (Id>0) Vd = $sqrt(2*Id/kp)+vth; // compute MOS-diode voltage
  else Vd = vth;                     // turn-off is just vth level here
  if (abs(Vd-D.V)>vtol) begin        // if significant voltage change
    if ($realtime>Tprev) begin
      Niter=0; Tprev=$realtime;      // new timepoint, reset counter
    end
    else Niter++;                    // else bump iteration counter
    if (Niter<=itermax) Vo<=(Vd<vmax)? Vd:vmax;  // update output voltage
    else if (Niter==itermax+1) $display(    
     "*WARNING* NMOSdioV %M exceeded iterations: T=%.1fns  Vn=%.3fV  Vd=%.3fV",
                                                   $realtime,   D.V,   Vd);
  end
//- $display("dioV:  %5.0fns #%2d  D.I=%9.3g  D.V=%8.4f  Vd=%8.4f",
//-                $realtime, Niter,   D.I,       D.V,      Vd); 
end

assign D = '{Vo,0,0};             // Drive output as ideal voltage

endmodule

     
