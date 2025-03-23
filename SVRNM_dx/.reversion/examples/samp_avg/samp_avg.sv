//--------------------------------------------------------------------------------------
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
//--------------------------------------------------------------------------------------
//
// Averaging (integrating) sampler
//
//--------------------------------------------------------------------------------------

`timescale 1ns/1ps

module samp_avg import cds_rnm_pkg::*; (IN,OUT);
  input wreal1driver IN; 
  output wreal1driver OUT;
  parameter Ts = 10;  			// sampling interval (ns)
  parameter vwig = 1e-12;		// output wiggle added when no change (V)

  real T0, V0, Sum0; 			// last input point & integral up to that point
  real Tout, Vavg ;  			// last output point 
  real Sout, Snew;  			// sum at last output point & new sum
  real  Vout ;

initial V0 = ((IN<1e20) && (IN>-1e20)) ? IN:0;	// init to initial value if valid, else zero

always @(IN) begin 				// at each input point
  if ((IN<1e20)&&(IN>-1e20)) begin		// if input valid
    Sum0 = Sum0 + V0*($realtime-T0); 		// integrate up to this point
    V0 = IN;       				// save point for next calculation
  end
  else V0 = 0;     				// use zero value if input is invalid
  T0= $realtime;
  if (T0==0) Vout = V0;			// DC update at time zero
end	

always #Ts begin    			// every output sample period
  Snew = Sum0+V0*($realtime-T0);		// sum up to current time
  Vavg = (Snew-Sout)/Ts;         		// compute average over interval
  Vout = (Vavg==Vout)? Vavg+vwig : Vavg;	// wiggle if no change
  Tout = $realtime;              		// save time and sum
  Sout = Snew;
end

assign OUT = Vout ;	
		
endmodule	

