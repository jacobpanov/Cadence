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

// CapGx is a capacitor from P to ground with automated timestep selection
// so that it should work in presence of wide impedance changes (switches).
// Parameters c and rs define capacitance and optional series resistance.
// Paremeter ic is the initial voltage on the capacitor at time zero.
// Default ic value of 1e9 indicates that the DC op point defines voltage.
//
// In this model, parameters reltol & vtol control timestep selection:
// Model reads external resistance value on net to compute time constant Tau
// (or you can write in the effective value RxExt if it's not just the net R).
// Max step is related to tolerance needed:  Fraction of Tau used for timestep
// varies with the square root of reltol, roughly as Ktau = 3.5*sqrt(reltol).
// When the voltage difference driving the cap becomes small, the vtol/Vdif
// ratio can be used instead of reltol since proportionally larger errors
// are acceptable due to the vtol limit on small signals.  When the effective
// relative error allowed is above 13%, any size timestep can be sufficiently
// accurate, so the model just doubles the max allowed timestep size per step.
// Parameters tmin & tmax define smallest and largest allowed timesteps.  
//
// Note that reltol & vtol in this module are ONLY used for computation of
// best timestep size to bound integration error criteria, which results in 
// time-response variation.  DC levels will still maintain full accuracy,
// and other events can cause smaller timesteps which results in better time
// accuracy.  Systems with multiple capacitors will at any point be controlled
// by whichever capacitor requires the smallest timestep.
//
// This model uses the standad analog simulator timestep evauluation method of
// replacing the capacitor with an equivalent resistance over each timestep. 
// Current/Voltage relation over a timestep dT is:
//    Vcap = Vold + (dT/C)*(Icap+Iold)/2
// This can be implemented as equivalent voltage source plus series resistance:
//    Reqs = dT/2C
//    Veq = Vold+Iold*Req
// Any series resistance can be added to Reqs when driving the output:
//    Req = Reqs+rs
//    P = '{Veq,0,Req}
// At each new timepoint, this module will recompute Req and Veq based on the 
// step from the previous timepoint.  Iterations at the same timepoint do not
// require any update to this element, as it is only dependent on the previous
// timepoint value -- it just needs to save the final voltage and current at
// each timepoint for use in computations at the next timepoint.
//
// This model implements a modified format when timesteps are attempted that 
// are more than twice the system time constant.  In that scenario, the 
// capacitor voltage will follow the input voltage waveform (given external 
// input model of Vx+Rx) with a delay of one time constant (Rx*C).  This format
// will only be needed when the Rx is much smaller at the new timepoint (when a
// switch turns on), or when the stepsize taken is limited by the Tmin parameter.
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
// of exp(-dT/Tau), which can be up to 13% at dT=2*Tau, but decays quickly to 2%
// for dT=4*Tau and becomes quite accurate for larger timesteps.  
// When it is in this mode, the model has been updated to return the average 
// current over the previous timestep as Icap, which works well for a ramping 
// input and is at least somewhat representative.  Actual currents would be 
// spiking on switching operations, which can't readily be modeled over a single
// big timestep, so this format spreads the current over the timestep.

// Updated: 2020-06-12 (ronv)

