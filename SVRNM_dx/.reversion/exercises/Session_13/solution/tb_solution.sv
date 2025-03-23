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
// LNA example exercise test bench 
//
//---------------------------------------------------------------

`timescale 1s/1fs

module tb ();

import EE_pkg::*;
import cds_rnm_pkg::*;

logic en, pwrEn;
logic [2:0] lnaGain = 3'b111;
wreal4state rfoutm, rfoutp, rfinm, rfinp;
wreal4state rfOutDiff, rfInDiff;
real measAmpl, measdBm, measIn;
real measGain, measGaindB;
real expectedGain;
EEnet VDD, VSS;

lna u_lna ( rfoutm, rfoutp, VDD, VSS, en, rfinm, rfinp, lnaGain );

// rfSource #(.amplitude (0.001)) u_rfsource (rfinp, rfinm);

// RF source instance for testing frequency response.
// slow modulation, very wide deviation, to sweep out frequency response of LNA
// Comment our u_rfsource and use this one instead.
rfSource #(.amplitude (0.001), .modFreq (100e3), .modDev (100e6)) u_rfSourceFreqResp (rfinp, rfinm);

tbPwrRamp #(.defaultFinalValue (1.5), .defaultRampTime (10e-6)) u_tbPwrRamp (VDD, VSS, pwrEn);

assign VSS = '{0, `wrealZState, 0};

always @ (lnaGain) begin
   expectedGain = (integer'(lnaGain) * 3) - 9; // 3dB steps + min
end

initial begin
   pwrEn = 1'b0;
   en    = 1'b0;

   #(10us) pwrEn = 1'b1;
   #(50us) en = 1'b1;
   repeat (7) begin
      #(25us) lnaGain = lnaGain - 1;
   end
   repeat (7) begin
      #(25us) lnaGain = lnaGain + 1;
   end
   #(5us) en = 1'b0;
   #(10us) pwrEn = 1'b0;
   #(20us) $stop;

end

assign rfOutDiff = ( ((rfoutp - rfoutm) > 1e20) || ((rfoutp - rfoutm) < -1e20) ) ? `wrealXState : (rfoutp - rfoutm);
assign rfInDiff  = ( ((rfinp - rfinm) > 1e20)   || ((rfinp - rfinm) < -1e20) )   ? `wrealXState : (rfinp - rfinm);

always @ (rfOutDiff) begin
   measAmpl = (rfOutDiff == `wrealXState) ? 0.0 : (rfOutDiff < 0) ? -rfOutDiff : rfOutDiff;
   measdBm = 20*$log10(measAmpl);
   measGain = measAmpl/measIn;
   measGaindB = 20*$log10(measAmpl/measIn);
end

always @ (rfInDiff) begin
   measIn = (rfInDiff == `wrealXState) ? 0.0 : (rfInDiff < 0) ? -rfInDiff : rfInDiff;
end


endmodule
