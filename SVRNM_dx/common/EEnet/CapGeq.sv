// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2019, Cadence Design Systems, Inc. All rights reserved.

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

// CapGeq is a single-ended capacitor from P to ground.
// Parameters c and rs define capacitance and optional series resistance.
// Paremeter ic is the initial voltage on the capacitor at time zero.
// Default ic value of 1e9 indicates that the DC op point defines voltage.
// Parameters tinc & vtol control output updating.
//
// This model replaces the capacitor with an equivalent resistance over each
// timestep.  Current/Voltage relation over a timestep dT is:
//    Vcap = Vold + (dT/C)*(Icap+Iold)/2
// This can be implemented as equivalent voltage source plus series resistance:
//    Req = dT/2C
//    Veq = Vold+Iold*Req
// That is the model for the capacitor itself.  Any series resistance would be 
// added to Req when driving the output, so the internal capacitor voltage at
// any instant can be computed by:
//    Vcap = Vin - rs*Icap
// So this fits into the simple linear resistance format that is used already
// for EEnet evaluation.  At each new timepoint, this function will recompute 
// Req and Veq based on the step from the previous timepoint.  Iterations at 
// the same timepoint do not require any update to this element, as it is only
// dependent on the previous timepoint value -- it just needs to save the final
// voltage at each timepoint for use in computations at the next timepoint.
//
// Model automatically updates its output every tinc seconds, and whenever an 
// external change causes the node to be reevaluated.  If the update to Veq 
// is less than the specified voltage tolerance, no update will be performed
// while the internal cap voltage will continue to be updated.  This produces
// fewer updates while maintaining specified error tolerance, speeding up 
// simulation when voltage is not significantly changing.  Tolerance value is
// incrementally decreased (0.625x for each skipped update) so a high accuracy
// result will be generated at a lower update rate (rather than returning a DC
// error of up to vtol when current drops to near zero).
//
// Integration accuracy is determined by the relationship of Tinc to the 
// dominant time constant of the R-C interaction occuring.  Error increases 
// with increasing timestep size, limited by the assumption of linear variation
// of voltage and current over the step interval (actual response may be of
// decaying exponential format).  Generally error is good for Tinc<Tau/2 and 
// moderate for Tinc=Tau, but it will of course vary depending on application. 
//
// This model can also implement a modified format when timesteps are 
// attempted that are more than twice the system time constant.
// In that scenario, the capacitor will essentially be following the input
// voltage waveform (given external input model of Vext+Rext) with a delay
// of one time constant (Rext*C).  This format works for response that is 
// controlled by the local R-C time constant.  For other situations, you can 
// either turn off this mode (rxflag=0) or actively specify what the effective
// external resistance is for the RC time constant throughout the simulation
// by using an OOMR to drive variable RxExt in this module (rxflag=2).
//
// Equation for output voltage following input by Tau delay looks like this:
// For external input going from Vx0 at Rx0 to Vx1 at Rx1, capacitor voltage 
// and current change from Vc0 and Ic0 to Vc1 and Ic1.
// Assuming we're past the natural response due to cap voltage Vc0, the output
// will just be a time delay of Tau=Rx1*C behind the input waveform at time T1:
//   Vx1-Vc1 = Tau*SlewRate = Rx1*C*(Vx1-Vx0)/dt
// Note that Vx1 and Vc1 are directly related by the current Ic1 and Rx1:
//   Ic1 = (Vx1-Vc1)/Rx1
// So replace Vx1's in equation with Vc1+Rc1*Ic1, and using Req defined above:
//   Vc1+Ic1*Rx1-Vc1 = (Vc1+Ic1*Rx1-Vx0)*Rx1/(2*Req)
// Solve for relation between Vc1 and Ic1:
//   Vc1 = [Vx0] + Ic1*[2*Req-Rx1]
// And note that Vx0 is computed as Vc0+Ic0*Rx0, resulting in:
//   Vc1 = [Vc0+Ic0*Rx0] + Ic1*[2*Req-Rx1]
// Note that when dT=2*Tau, Rx=Req, so the computed resistance matches the 
// previous at that point.  Errors in initial step response can be in the range
// of exp(-dT/Tau), which can be up to 13% for dT=2*Tau, 5% for dT=3*Tau, 2%
// for dT=4*Tau....  In this format, the model will return the average 
// current over the previous timestep, which works well for a ramping input
// and is at least somewhat representative (actual currents may be spiking
// on switching operations which can't readily be modeled over a single big
// timestep).

// Updated: 2020-01-22 (ronv)