`timescale 1ns/1ps
import EE_pkg::*;

module CapGx(P);
inout EEnet P;

parameter real c=1e-9;      // capacitance
parameter real rs=0;        // series resistance
parameter real ic=1e9;      // initial voltage at time zero (default uses DCOP)
parameter real reltol=0.01; // relative error tolerance (stepsize control vs. V)
parameter real vtol=1e-4;   // voltage tolerance (V) (stepsize control near V=0)
parameter real tmin=1e-11;  // minimum timestep (sec) (when external R tiny)
parameter real tmax=1e-7;   // maximum timestep (sec) (when external R huge)

real Vcap,Tcap;             // voltage on capacitor @ time
real Iinst,Icap;            // instantaneous & reported current
real Vold,Told,Iold;        // V,T,I at previous timepoint
real dT;                    // actual timestep (ns) since last timepoint
real Reqs;                  // equiv R of cap based only on timestep size
real Veq,Req;               // output equiv V & R for cap model over timestep
real Rx,Rxold;              // external resistance now and at previous timepoint
real Tau,Tauo;              // time constant (Rx*C) and previous timepoint value
real Vx,Vdif;               // computed external V and diffl V (based on Rx)
real Vdifo,Rxo;             // previous iteration values for update processing
real RxExt;                 // externally-loadable Rx value

real c_ns    = c*1s;        // convert c, tmin, and tmax to system timescale
real tmin_ns = tmin*1s;     
real tmax_ns = tmax*1s;     
real kTauNom = 3.5*$sqrt(reltol);  // nominal fraction of Tau for stepsize
real relacc;                // relative accuracy required based on reltol & vtol
real kTau;                  // fraction of Tau computed
real Tstep;                 // stepsize limit computed

event tstart,tdone;         // events: start timer & timer is done
bit rxxflag;                // flag set when RxExt is updated externally
bit BigStep;                // flag set when large timestep detected (>2tau)

// DEBUG VARS:
int Tmode;                  // Mode index for timestep size selection:
          // 1 = Tau much smaller - use reltol (6 if changed on iteration)
          // 2 = Normal change    - use relacc (7 if changed on iteration)
          // 3 = Tiny Vdif        - double stepsize
          // 4 = Low accuracy     - double stepsize

initial @(RxExt) rxxflag=1; // set flag when Rx is externally defined

// RESETTABLE TIMER OPERATION:
// This task limits specified td to range of tmin to tmax, 
// only allows doubling per timestep, and ignores smaller size change requests.
task StartT (input real td);              // (ns) specify nominal timer delay
  if (td>2*Tstep)      td=2*Tstep;        // limit to max 2x increase of stepsize
  if (td>tmax_ns)      Tstep=tmax_ns;     // upper bound of timestep
  else if (td<tmin_ns) Tstep=tmin_ns;     // lower bound of timestep
  else if (td<0.8*Tstep || td>1.35*Tstep) // only update if significant
    Tstep=$floor(td/tmin_ns+0.5)*tmin_ns; //  and round to multiple of tmin
  ->tstart;                               // restart the timer
endtask
// TIMER:
always fork
  begin :ckgen    // start timer
    #(Tstep);     // wait for specified time delay
    ->tdone;      // signal that timer has finished
    @(tstart);    // wait for next start command
  end
  @(tstart) disable ckgen;  // cancel timer if restart command
join_any          // continue when either step completes

// DC OP POINT EVALUATION:
initial begin
  Tstep = tmax_ns;                  // allow any first stepsize
  StartT(0.1*Tstep);                // default to fraction of max timestep
  if (ic<1e9) begin                 // If IC is specified
    Veq = ic;                       //  force the voltage
    Req = (rs==0)? 1e-3:rs;         //  at low resistance
    while ($realtime==0)            // during DC op point computation
     @(P.V,P.R,RxExt,tdone)         // after next event or at sample time
      if ($realtime==0) begin       // if still at op point
        if (P.V<1e6) begin          //  if valid voltage
          Vcap = P.V;               //   measure voltage
          Icap = (P.V-Veq)/Req;     //    and current
        end
        if (rxxflag)                // if Rx is exernally driven,
          if (RxExt<1e12) Rx = RxExt;   // use externally-updated Rx value
          else            Rx = 1e12;    //   or 1e12 if it's X or Z
        else                        // otherwise get external R from net
          if (P.R<Req) Rx = Req*P.R/(Req-P.R); // compute external resistance
          else         Rx = 1e12;              //  or 1e12 if it's X or Z
        Tau = (Rx+rs)*c_ns;         // compute system time constant
        StartT(Tau*kTauNom*0.2);    // restart timer with 20% of actual kTau
      end
    Iinst = Icap;                   // save cap current at end of op point
  end
  else begin                        // Else open circuit at DC, so measure voltage
    Veq=0; Req=1e12;                // at DC op point, set to highZ
    while ($realtime==0) begin      // during DC op point computation
      if (rxxflag)                  // if Rx is exernally driven,
        if (RxExt<1e12) Rx = RxExt; // use externally-updated Rx value
        else            Rx = 1e12;  //   or 1e12 if it's X or Z
      else                          // otherwise get external R from net
        if (P.R<1e12) Rx = P.R;     // compute external resistance
        else          Rx = 1e12;    //  or 1e12 if it's X or Z
      Tau = (Rx+rs)*c_ns;           // compute system time constant
      StartT(Tau*kTauNom*0.2);      // restart timer with 20% of actual kTau
      @(P.V,P.R,RxExt,tdone);       // update on any change during DC op point
      if ($realtime==0 && P.V<1e6) Vcap = P.V; // update voltage
    end
    Veq=Vcap; Req=(rs==0)? 1e-3:rs; // cap static near-ideal voltage at time zero
  end
  Tauo=Tau;                         // initialize old Tau value

// MAIN CALCULATION LOOP:
 forever begin  
  if (P.V<1e6) begin         // On each clock or V or R change with non-X input
   Rxo = Rx;                        // save old Rx for trivial update check
   if (rxxflag)                     // if Rx is exernally driven,
      if (RxExt<1e12) Rx = RxExt;   // use externally-updated Rx value
      else            Rx = 1e12;    //  or 1e12 if it's X or Z
   else                             // otherwise get external R from net
      if (P.R<Req) Rx = Req*P.R/(Req-P.R); // compute external resistance
      else         Rx = 1e12;              //  or 1e12 if it's X or Z
   if (abs(Rx-Rxo)<1e-4*(Rx+1)) Rx=Rxo; // don't change if trivial!
// ON NEW TIMEPOINT:
   if ($realtime>Tcap) begin        // if forward timestep occurred
     if (Rx!=Rxo) begin             // if time constant changed
       Tauo = Tau;                  // save previous value
       Tau = (Rx+rs)*c_ns;          // compute new system time constant
     end
     Iold = Iinst;                  // save last values at previous timepoint
     Vold = Vcap;                   // note, Vcap includes the rs voltage drop
     Told = Tcap;
     Tcap = $realtime;              // save new time value
     dT = Tcap-Told;                // actual timestep used 
     Reqs = dT/(2*c_ns);            // equiv resistance based on C and timestep
     Rxold = Rxo;                   // save Rx value at last timestep
     if (Told>0) Vx = P.V+(P.V-Veq)*Rx/Req;  // external drive V for given Rx
     Vdif = abs(Vx-P.V);            // estimate of voltage drive
// Timestep evaluation:
     if (Rx<0.5*Rxold) begin        // when external R significantly decreases
       relacc = reltol;             // use default stepsize based on reltol
       kTau = kTauNom;
       Tmode = 1;
     end
     else if (Vdif<8*vtol) begin    // only tiny change over step
       if (kTau<1.1 || Tstep<Tau) kTau=1.4;  //  go to max normal stepsize
       else kTau = 2;               // after that, switch to BigStep mode 
       Tmode = 3;
     end
     else begin
       if (Vdif>=abs(Vx)) relacc = reltol+vtol/Vdif; // small Vx, so reltol dominates
       else    relacc = (reltol*abs(Vx)+vtol)/Vdif;  // small Vdif, so relacc is big
       if (relacc<0.16) begin
         kTau = 3.5*$sqrt(relacc);  // compute fraction of Tau for step
         Tmode = 2;
       end
       else begin                   // low accuracy update is OK, 
         if (kTau<1 || Tstep<Tau) kTau=1.4;  // so go to max normal stepsize
         else kTau = 2;             // after that, double stepsize to BigStep mode 
         Tmode = 4;
       end
     end
     if (kTau<2)                    // if using normal equations
       if (Tau<1.25*Tauo) StartT(Tau*kTau);       // normal next step evaluation
       else               StartT(1.25*Tauo*kTau); // limit change when Rx increase  
     else                           // else bigstep form so doubling OK
       if (dT>0.75*Tstep) StartT(tmax_ns); // double if near Tstep limiting
       else               StartT(Tstep);   // else samestep after external event 
// Bigstep vs normal processing:
     BigStep = (Rx<Reqs);           // Two models cross at 2Tau which is Rx=Reqs
     if (!BigStep) begin            // normal operation: 
       Veq = Vold+Iold*(Reqs-rs);   //  equiv voltage based on previous V&I
       Req = Reqs+rs;               //  add series resistance to Req term
     end
     else begin                     // bigstep operation:
       Veq = Vold+Iold*(Rxold-rs);  //  equivalent voltage
       Req = 2*Reqs-Rx+rs;          //   and resistance (including rs)
     end
   end
// ELSE ON ITERATION: 
   else begin           // When Rext changes, reevaluate model setup:
    if (Rx!=Rxo) begin 
      Tau = (Rx+rs)*c_ns;              // compute new system time constant
// Check for BigStep mode change:
      if (BigStep != (Rx<Reqs)) begin  // If mode has changed
        BigStep = !BigStep;            // update flag
        if (!BigStep) begin            // normal operation - 
          Veq = Vold+Iold*(Reqs-rs);   // equiv voltage based on previous V&I
          Req = Reqs+rs;               // add series resistance to Req term
        end
        else begin                     // bigstep operation -
          Veq = Vold+Iold*(Rxold-rs);  // equivalent voltage
          Req = 2*Reqs-Rx+rs;          //  and resistance (including rs)
        end
      end
// Timestep recalculation if Rx significantly decreases:
      if (Rx<0.5*Rxo) begin
        relacc = reltol;               // use default stepsize based on reltol
        kTau = kTauNom;
        Tmode = 6;
        StartT(Tau*kTau);              // restart timer with new stepsize
      end
    end
// Else check for big Vdif requiring shorter tstep:
    else begin                         // if small Vdif was causing bigger tstep
      Vdifo = Vdif;                    // save previous iteration's difference
      Vx = P.V+(P.V-Veq)*Rx/Req;       // new external drive V for given Rx
      Vdif = abs(Vx-P.V);              // new estimate of voltage difference
      if (Vdif>1.5*Vdifo+8*vtol) begin   // recompute step if much larger Vdif
        if (Vdif>abs(Vx)) relacc = reltol+vtol/Vdif;  // small Vx, so reltol dominates
        else    relacc = (reltol*abs(Vx)+vtol)/Vdif;  // small Vdif, so relacc is big
        if (relacc<0.16) begin         // if better accuracy needed
          kTau = 3.5*$sqrt(relacc);    // compute fraction of time constant for step
          if (Tau*kTau<Tstep) begin    // if stepsize needs decreasing,
            Tmode = 7;
            StartT(Tau*kTau);          // restart timer with new stepsize
          end
        end
      end
    end
   end     // of step/iter processing
   Vcap = P.V;             // get voltage & current at this iteration
   Iinst = (P.V-Veq)/Req;  // instantaneous I: if bigstep, replace with avg=C*dV/dT
   Icap = BigStep? (Vcap-Vold-rs*(Iinst-Iold))/(2*Reqs) : Iinst; 
  end      // of "if (P.V<1e6)"
  @(P.V,P.R,RxExt,tdone);  // repeat on next input change or clock
 end       // of "forever"
end        // of "initial" 

// Drive equivalent voltage & resistance onto output pin:
assign P = '{Veq,0,Req};

endmodule

