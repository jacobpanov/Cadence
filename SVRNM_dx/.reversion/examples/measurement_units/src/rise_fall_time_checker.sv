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

//rise time check Assertion monitor module

`timescale 1ns/1fs

module rise_fall_time_checker(in);
input var real in;

parameter real Vlo=0.0;                        //Lowest voltage cross point in Volts(V)
parameter real Vhi=1.8;                        //Highest voltage cross point in Volts(V)
parameter real frac_rise_fall_time_hi=0.9;     //Percentage of highest voltage cross point (Vhi) parameter that needs to be used 
                                               //for rise time Calculation as the highest voltage value.0.9 represent 90% of the Vhi is used.
parameter real frac_rise_fall_time_lo=0.1;     //Percentage of Lowest voltage cross point (Vlo) parameter that needs to be used 
                                               //for rise time Calculation as the lowest voltage value.0.1 represent 10% of the Vlo is used.


//rise rate calculation starts here
real Tf,Ti,rise_fall_time_calc;
reg i,f;
real Vhi_lo_per,Vhi_hi_per,VL,TL,Vi,Vf;

initial begin
  Tf=0.0;
  Ti=0.0;
  rise_fall_time_calc=0.0;
  i=1'b1;
  f=1'b1;
  Vhi_lo_per= Vlo + (frac_rise_fall_time_lo*(Vhi-Vlo));
  Vhi_hi_per=Vhi - ((1-frac_rise_fall_time_hi)*(Vhi-Vlo));
  Vi=0.0;
  Vf=0.0;
  VL=0.0;
  TL=0.0;
end

 
always@(in) begin           

      if((in>=Vlo) && (in>=Vhi_lo_per) && (i==1)) begin    
        Vi=Vhi_lo_per;          
        Ti = (((Vhi_lo_per-VL)*($realtime-TL))/(in-VL)) +TL;
        i=0;
      end
      
      if((in>=Vlo) && (in<Vhi_lo_per) && (i==0)) begin
        Vi=Vhi_lo_per;          
        Ti = (((Vhi_lo_per-VL)*($realtime-TL))/(in-VL)) +TL;
        i=1;
      end
  
      if((in<=Vhi) && (in>=Vhi_hi_per) && (f==1)) begin
        Vf=Vhi_hi_per;
        Tf= (((Vhi_hi_per-VL)*($realtime-TL))/(in-VL)) +TL;
        f=0;
      end
      
      if((in<=Vhi) && (in<Vhi_hi_per) && (f==0)) begin
        Vf=Vhi_hi_per;
        Tf= (((Vhi_hi_per-VL)*($realtime-TL))/(in-VL)) +TL;
        f=1;
      end
                    
        VL=in;
        TL=$realtime; 
end

always@(Ti,Tf) begin
      if( ((f==1) && (i==1)) || ((f==0) && (i==0)) ) begin 
        if(Tf>Ti) rise_fall_time_calc=(Tf-Ti)*1e-9;
        else if (Tf<Ti) rise_fall_time_calc=(Ti-Tf)*1e-9;
      end
      else
        rise_fall_time_calc=`wrealZState;
end

  
endmodule


