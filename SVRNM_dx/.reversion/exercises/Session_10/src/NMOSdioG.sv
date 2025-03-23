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

// NMOSdioG is a model for a diode-connected n-channel MOSFET's voltage versus
// current behavior.  This is an EEnet based model that computes the current and
// conductance based on applied voltage, so it may be able to converge to a 
// solution when driven with a linear system of any impedance.
// It includes controls to allow it to iterate toward a solution (and complain
// if the iterations do not converge).
// Basic active NMOS transfer characteristic: 
//    Id = (Kp/2)*(Vgs-Vth)**2
// Conductance can be computed as partial of Id with respect to Vgs:
//    Gd = Kp*(Vgs-Vth)

// Updated: 2017-06-30 (ronv) 
// Prepared for Exercise 2020-02-20  (danielcr)

`timescale 1ns/1ps


module NMOSdioG import EE_pkg::*; (D);
inout EEnet D;      // Drain&Gate pin of diode-connected NMOS (S is grounded)

parameter real kp=100e-6;      // gain constant in mosfet equation [A/V**2]   
parameter real vth=0.8;        // threshold voltage 
parameter real roff=1e8;       // off resistance
parameter real vtol=1e-4;      // voltage tolerance
parameter integer itermax=10;  // max iterations allowed at one timepoint

real Vd=vth,Id,Rd=roff;  // Measured voltage, computed current & resistance
int Niter;               // number iterations at present timepoint
real Tprev;              // time at previous iteration

// Compute V,I at corner between off and active region equations:
real idx=vth/roff;              // off resistance equation defines current
real vthx=vth+$sqrt(2*idx/kp);  // inverted mos-diode equation defines voltage

always @(D.V) if (abs(D.V-Vd)>vtol) begin  // when nontrivial node change
  if (D.V>vthx) begin               // if above threshold
    if ($realtime>Tprev) begin    // if new timepoint,
      Niter=0; Tprev=$realtime;   //  reset iteration counter
    end
    else Niter++;                 //  else bump iteration counter
    if (Niter<=itermax) begin
      Vd <= D.V;                   // update voltage
      Id <= kp/2*(D.V-vth)**2;     // compute current
      Rd <= 1/(kp*(D.V-vth));      // compute conductance
    end
    else if (Niter==itermax+1) $display(    
    "*WARNING* NMOSdioIG %M exceeded iterations: T=%.1fns  Vn=%.3fV  Vd=%.3fV",
                                               $realtime,   D.V,   Vd);
  end
  else begin                        // not conducting - just leakage
    if ($realtime>Tprev) begin      // if new timepoint,
      Niter=0; Tprev=$realtime;     //  reset iteration counter
    end
    else if (Id>0) Niter++;         //  else bump counter only at turnoff
    Id <= 0;                        // zero diode current here
    Vd <= 0;                        // centered at zero voltage
    Rd <= roff;                     // leakage resistance
  end 
//- $display("dioG:  %5.0fns #%2d  Vn=%8.4f  Vd=%8.4f  Id=%9.3g  Rd=%9.3g",
//-                $realtime, Niter,  D.V,      Vd,       Id,       Rd); 
end

assign D = '{Vd,-Id,Rd};            // Drive I as sink, with V+R dependence

endmodule

     
