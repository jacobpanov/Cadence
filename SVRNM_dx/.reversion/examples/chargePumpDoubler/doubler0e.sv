// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2017, Cadence Design Systems, Inc. All rights reserved.

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

// Cycle-Averaged model for charge pump operation.
// Uses EEnet format for input & output pins to model current handling,
// logic for clock input.  Assumes ground is at zero volts.
// 
// DOUBLER TOPOLOGY: 
//   [IN]*------+----------+
//              S1         S0
//              +-----||---*[MID]---S1---+------*[OUT]
//              S0    CP                _|_ +  
//              |   -Vcp+             CL--- Vcl
//             _|_                      _|_ -  
//              -                        -     
//
// IMPLEMENTATION NOTES:
// The two S1 switches are closed when the clock is high; the two S0
// switches are closed when the clock is low; both are open while the
// clock is switching.  When clock is low, Cp is charged up to Vin.
// Then when clock goes high, Cp and Vin are connected in series to
// the output pin, which can drive the output up to near 2*Vin.
// In each case, the current flows from input through two switches
// and CP (with switched direction) to either ground or output.
//
// CYCLE-AVERAGED MODEL:
// By averaging the currents flowing in the charge pump circuit over one
// cycle of the clock, the resulting output waveform will follow a similar
// envelope as the actual system but not include the cyclic oscillations.
// This provides a very efficient model that maintains large sigal accuracy
// while being simulated very rapidly, since only the dominant time constant
// of the load capacitor needs to be modeled, not the higher frequency
// oscillations that are occuring in the pumping mechanism.
// 
// During the half-cycle with input clock low, current flows from the input
// into Cp to charge it up; then in the second half-cycle while input clock
// is high, current flows from input through Cp to output cap to simulaneously
// discharge Cp and charge CL.  The voltage across Cp is alternating between
// VOUT-VIN when starting charge from input and VIN when charging completes.  
// Charge transfer for each half-cycle can be written as:
//     Qchg = Cp*(2*VIN-VOUT)   from input to ground
//     Qdis = Cp*(2*VIN-VOUT)   from input to output
// Given the clock cycle period Per, we can thus define average input and 
// output current as:
//     Iout = Cp*(VOUT-2*VIN)/Per
//     Iin  = 2*Cp*(2*VIN-VOUT)/Per
// This can be converted to simple voltage+resistance drive to the input
// and output pins by converting those equations to I=(V-Vdr)/R format:
//     Req  = Per/Cp
//     Iout = (VOUT-2*VIN)/Req
//     Iin  = (VIN-VOUT/2)/(Req/4)
// Thus the drivers to the input and output can be defined as:
//     OUT: {2*VIN,0,Req}
//     IN:  {VOUT/2,0,Req/4}
// These can be implemented relatively independently, as the load capacitance
// hanging on the output pin will effectively delay any interaction between the
// two sides.  As long as the sample rate for the load capacitor update is 
// appropriate for the CL*Rload time constant, accuracy should be good.
//
// If the clock frequency gets too high, incomplete charge transfer will occur:
//     Tau = 2*Rsw*Cp
//     Qfh = 1-$exp((Tsw-Per/2)/Tau);  // charge transfer frac in half-cycle
//     Qfrac = Qfh/(2-Qfh);            // charge transfer performed twice
//     Req = Per/Cp/Qfrac;             // smaller transfer = larger resistance

`timescale 1ns/1ps


module doubler0e import EE_pkg::*; (
  inout EEnet OUT,          // EEnet format input and output
  inout EEnet IN,
  input CK                  // clock control input 
  );

  parameter real CL=100e-9;   // output capacitance
  parameter real Cp=10e-9;    // Internal capacitor of charge pump
  parameter real Ron=3;       // on resistance of switches
  parameter real Roff=1e6;    // off resistance of switches (not used)
  parameter real Tsw=5e-9;    // non-overlap interval for switching
  parameter real Ts=500e-9;   // sample rate for load capacitor voltage update
  parameter real Vtol=1e-5;   // tolerance for all element computations

  // Definition of "min" function (not available in standard SV functions):
  function real min(input real A,B); min = (A<B)? A:B; endfunction

  real Cps,Td,Tau,Tfull,Tedge,Tdn,Per,Per0,Qfrac,Req; // variables & constants
  initial begin
    Cps= Cp*1s;          // capacitance converted to timescale units
    Td = Tsw*1s;         // Tsw converted to timescale units
    Tau = Cps*Ron*2;     // time constant in timescale units
    Tfull = 10*Tau+2*Td; // required period for full charge transfer
    Tedge = 0;           // time of last clock edge
    Per = Tfull;         // initially set to min full period value
    Req = Per/Cps;       // pick Req for initial Per
  end

  bit ActClk;            // flag indicating whether clock input is active
  bit[3:0] Nck,NckD;     // clock edge cyclic counter, and delayed version 

  // Compute equivalent resistance on each clock cycle:
  always begin
    wait (!CK);                // wait until clock goes low
    Tdn=$realtime;             // save down-time
    wait (CK);                 // then wait until clock goes high
    if ($realtime>Tdn) begin   // do nothing on clock glitches
      Per0=Per;                // save old period value
      if (ActClk) Per = $realtime-Tedge;  // normal clock period
      else begin               // clock just restarted
        ActClk<=1;             // switch to active state
        Per = 2*min($realtime-Tdn,Per);   // guess period value
      end
      if (Per!=Per0) begin     // update coefs on period change
        if (Per>Tfull) Req = Per/Cps;     // nominal equivalent resistance
        else begin
          Qfrac = 1-$exp((Td-Per/2)/Tau); // fractional-transfer portion
          Qfrac = Qfrac/(2-Qfrac);        // solution for double transfer
          Req = Per/(Cps*Qfrac);          // scaled equivalent resistance
        end
      end
      Tedge = $realtime;       // save time now for next period computation
      Nck++;                   // increment clock cycle counter
      NckD <= #(1.1*Per) Nck;  // update delayed counter after more than a period
    end
  end
  // If no new clock in more than a period, set clock to inactive:
  always @(NckD) if (NckD==Nck) ActClk=0; 

  // Measured input & output voltages:
  real Vin,Vout;
  always @(IN.V) if (abs(IN.V-Vin)>Vtol) Vin = IN.V;
  always @(OUT.V) if (abs(OUT.V-Vout)>Vtol) Vout = OUT.V;

  // Drive equivalent V+R to input and output ports:
  real Vs0,Vs1,Rs0,Rs1;
  assign Vs0 = Vout/2;
  assign Vs1 = ActClk? Vin*2 : Vin;     // switch to passive params when inactive
  assign Rs0 = ActClk? Req/4 : Roff/2;
  assign Rs1 = ActClk? Req : Roff;
  assign IN  = '{Vs0, 0.0, Rs0};
  assign OUT = '{Vs1, 0.0, Rs1};

  // Measured s0 and s1 cycle-averaged currents (just for display):
  real Is0,Is1;
  assign Is0 = (IN.V-Vs0)/Rs0;
  assign Is1 = (Vs1-OUT.V)/Rs1;

  // output capacitor:
  CapGeq #(.c(CL), .tinc(Ts))  Cout (OUT);

endmodule
