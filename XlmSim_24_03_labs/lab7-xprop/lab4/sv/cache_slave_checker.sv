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
// File        : cache_slave_checker.sv                                                       //  
// Author      : Abhishek Raheja/Harsh Gupta (araheja@cadence.com, harshg@cadence.com )       //  
// Description : This is slave checker. It checks for hit_miss as per cache protocol.         //  
//                                                                                            //  
// Revision History:                                                                          //  
// -------------------------------------------------------------------------------------------//
//   ID                Date           Version         Remark                                  //
// -------------------------------------------------------------------------------------------//
// araheja, harshg   09thDec, 2007     0.1          Checks for hit_miss as per cache protocol.//
////////////////////////////////////////////////////////////////////////////////////////////////

class cache_slave_checker#(type L = logic, type L14 = logic [13:0], type CP = cache_pkg_cache_packet);

   //static logic slave_hit_miss;
   //cache_packet p;
   static L slave_hit_miss;
   CP p;

   static logic [13:0] tag_mem [2**16 - 1 : 0];

   function new();
      p = new();
   endfunction

   task check(virtual interface cache_pkg_if vifc);
     
      @(posedge vifc.gnt)
      begin
         p.addr = vifc.addr_in;
         p.data = vifc.data_in;

         /* check if it should be a hit or a miss operation*/
         if(tag_mem[p.addr[17:2]] == p.addr[31:18])
	 begin
	    $display("SLAVE HIT");
	    slave_hit_miss = 1'b1;
          end
	  else
	  begin
	     $display("SLAVE MISS");
	     slave_hit_miss = 1'b0;
             tag_mem[p.addr[17:2]] = p.addr[31:18];
	  end
       end
       @(negedge vifc.gnt)
       begin
	  if(slave_hit_miss != vifc.hit_miss)
	     $display("FATAL : HIT_MISS signal different than expected");
       end
   endtask

endclass
