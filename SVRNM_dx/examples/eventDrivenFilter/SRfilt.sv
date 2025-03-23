// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2018, Cadence Design Systems, Inc. All rights reserved.

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

// SRfilt(OUT,IN):  First order filter model with slew rate limiter.
// Computes integral of discrete input over timestep to get nominal 
// filtered dV of output, but limits that dV using the slew rate parameter.
// Updates on all input events, but skips output updates of less than vtol.
// Output steps to input value when it converges to within vtol/4.

// Updated: 2019-04-05 (ronv)


module SRfilt import cds_rnm_pkg::*; (output wreal4state OUT, input wreal4state IN);
 timeunit 1ns/1ps;              // set time uint & precision for this module
 parameter real Fc=1e6;         // corner freq (Hz)
 parameter real SR=Fc;          // slew rate limit (V/sec)
 parameter real vtol=1e-5;      // voltage tolerance (no change when dV<vtol)
 parameter real Ts=0.08s/Fc;    // max timestep of response (ns)

real Tau,SRns,dT,dV,dVsr,Vout,IN0,INbuf,V0,T0;
// Define real absolute value and max functions:
function real abs(input real A); abs = (A<0)? -A:A; endfunction
function real max(input real A,B); max = (B>A)? B : A; endfunction

// Define delay timer with start & end tasks:
reg Dtime=0; 
task startT; begin                   // task to start the timer
  Dtime=1'bx; wait (Dtime); end      // wait for timer to start, then continue
endtask
task cancelT; begin                  // cancel the timer
  disable Timer; wait(!Dtime); end   // wait for timer to stop, then continue
endtask
always @(Dtime) begin                // define cancellable timer
  begin:Timer Dtime=1; #(Ts); end    // starting sets Dtime to 1
  Dtime=0;                           // completion or cancelling sets to 0
end

assign INbuf = (abs(IN)<1e6) ? IN : 0.0; // filter X/Z states

// MAIN LOOP:
initial begin
  Tau=1s/(6.2831853*Fc);       // time constant (ns)
  SRns=SR/1s;                  // slew rate (V/ns)
  while ($realtime==0) begin   // At DCop
                               
    IN0 =  INbuf; 
    V0  =  INbuf; 
    Vout=  INbuf;    // output matches input
    @(INbuf);
  end
  forever begin                      // For rest of run, 
    dT=$realtime-T0;                 // compute timestep size
    dV=(IN0-V0)*(1-$exp(-dT/Tau));   // dV over timestep for filter
    dVsr=SRns*dT;                    // dV over timestep for SR limit
    if      (dV>dVsr)  V0+=dVsr;     // positive slew limiting
    else if (-dV>dVsr) V0-=dVsr;     // negative slew limiting
    else               V0+=dV;       // output limited only by filter
    T0=$realtime;                    // save time of V0 update
     // save input value
    IN0= INbuf;                         
    if (abs(V0-INbuf)<vtol*0.25) begin  // if converged to INbuf value
                //  stop at final value
      V0= INbuf; 
      Vout= INbuf;
      @(INbuf);                         //  and wait for next change
    end
    else begin                       // else normal update step
      if (abs(Vout-V0)>vtol) Vout=V0;//  update output value if change>vtol 
      startT;                        //  set timer
      while ($realtime==T0) begin    // wait for new timestep to occur:
        @(INbuf,Dtime);                 //  wait for next INbuf change or timer
        if ($realtime==T0) IN0=INbuf;   //  iteration at same point (update INbuf)
        else if (Dtime) cancelT;     // cancel timer if INbuf changes first
      end                            // continue only when new timestep
    end
  end
end
assign OUT = Vout;
endmodule

