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

// DIO_SIMP - Model for unidirectional resistor (aka diode) between two EEnets.
// Defines hysteretic behavior:  turns on (R=ron) when voltage exceeds specified
// "von" and turns back off (R=roff) when voltage drops below zero.  Voltage 
// changes of less than vtol are not propagated through the switch.

// This model only works cleanly when one of the nets has a resistance of zero
// (in other words, should be used to connect a diode from a net to a supply).
// It should converge quickly when there is a large difference in the effective 
// resistance at the two nets.  It can have inaccuracy and convergence problems  
// if the nets have similar resistances or if the "on" resistance of the diode  
// isn't much larger than the resistance of the low impedance net.  It will not
// work with an "on" resistance of zero.

// An optional turn-off delay time is included in the model.  This can be set to
// zero when one side has ideal voltage drive, but a small nonzero value is very
// useful for stopping on/off oscillations from occurring during switching when 
// a non-ideal supply is connected.

// Updated: 2019-12-09 (ronv) Cadence Design Systems Inc.

`timescale 1ns/1ps
import EE_pkg::*;

module DIO_SIMP (inout EEnet P,N);

parameter real ron=100,roff=1e12;  // on & off resistance of diode
parameter real von=0.01;           // voltage delta needed to turn on
parameter real vtol=1e-5;          // voltage tolerance for updates
parameter real toff=50e-12;        // turn-off time (sec)

real VP,VN,Vdio,Rdio;              // net voltages, and diode V & R
bit State; wire StateD;            // on/off state and off-delayed version

always begin
  Vdio = P.V-N.V;
  if      (Vdio<=0)   State = 0;   // turn off when V goes below 0
  else if (Vdio>=von) State = 1;   // turn on when V goes above von
  if (abs(VP-P.V)>vtol) VP = P.V;  // propagates voltages only when
  if (abs(VN-N.V)>vtol) VN = N.V;  //  change is non-trivial
  @(N.V,P.V);                      // repeat on change of either voltage
end

assign #(0,toff*1s) StateD = State;// immediate turn-on, delayed turn-off
always_comb Rdio = ((State||StateD)===1'b1)? ron:roff;  // state controlled R

assign P = '{VN,0,Rdio};  // drive each side with other voltage + diode resistance
assign N = '{VP,0,Rdio};
// Note, formulation is accurate for drive from voltage source to load, and will 
// provide proper current back from load to voltage source in that case as well.
// But it becomes increasingly inaccurate as source resistance increases.
// Resistor divider effects are propagated through iteration, stopping when
// incremental update is less than vtol, so this is an inefficient operation
// (at best) in the presence of nonzero supply resistance.

endmodule

