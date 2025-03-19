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
// File        : golden_mem.sv                                                                //  
// Author      : Abhishek Raheja/Harsh Gupta (araheja@cadence.com, harshg@cadence.com )       //  
// Description : This is golden memory used as golden reference model                         //  
//                                                                                            //  
// Revision History:                                                                          //  
// -------------------------------------------------------------------------------------------//
//   ID                Date           Version         Remark                                  //
// -------------------------------------------------------------------------------------------//
// araheja, harshg   09thJune, 2008     0.1          Implements memory as static element      //
////////////////////////////////////////////////////////////////////////////////////////////////
                                                    
   class golden_mem #(type DT = data_type, type AT = addr_type) ;
      //static data_type mem[addr_type];
      static DT mem[AT];

      //function data_type pop_data(addr_type addr);
      function DT pop_data(AT addr);
         if (mem.exists(addr))
           return mem[addr];
         else
           return ('hFFFF);
      endfunction // pop_data

      //function void push_data(addr_type addr, data_type data);
      function void push_data(AT addr, DT data);
         mem[addr] = data;
      endfunction // push_data
   endclass // golden_mem

