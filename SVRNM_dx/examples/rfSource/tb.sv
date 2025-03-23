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
// Test bench for RF Source
//
//--------------------------------------------------------------------------------------

`timescale 1s/1ps

module tb_rfSource ();
real rfp, rfm;
logic modclk;
logic modEn;
logic rfEn=1'b0;
real ampl=0.5;
real modData;
real fCarrier = 2440;
real modFreq = 1e6;
real modClkPer = 1/(16*modFreq); // 16X oversampling

initial begin
  modclk = 1'b0;
  modEn = 1'b0;
  rfEn  = 1'b0;

  #(5us);
  rfEn = 1'b1;  //enable RF Source 1 clock before data gets there
  #(10us);
  modEn = 1'b1;
  #(100us);
  modEn = 1'b0;
  #(10us);
  rfEn = 1'b0;
  #(10us);
  $finish;
end

//Generate the mod clock
always #(modClkPer/2) begin
      modclk = (modEn == 1'b1) ? ~modclk : 1'b0;
end

always @ (posedge modclk)
   modData = $cos($realtime*modFreq);

tbRFSource u_tbRFSource (
  .carrierFreq (fCarrier), 
  .amplitude (ampl), 
  .modulation (modData),
  .rfp (rfp), 
  .rfm (rfm),
  .sampClk (modclk), 
  .enable (rfEn)
);



endmodule

