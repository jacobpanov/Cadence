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
// VCO Model with table lookup using file-based and real array based methods


`timescale 1ns/1ps
module vco import cds_rnm_pkg::* ; (
   output  logic VCO_OUT, 
   input  wreal4state VDD, VCTRL
   );

// real array based table model declarations
real x[0:14]; real y[0:14]; real f_xy[0:14];

real Freq, Thalfper=1;

initial begin
       // Used for Real Array Table Model
      x[ 0]=1; y[ 0]=0; f_xy[ 0]=9.81E+07;
      x[ 1]=1; y[ 1]=0.4;     f_xy[ 1]=1.05E+09;
      x[ 2]=1; y[ 2]=0.8;  f_xy[ 2]=1.41E+09;
      x[ 3]=1.1; y[ 3]=0; f_xy[ 3]=9.88E+07;
      x[ 4]=1.1; y[ 4]=0.45;     f_xy[ 4]=1.29E+09;
      x[ 5]=1.1; y[ 5]=0.9;  f_xy[ 5]=1.52E+09;
      x[ 6]=1.2; y[ 6]=0; f_xy[ 6]=9.95E+07;
      x[ 7]=1.2; y[ 7]=0.5;     f_xy[ 7]=1.37E+09;
      x[ 8]=1.2; y[ 8]=1;  f_xy[ 8]=1.69E+09;
      x[ 9]=1.3; y[ 9]=0; f_xy[ 9]=1.00E+08;  
      x[10]=1.3; y[10]=0.55;     f_xy[10]=1.52E+09;
      x[11]=1.3; y[11]=1.1;  f_xy[11]=1.85E+09;
      x[12]=1.4; y[12]=0; f_xy[12]=1.01E+08;
      x[13]=1.4; y[13]=0.6;     f_xy[13]=1.67E+09;
      x[14]=1.4; y[14]=1.2;  f_xy[14]=2.00E+09;
end

always @(VDD, VCTRL) begin
   //file-based table model
   Freq = $table_model(VDD, VCTRL,"./vtuneFreqControl.tbl", "1LL");
   //real array based table model 
   // Freq = $table_model(VDD, VCTRL, x,y,f_xy, "1LL"); 

   $display ("The Frequency read from table is %9.5e", Freq) ;
   Thalfper = 0.5e9/Freq;
   $display ("Thalfper is %9.5e", Thalfper) ;
 end

 logic osc=0;
 always  #Thalfper osc = !osc;
 assign VCO_OUT = osc;

 endmodule

