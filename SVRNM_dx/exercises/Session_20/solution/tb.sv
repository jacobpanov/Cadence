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
// PLL example exercise test bench 
//
//---------------------------------------------------------------

`timescale 1s/1fs

import EE_pkg::*;
import cds_rnm_pkg::*;

module tb ();

logic en, pwrEn;
EEnet VDD, VSS;
logic [6:0] vcoTune;
logic [3:0] lfTrim;
logic [4:0] div;
logic [5:0] mod;

tbPwrRamp #(.defaultFinalValue (1.5), .defaultRampTime (2e-6)) u_tbPwrRamp (VDD, VSS, pwrEn);

PLL_stimulus u_stimulus (
   .PLL_EN (en),
   .vcoTune (vcoTune), 
   .REFCLK_EN (refClkEn),
   .RESETN (resetn),
   .PLLLOCK (pllLock),
   .LFPREEN (lfPreEn),
   .MOD (mod),
   .LFTRIM (lfTrim),
   .DIV (div),
   .PWREN (pwrEn)
);

PLL_top u_PLLtop (
  .adcClkn (), 
  .adcClkp (), 
  .div_outm (), 
  .div_outp (), 
  .pllLock (pllLock), 
  .refclkm (), 
  .refclkp (), 
  .vco_outn (vco_outn), 
  .vco_outp (vco_outp), 
  .vdd (VDD), 
  .vss (VSS), 
  .courseTune (vcoTune), 
  .div (div), 
  .en (en), 
  .lfPreChg (lfPreEn), 
  .lfTrim (lfTrim), 
  .mod (mod), 
  .refClkEn (refClkEn)
);

// Place an instance of the measurement block here 
pllLockTimeMeas #(.lockTimeSpec (55e-6)) u_LockTimeMeas (
  .targFreq (4928e6), 
  .lockSpec (100e3), 
  .window (10e-6), 
  .holdOff (9e-6),
  .enableSig (en), 
  .vcoIn (vco_outp & ~vco_outn),
  .lockTime (),
  .done ()
);

assign VSS = '{0, `wrealZState, 0};

endmodule

