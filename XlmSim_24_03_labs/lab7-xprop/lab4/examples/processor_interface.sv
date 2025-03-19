////////////////////////////////////////////////////////////////////////////////////////////////
// ****************************************************************************               //
// *         CONFIDENTIAL AND PROPRIETARY INFORMATION OF CADENCE India        *               //
// *                                                                          *               //
// *               Copyright (c) Cadence, Inc. 2007                           *               //
// *                                                                          *               //
// *     Use of the material contained herein requires the written consent    *               //
// *         of Cadence India, and is subject to the terms of Cadence's       *               //
// *                         Nondisclosure Agreement.                         *               //
// ****************************************************************************               //
//                                                                                            //
// File        : processor_interface.sv                                                       //  
// Description : This is processor interface of cache controller IP.                          //  
//                                                                                            //  
////////////////////////////////////////////////////////////////////////////////////////////////

module processor_interface 
   (
          clk,                          // clock input
          reset,                        // reset input 
          top_pint_req,                 // memory request, = 1 new request; = 0 no request;
          pint_mctrl_access             // access to main controller; = 1 access on; = 0 no access;   
   );

   input 
          clk,
          reset,
          top_pint_req;       

   output   
          pint_mctrl_access;
 
   reg      
          pint_mctrl_access;
  
  
  always @(posedge clk or negedge reset) begin
    if (reset == 1'b0) begin
      pint_mctrl_access  <= 1'b0;
    end 
    else begin
      case (top_pint_req)
        1'b0 : begin
          pint_mctrl_access   <= 1'b0;
        end
        1'b1 : begin
          pint_mctrl_access   <= 1'b1;
        end
      endcase  
    end
  end 
endmodule
