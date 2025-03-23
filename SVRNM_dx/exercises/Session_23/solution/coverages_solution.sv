//--------------------------------------------------------------------------------------
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
//--------------------------------------------------------------------------------------
//
// Covergroups and cover points for PLL test bench 
//
//--------------------------------------------------------------------------------------

module covPLL (input adcClkn, adcClkp, div_outm, 
    div_outp, pllLock, refclkm, refclkp, vco_outn, vco_outp, 
    vdd, vss, en, lfPreChg, refClkEn, [6:0] courseTune, [4:0] div, [3:0] lfTrim, [5:0] mod);

covergroup PLL_coverage 
    @ ( posedge (refclkp & !refclkm) iff ((en === 1'b1) && (refClkEn=== 1'b1)) );

   cvdiv:  coverpoint div {bins divRanges[4] = {[0:$]}; }
   tune:   coverpoint courseTune {bins cTune[] = {[0:$]}; }
   lfPre:  coverpoint lfPreChg;
   lfTr:   coverpoint lfTrim {
              bins rx = {4}; 
              bins tx = {9};
       ignore_bins unused = {[0:3],[5:8],[10:$]};
           }
   cMod:   coverpoint mod {
              bins used = {[0:16]};
       ignore_bins unused = {[17:31]};
           }
   option.comment = "********************* PLL Block Coverage *********************";
endgroup

PLL_coverage PLLcov = new;

endmodule

module covVCO (input outp, en, real vtune);
// Try to gather coverage on what values vtune reaches. Define some ranges.
covergroup VCO_coverage @(posedge outp iff (en == 1'b1));
   VCOtune: coverpoint vtune
      { ignore_bins vtune0 = {[0.0:0.25]};
        bins vtune1 = {[0.25:0.5]};
        bins vtune2 = {[0.5:0.75]};
        bins vtune3 = {[0.75:1.0]};
        bins vtune4 = {[1.0:1.25]};
        bins vtune5 = {[1.25:1.5]};
        ignore_bins vtune6 = {[1.5:$]};
      }
     option.comment = "********************* VCO VTUNE Bins *********************";
endgroup

VCO_coverage VCOcov = new;

endmodule

module coverages ();

bind PLL_top covPLL cv_PLLcov ( .adcClkn(adcClkn), .adcClkp(adcClkp), 
    .lfTrim(lfTrim), .lfPreChg(lfPreChg), 
    .refClkEn(refClkEn), .div_outm(div_outm), .div_outp(div_outp), 
    .pllLock(pllLock), .refclkm(refclkm), .refclkp(refclkp), 
    .div(div), .courseTune(courseTune), .vss(vss), 
    .vdd(vdd), .vco_outn(vco_outn), .vco_outp(vco_outp), .en(en), 
    .mod(mod)) ;


bind vco_rf covVCO cv_VCOcov (
  .outp (outp), .en (en), .vtune (vtune)
);


endmodule
