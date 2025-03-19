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
// File        : cache_master_checker.sv                                                      //  
// Author      : Abhishek Raheja/Harsh Gupta (araheja@cadence.com, harshg@cadence.com )       //  
// Description : This is master checker. It compares the content of cache wrt golden memory   //  
//                                                                                            //  
// Revision History:                                                                          //  
// -------------------------------------------------------------------------------------------//
//   ID                Date           Version         Remark                                  //
// -------------------------------------------------------------------------------------------//
// araheja, harshg  09thJune, 2008     0.1           Implements master                        //
//                                                   checker                                  //
////////////////////////////////////////////////////////////////////////////////////////////////

   class cache_master_checker;
      golden_mem gm;

      task write(cache_pkg_cache_packet p);
         gm.push_data(p.addr,p.data);
	 $display("Data at addr %h is %h\n", p.addr, p.data);
      endtask // write

      task checker(cache_pkg_cache_packet p);
         if (p.data == gm.pop_data(p.addr)) begin
           $display("\n Monitor: Data read is CORRECT  : ADDR = %h - cache = %h and golden = %h :-)", p.addr, p.data, gm.pop_data(p.addr));
           //`dut_error(("Data receieved is different from the expected data\n"))
         end
         else begin
           $display("\n Monitor: Data read is INCORRECT: ADDR = %h - cache = %h and golden = %h :-(", p.addr, p.data, gm.pop_data(p.addr));
         end
      endtask // checker

      function new();
         gm = new();
      endfunction // new
         
   endclass

