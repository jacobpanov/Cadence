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
// --------------------------------------------------------------

// Simple EEnet model for voltage source with optional series resistance
// Returns measured current flow from pin P through this element to ground

module myVIR            // module for voltage+resistance driver 
 ( inout EE_pkg::EEnet P,  // EEnet pin is inout format
   input real Vval,        // voltage value to drive to net
   input real Rval,        // resistor value to drive to net
   input real Ival,
   output real Imeas );    // measured current from pin thru V+R to ground

// drive voltage & resistance onto net:
 assign P = '{Vval,Ival,Rval};  

// if ideal voltage source, read current from net, else compute from V/R:
 assign Imeas = (Vval+Rval===`wrealZState)? -Ival : 
                (Rval==0)? P.I : (P.V-Vval)/Rval-Ival;

endmodule

