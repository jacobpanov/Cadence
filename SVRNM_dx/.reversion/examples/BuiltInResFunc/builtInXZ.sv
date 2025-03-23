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
// Demonstration of using Built-In Nettype Definitions with X and Z states
//
//*************************************************************************************************************

import cds_rnm_pkg::*; // Importing the Cadence RNM package

nettype wrealavg realnet; //Renaming wrealavg to realnet

module top; 
realnet w; 
//All 3 modules connect to net w
receiver r1(w); 
driver1 d1(w); 
driver2 d2(w); 
endmodule 

module receiver(input realnet rec_1);
always @(rec_1)
$display($time , ," outval = %f \n", rec_1);
endmodule 

module driver1(output realnet dr_1); 
real r1; assign dr_1 = r1; 
initial begin
r1 = 2.2 ;
#2 r1 = `wrealZState ; #2 r1 = 1.5 ;
#3 r1 = `wrealXState ; #1 r1 = 2.1 ;
end
endmodule

module driver2 (output realnet dr_2); 
real r2; assign dr_2 = r2; 
initial begin 
r2 = 3.3 ;
#1 r2 = `wrealZState ; #3 r2 = 1.3 ;
#2 r2 = `wrealXState ; #2 r2 = 2.1 ;
end 

endmodule
