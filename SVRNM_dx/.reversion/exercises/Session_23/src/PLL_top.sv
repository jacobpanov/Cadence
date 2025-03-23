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
// Top level structural netlist for Charge-pump PLL
//
// --------------------------------------------------------------

`timescale 1ns/1ps

import EE_pkg::*;
import cds_rnm_pkg::*;

module PLL_top (adcClkn, adcClkp, div_outm, 
    div_outp, pllLock, refclkm, refclkp, vco_outn, vco_outp, 
    vdd, vss, courseTune, div, en, lfPreChg, lfTrim, mod, refClkEn);

output logic adcClkn, adcClkp, div_outm, div_outp, pllLock, refclkm, 
    refclkp, vco_outn, vco_outp;

inout  EEnet vdd, vss;

input  logic en, lfPreChg, refClkEn;

input [5:0]  mod;
input [3:0]  lfTrim;
input [6:0]  courseTune;
input [4:0]  div;

wreal4state vtune;
EEnet pdOut;


divider2 IDiv ( .adcClkm(adcClkn), .adcClkp(adcClkp), .outm(div_outm), 
    .outp(div_outp), .div(div), .en(en), .vss(vss), .vdd(vdd), 
    .inm(vco_outn), .inp(vco_outp));

chgPumpPhDet IPhDet ( .resetb(en), .vss(vss), .vdd(vdd), 
    .refinm(refclkm), .refinp(refclkp), .vcoinm(div_outm), 
    .vcoinp(div_outp), .out(pdOut));

vco_rf IVCO ( .courseTune(courseTune), .outn(vco_outn), 
    .outp(vco_outp), .en(en), .modin(mod), .vtune(vtune), .vss(vss), 
    .vdd(vdd));

loopFilter2 ILF ( .trim(lfTrim), .preChg(lfPreChg), .lock(pllLock), 
    .en(en), .out(vtune), .in(pdOut), .vss(vss), .vdd(vdd));

refClkGen IRefClk ( .vss(vss), .vdd(vdd), .clkb(refclkm), 
    .clk(refclkp), .en(refClkEn));

endmodule
