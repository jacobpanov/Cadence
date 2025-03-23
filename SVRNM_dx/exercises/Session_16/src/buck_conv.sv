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
//
// buck mode DC/DC converter model (EEnet version)
//               CK
//            ...|......................
//    Iin->   : _v_    IL->  L         :  Iout->
//    __________---___ _____ooo___ ______________ 
//   |   [IN] :      _|_[M]      _|_   : [OUT]   |   
//  Vs        :   dio/_\        C---   :        RL 
//   |        :       |           |    :         |  
//   v        :       v           v    :         v
//            :........................:
// Clock (CK):  period [Per], duty cycle [Duty]
// Inductor [L], Capacitor [C],
// Diode:  on voltage [Vd], on resistance [Rd]
// Switch: on resistance [Rsw], switch time [Tsw]

module buck_conv  import EE_pkg::*;
  (output EEnet OUT, input EEnet IN, input CK);

parameter real L=1e-3;    // inductor value
parameter real C=0.2e-6;  // capacitor value
parameter real Rsw=0.1;   // on resistance of switch
parameter real Tsw=10e-9; // rise/fall time of switch
parameter real Rd=0.1;    // on resistance of diode
parameter real Vd=0.2;    // on voltage of diode
parameter real Roff=1e9;  // off resistance of diode & switch
parameter real Ts=2e-6;   // sample period

EEnet M,GND;              // internal nodes within module
assign GND = '{0,0,0};    // drive ground node to zero

// EENET NETLIST:
SwitD   #(.ron(Rsw), .roff(Roff), .tr(Tsw))  Swt(IN,M,CK);
DIO_EE  #(.von(Vd), .ron(Rd), .roff(Roff))   Dio(GND,M);
IndDeq0 #(.l(L), .tinc(Ts), .ic(0))          Ind(M,OUT);
CapGeq1 #(.c(C), .tinc(Ts), .ic(0))          Cap(OUT);

endmodule

