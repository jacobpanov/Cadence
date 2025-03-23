// --- Begin Copyright Block -----[ do not move or remove ]------
//Copyright (c) 2020, Cadence Design Systems, Inc. All rights reserved.

/*************************************************************************************************************

The model contained herein is the proprietary and confidential information of Cadence, 
and is supplied subject to, and may be used only by Cadence's customer in accordance with 
a previously executed license and maintenance agreement between Cadence and that customer. 
This model is intended for use with products only from Cadence Design Systems, Inc.  
The use or sharing of any models from this library or any of its modified/extended form 
is strictly prohibited with any non-Cadence products.  

ALL MATERIALS FURNISHED BY CADENCE HEREUNDER ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
AND CADENCE SPECIFICALLY DISCLAIMS ANY WARRANTY OF NONINFRINGEMENT, FITNESS FOR A PARTICULAR 
PURPOSE OR MERCHANTABILITY. CADENCE SHALL NOT BE LIABLE FOR ANY COSTS OF PROCUREMENT OF SUBSTITUTES,
LOSS OF PROFITS, INTERRUPTION OF BUSINESS, OR FOR ANY OTHER SPECIAL, CONSEQUENTIAL OR INCIDENTAL DAMAGES,
HOWEVER CAUSED, WHETHER FOR BREACH OF WARRANTY, CONTRACT, TORT, NEGLIGENCE, STRICT LIABILITY OR OTHERWISE.

***************************************************************************************************************/
// Testbench for table_model driven vco

`timescale 1ns/1ps

module vco_ds_TB ( );
real VDD, VCTRL;   // input voltage to drive vco
logic VCO_OUT;    // output from digital vco
vco I1 (VCO_OUT, VDD, VCTRL);

task sweepVCTRL;
for (integer i=0;i<9;i++) begin
   if (VCTRL >= 2.0) VCTRL = 0.0;
   else VCTRL = VCTRL + 0.25; 
   #100;
end
endtask

always begin			
  VDD = 1; VCTRL = 0; 		
  sweepVCTRL;
  #100 VDD = VDD+0.1 ; 
  sweepVCTRL;
  #100 VDD = VDD+0.1 ;   
  sweepVCTRL;
  #100 VDD = VDD+0.1 ;   
  sweepVCTRL;  
  #100 VDD = VDD+0.1 ;   
  sweepVCTRL;		
  #200 $finish;    		
end


// MEASURE ACTUAL DIGITAL FREQUENCY:
real fdig,tupd=0;  

// on leading clock edge
always @(VCO_OUT) begin
  //  compute F=1/period (Hz)
  if (tupd>0) fdig=1e9/(($realtime-tupd)*2);
  tupd = $realtime; //   and save edge time
end

endmodule