`timescale 1ns/1ps
import EE_pkg::*;

module CapGeq(P);
inout EEnet P;

parameter real c=1e-9;      // capacitance
parameter real rs=0;        // series resistance
parameter real ic=1e9;      // initial voltage at time zero (or big uses DCOP)
parameter real tinc=1e-9;   // timestep for computing voltage update (sec)
parameter real vtol=1e-5;   // voltage tolerance for output update (V)
                            //  or set to zero to disable update skipping
parameter integer rxflag=1; //   0=turn off bigstep feature,
                            //   1=automatic bigstep step feature (default),
                            //   2=external Rx computation (in RxExt variable)

real Vcap,Tcap,Icap;        // voltage on capacitor @ time, and current
real Vold,Told,Iold;        // V,T,I at previous timepoint
real Reqs;                  // equiv R of cap based only on timestep size
real Veqi,Reqi;             // internal Veq&Req (prior to tolerancing)
real Veq,Req;               // output equiv V & R for cap model over timestep
real Rx,Rxold;              // external resistance now and at previous point
real RxExt=1e6;             // externally-loaded Rx value (for diffl cap model)
real PRsav;                 // net resistance for iteration update check
real vtoli;                 // tolerance for use on next evaluation
bit ck,cko;                 // internal clock to drive sampling
bit BigStep;                // flag set when large timestep taken (>2tau)

always begin :ckgen         // start resettable clock generator
  cko <= #(1step) ck;       // cko lags one resolution step behind ck
  #(tinc*1s) ck=!ck;        // clock changes after specified timestep
end

initial begin
  vtoli=vtol;
  if (ic<1e9) Vcap=ic;              // Use specified IC, or
  else begin                        //   open circuit at DC
    Veq=0; Req=1e12;                // at DC op point, set to highZ
    while ($realtime==0) begin      // during DC op point computation
      if (P.V<1e9) Vcap = P.V;      // measure voltage
      @(P.V,P.R,ck);                // repeat on each change 
    end
  end
  Veq=Vcap; Req=(rs==0)? 1e-3:rs;   // cap static near-ideal voltage at time zero
  Vold=Vcap; Veqi=Veq; Reqi=Req;    // copy to internal terms
// MAIN CALCULATION LOOP:
 forever begin  
  if (P.V<1e6) begin         // On each clock or V or R change with non-X input
   if ($realtime>Tcap) begin        // if forward timestep occurred
     Iold = (Vcap-Veq)/Req;         // save last values at previous timepoint
     Vold = Vcap;                   // note, Vcap includes the rs voltage drop
     Told = Tcap;
     Tcap = $realtime+1e-11;        // save new time value (rounding up)
     Reqs = (Tcap-Told)/(2s*c);     // equiv resistance based on C and timestep
     if (rxflag>0) begin            // ignore if no bigstep usage
       Rxold = Rx;                  // save Rx value at last timestep
       if (rxflag==2) 
         if (Rx<1e12) Rx = RxExt;   // use externally-updated Rx value
         else         Rx = 1e12;    //  or 1e12 if it's X or Z
       else if (P.R<Req) Rx = Req*P.R/(Req-P.R); // compute external resistance
       else Rx = 1e12;                      // limit Rx reported for Rx=Z case
       if (BigStep != (Rx<Reqs)) begin  // IF BIGSTEP MODE CHANGE:
         BigStep = !BigStep;        // Two models cross at 2Tau which is Rx=Reqs
         if (BigStep && Rxold>Reqs) Rxold=Reqs;  // bound max value in update est
       end
       PRsav = P.R;                 // keep value of P.R to check for iter update
     end
     if (!BigStep) begin            // normal operation: 
       Veqi = Vold+Iold*(Reqs-rs)   //  equiv voltage based on previous V&I
               +(Veqi-Veq);         //   with delta for non-updated change
       Reqi = Reqs+rs;              // add series resistance to Req term
     end
     else begin                     // bigstep operation:
       Veqi = Vold+Iold*(Rxold-rs); //  equivalent voltage
       Reqi = 2*Reqs-Rx+rs;         //   and resistance (including rs)
     end
     if (abs(Veqi-Veq)>vtoli || abs(Reqi-Req)>Req*1e-3) begin  // VTOL CHECK:
       Veq = Veqi;                  // update if voltage changes by vtol
       Req = Reqi;                  //  or resistance changes by >0.1%
       vtoli = vtol;                // use normal tolerance on next point
     end
     else vtoli = vtoli*0.625;      // decrease tolerance when skipping update
     if (ck==cko) disable ckgen;    // reset clock generator on external event
   end
// ELSE ON ITERATION: Check whether ext R change causes bigstep/normal toggle:
   else if (rxflag==1 && abs(P.R-PRsav)>0.2*PRsav ||
            rxflag==2 && abs(RxExt-Rx)>0.2*Rx) begin
     if (rxflag==2) 
       if (RxExt<1e12) Rx = RxExt;  // use externally-updated Rx value
       else            Rx = 1e12;   // or 1e12 if it's X or Z
     else begin
       if (P.R<Req) Rx = Req*P.R/(Req-P.R); // compute external resistance
       else Rx = 1e12;                      // limit Rx reported for Rx=Z case
       PRsav = P.R;                 // keep value of P.R to check for iter update
     end
     if (BigStep != (Rx<Reqs)) begin  // IF BIGSTEP MODE CHANGE:
       BigStep = !BigStep;            // change mode
       if (!BigStep) begin            // change to normal operation: 
         Veqi = Vold+Iold*(Reqs-rs)   // equiv voltage based on previous V&I
                 +(Veqi-Veq);         //   with delta for non-updated change
         Reqi = Reqs+rs;              // add series resistance to Req term
       end
       else begin                     // change to bigstep operation:
         if (Rxold>Reqs) Rxold=Reqs;  // bound max Rx used in update estimate
         Veqi = Vold+Iold*(Rxold-rs); // equivalent voltage
         Reqi = 2*Reqs-Rx+rs;         //  and resistance (including rs)
       end
       Veq = Veqi;
       Req = Reqi;                    // apply changes to output drive
     end
   end
   Vcap = P.V;                        // get voltage & current at this iteration
   Icap = !BigStep? (P.V-Veq)/Req :   // compute instantaneous current at point
            (Vcap-Vold-rs*(Icap-Iold))*0.5/Reqs; // or average=C*dV/dT when bigstep
  end     // of "if (P.V<1e6)"
  @(P.V,P.R,RxExt,ck);                // repeat on next change of input or clock
 end    // of "forever"
end    // of "initial" 

// Drive equivalent voltage & resistance onto output pin:
assign P = '{Veq,0,Req};

endmodule

