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
// 
// Demonstration of using a scalar real nettype with Built-In Resolution Functions
//
//*************************************************************************************************************

//Nettype declaration 
nettype real realnet with CDS_res_wrealsum; 

module top; 
realnet w; 
driver1 d1(w); 
driver2 d2(w); 
receiver r1(w); 
endmodule 

module receiver(input realnet rec_1);
always @(rec_1)
$display($time , ," outval = %f \n", rec_1);
endmodule 

module driver1(output realnet dr_1); 
assign dr_1 = 2.2; 
endmodule 

module driver2 (output realnet dr_2); 
real r; 
assign dr_2 = r; 
initial begin 
#10 r = 1.1; 
end 

endmodule
