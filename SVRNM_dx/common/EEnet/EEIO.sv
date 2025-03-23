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

// EEIO.sv - drive signal to EEnet net and measure external drive to it
// Signal driven to Drv input will be directly applied to Net;
// Whenever Net changes, external drive will be computed and update Ext.
//
// Includes V&I tolerance: external change ignored if input iteration occur
// within tolerances of the initial value at that timepoint.
// If only discretely changing signals are being processed (static DC networks),
// you can set flag "disc" to 1 so that small changes to a new timestep will
// not be passed through (more efficient but does not maintain piecewise-
// linear signal assumption so integration & pwl plotting may be less accurate).
//
// Module also counts number of external changes at same timepoint, and stops
//  updating and prints message when itermax updates have already occurred.  
//     Iter    = number of iterations seen at each timepoint;
//     IterERR = number of timepoints which pass iteration limit
//     Npts    = total number of timepoints processed
//     Nupdt   = total number of external updates processed
//
// Note that both Drv and Ext are EEstruct values, not nets.
// Valid Drv input formats:      '{V,I,R}, '{-,I,`Z}, '{`X,-,-}
// Output Ext formats generated: '{V,0,R}, '{0,I,`Z}, '{`X,0,`X}
//  (the dashes "-" are don't cares: not used in processing)

// Updated 2019-04-11 (ronv) Cadence Design Systems Inc.

import EE_pkg::*;

// Shorthand for standard real constants:
`ifdef EEX
`else
 `define Z `wrealZState
 `define X `wrealXState
 `define EEZ '{0.0, 0.0, `Z}
 `define EEX '{`X, 0.0, `X}
`endif

module EEIO( inout EEnet Net,        // net to drive & sense
             input EEstruct Drv,     // signal to drive to Net
             output EEstruct Ext);   // measured external input to Net

parameter real itermax=10;  // max iterations at one timepoint
parameter real vtol=1e-4;   // output voltage update tolerance
parameter real itol=1e-9;   // output current update tolerance
parameter real rtol=0.1;    // output resistance update tolerance
parameter real rz=1e13;     // input resistance to treat as Z
parameter bit  disc=0;      // set high to indicate only static updates
                            // (no Ext update at new timepoint if change<tol)

real Imeas=0;               // measured incoming current (Ext-to-Drv)
int Iter;                   // iterations per timepoint (counts to itermax) 
int IterERR;                // count number of timepoints that pass itermax
int Npts,Nupdt;             // total numbers of timepoints & Ext updates 

// Actual code that extracts incoming signal and processes iterations
// and tolerances is protected here.  

//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=prv(CDS_RSA_KEY_VER_1)
//pragma protect key_method=RSA
//pragma protect key_block
f9sws2OFCDnHcss5do4qRtwUmWQLL2Mp5v3TvLb0iK6tpx/v7S1TGOlhLmZ5q+tn
hT4bZ6M27eD5TKsJl0zTNwoaGcPCeMqV1ExPo0qfz4AUCv1jjzyC6/N8u7rEM0Nq
+z/ixC9cGcW5+Wh0XCoDu1SXEskdO8z1dm25lAsQaxfBQIoq5AYbVCilUw1cIaKk
HboMzGb+gQp3nBJxgZZWoBHkMO3R17w8oIH7aPdgYUHhmbiWc4KyXGsjBX8djAyj
4D0O0HdbIwcbgYXjSv8SVShJ0GBg2YTZ+DHwzInx6pziG5KiFaCxXOeeqjrhWIng
coJ/JhHXM4UT0qHpGsCDbg==
//pragma protect end_key_block
//pragma protect digest_block
0IzazE2m5eqCEIEtbbOFKe3cW7Q=
//pragma protect end_digest_block
//pragma protect data_block
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
qUmES0hpb7F8XL1Au5vMMg==
//pragma protect end_data_block
//pragma protect digest_block
GvblETeX00JVTd0hfmfM+D11MF0=
//pragma protect end_digest_block
//pragma protect end_protected

endmodule
