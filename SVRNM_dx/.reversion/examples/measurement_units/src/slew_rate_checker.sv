//Copyright (c) 2016, Cadence Design Systems, Inc. All rights reserved.

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

//Slew rate check Assertion monitor module

`timescale 1ns/1fs

module slew_rate_checker(in);
input var real in;

parameter real Vlo=0.0;                    //Lowest voltage cross point in Volts(V)
parameter real Vhi=1.8;                    //Highest voltage cross point in Volts(V) 
parameter real voltage_hi_frac=0.9;        //Fraction of high voltage value (Vhi) used for slew rate calculation.
parameter real voltage_lo_frac=0.1;        //Fraction of low voltage value (Vlo) used for slew rate calculation.

//Slew rate calculation starts here
real Vf,Vi,Tf,Ti,slew_rate;
reg i,f;

real Vhi_lo_per,VL,TL,Vhi_hi_per;

initial begin
  Vf=0.0;
  Vi=0.0;
  Tf=0.0;
  Ti=0.0;
  slew_rate=0.0;
  i=1'b1;
  f=1'b1;
  Vhi_lo_per=Vlo+(voltage_lo_frac*(Vhi-Vlo));
  Vhi_hi_per=Vhi-((1-voltage_hi_frac)*(Vhi-Vlo));
  VL=0.0;
  TL=0.0;
end
    
    
always@ (in) begin          
    if((in>=(Vhi_lo_per)) && (i==1)) begin
        Vi=Vhi_lo_per;          
        Ti = (((Vhi_lo_per-VL)*($realtime-TL))/(in-VL)) +TL;
        i=0;
    end   

    if((in<(Vhi_lo_per)) && (i==0)) begin
        Vi=Vhi_lo_per;          
        Ti = (((Vhi_lo_per-VL)*($realtime-TL))/(in-VL)) +TL;
        i=1;
    end
        
           
    if((in>=(Vhi_hi_per)) && (f==1)) begin
        Vf=Vhi_hi_per;
        Tf= (((Vhi_hi_per-VL)*($realtime-TL))/(in-VL)) +TL;
        f=0;
    end   
        
    if((in<(Vhi_hi_per)) && (f==0)) begin       
        Vf=Vhi_hi_per;
        Tf= (((Vhi_hi_per-VL)*($realtime-TL))/(in-VL)) +TL;
        f=1;
    end
        
    VL=in;
    TL=$realtime; 
end

always@ (Ti,Tf) begin: block 
          if( ((f==1) && (i==1)) || ((f==0) && (i==0)) ) begin
                if(Tf>Ti) slew_rate=((Vf-Vi)*1e9)/(Tf-Ti);
                else if (Tf<Ti) slew_rate=((Vf-Vi)*1e9)/(Ti-Tf);
          end
          else
             slew_rate=`wrealZState;
end


endmodule


