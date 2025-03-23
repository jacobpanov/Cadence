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
//
// Variable Gain TransImpedance Amplifier
//
//---------------------------------------------------------------

`timescale 1s / 1ps

module TIA import cds_rnm_pkg::*; import EE_pkg::*; ( 

  inout EEnet vdd,
  inout EEnet vss,
  input wreal1driver vbias1,
  input wreal1driver vbias2,
  input EEnet in,
  output EEnet out,
  input logic [3:0] gain,
  input logic en

 );

 parameter real vddMin = 1.0;   // Volts
 parameter real vddMax = 1.8;   // Volts  
 parameter real vssMax = 0.1;    // Volts
 parameter real vbias1Nom = 0.25; // % of vdd
 parameter real vbias2Nom = 0.75; // % of vdd
 parameter real vbiasTol = 0.05;  // % of Nom
 parameter real onCurrent = 600e-6;  //Amps
 parameter real stdbyCurrent = 1e-6; //Amps
 parameter real AzNom = 50;      // Volts/Amp
 parameter real rOutNom = 1000;  // Ohms
 parameter real rOutOff = 1;     // Ohms
 parameter real rOutHi  = 1e6;   // Ohms
 parameter real ZinOn = 2000;    // Ohms
 parameter real ZinOff = 1e6;     //Ohms
 parameter real dcOutNom = 0.75;  //Volts
 parameter real FcNom = 20e6;        // Cutoff Frequency
 parameter real vtol=1e-5;      // voltage tolerance (no change when dV<vtol)
 parameter real Ts=0.01/FcNom;    // max timestep of response (s)
 parameter real Tau=1/(6.2831853*FcNom);       // time constant (s)


  reg vddGood;
  reg vssGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  reg vbias1Good;
  reg vbias2Good;
  logic vbiasFilt;
  wire enInt;
  reg tiaOn;
  real vout, vout_int;
  real rOut;
  real iSupply;
  real Az_calc;
  real i_in;
  real v_in;
  real Zin;
  real dcOut;

  always begin
      vddGood = ((vdd.V >= vddMin) && (vdd.V < vddMax));
      @ (vdd.V);
  end
  assign #(250e-9) vddGoodFilt = vddGood;
  
  always begin
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
      @ (vss.V);
  end

  assign #(250e-9) vssGoodFilt = vssGood;

  always @ (vbias1 or vdd.V)
      vbias1Good = ( (vbias1 > (vbias1Nom*vdd.V*(1-vbiasTol))) && 
                   (vbias1 < (vbias1Nom*vdd.V*(1+vbiasTol))) );

  always @ (vbias2 or vdd.V)
      vbias2Good = ( (vbias2 > (vbias2Nom*vdd.V*(1-vbiasTol))) && 
                   (vbias2 < (vbias2Nom*vdd.V*(1+vbiasTol))) );
  
  assign #(250e-9) vbiasFilt = ((vbias1Good && vbias2Good)) ? 1'b1 : 1'b0;

  assign #(250e-9) enInt = (en === 1'b1);

  always @ (enInt or vddGoodFilt or vssGoodFilt or vbiasFilt) begin
      if ( (enInt == 1'b1) && (vddGoodFilt === 1'b1) 
           && (vssGoodFilt === 1'b1) && (vbiasFilt === 1'b1) ) begin
          tiaOn = 1;
          Zin = ZinOn;
          vout_int = dcOut;
      end
      else begin
         if ((vddGoodFilt !== 1'b1) || (vssGoodFilt !== 1'b1)) begin
             vout_int = `wrealZState;
             rOut = rOutHi;
             tiaOn = 0;
             Zin = `wrealZState;
             dcOut = `wrealZState;
         end
         else if ((enInt == 1'b0) || (vbiasFilt == 1'b0)) begin
             vout_int = 0.0;
             rOut = rOutOff;
             tiaOn = 0;
             Zin = ZinOff;
             dcOut = 0.0;
         end
     end
  end

  assign iSupply = ((tiaOn == 1'b1) ? onCurrent : 0.0) + 
     ( ((vddGoodFilt !== 1'b1) || (vssGoodFilt !== 1'b1)) ? 0.0 : stdbyCurrent );
  assign out = '{vout,0,rOut};
  assign in  = '{0, 0, Zin};
  assign vdd = '{`wrealZState,-iSupply, 0};
  assign vss = '{`wrealZState,+iSupply, 0};

  always @ (gain or tiaOn or vdd.V) begin
    if ( !($isunknown(gain)) && (gain != 0) && (tiaOn == 1'b1) ) begin
           Az_calc = AzNom / $countones(gain);
           rOut = rOutNom / $countones(gain);
           dcOut = vdd.V - (dcOutNom / $countones(gain));
        end
        else begin
           if (tiaOn == 1'b0) begin
              Az_calc = `wrealZState;
              rOut    = rOutOff;
              dcOut = 0.0;
           end
           else begin           // means gain = 0 or undefined
              Az_calc = 1.0; 
              rOut = rOutHi;
              dcOut = 0.0;
           end         
        end
  end

  always @ (in.V or in.R or tiaOn) begin
     if (tiaOn == 1'b1) begin
        i_in = in.V/in.R;
        vout_int = (vdd.V - vss.V) * $tanh((dcOut + (Az_calc * i_in)) / (vdd.V - vss.V));
     end
  end


  real dT, dV, T0, V0, IN0;
  reg Dtime=0; 

  task startT; begin                   // task to start the timer
    Dtime=1'bx; wait (Dtime); end      // wait for timer to start, then continue
  endtask

  task cancelT; begin                  // cancel the timer
    disable Timer; wait(!Dtime); end   // wait for timer to stop, then continue
  endtask

  always @(Dtime) begin                // define cancellable timer
    begin:Timer 
      Dtime=1; 
      #(Ts); 
    end    // starting sets Dtime to 1
    Dtime=0;                           // completion or cancelling sets to 0
  end

  initial begin
    IN0 = vout_int; 
    V0 = vout_int;
    @ (vout_int);
  forever begin                      // For rest of run, 
    dT=$realtime-T0;                 // compute timestep size
    dV=(IN0-V0)*(1-$exp(-dT/Tau));   // dV over timestep for filter
    V0 = (abs(V0) < 1e10) ? (V0 + dV) : 0.0; // accumulate one dV step this time point
    T0=$realtime;                    // save time of V0 update
     // save input value
    IN0 = vout_int;                  // get a new sample of raw out
    if (abs(V0-vout_int)<vtol*0.25) begin  // if converged to value
                                          //  stop at final value
      V0= vout_int; 
      vout= vout_int;
      @(vout_int);                    //  and wait for next change
    end
    else begin                       // else normal update step
      if (abs(vout-V0)>vtol) vout=V0;//  update output value if change>vtol 
      startT;                        //  set timer
      while ($realtime==T0) begin    // wait for new timestep to occur:
        @(vout_int,Dtime);                 //  wait for next value change or timer
        if ($realtime==T0) IN0=vout_int;   //  iteration at same point (update INbuf)
        else if (Dtime) cancelT;     // cancel timer if raw value changes first
      end                            // continue only when new timestep
    end
  end
  end

// Define real absolute value and max functions:
function real abs(input real A); abs = (A<0)? -A:A; endfunction
function real max(input real A,B); max = (B>A)? B : A; endfunction

endmodule
