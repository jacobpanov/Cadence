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
// File        : tag_mem.sv                                                                   //  
// Description : This is tag memory of cache controller IP.                                   //  
//                                                                                            //  
////////////////////////////////////////////////////////////////////////////////////////////////

module tag_mem 
   (
      tcmp_tmem_en,                  // enable the tag memory 
      tcmp_tmem_rdwr,                // read write input, = 0 read ; = 1 write;
      tcmp_tmem_addr_in,             // address from tag comparision block to read the tag memory
      tcmp_tmem_tag_in,              // Tag data to be written into the tag memory
      tmem_tcmp_tag_out,             // Tag data read from the tag memory
      tmem_tcmp_rdy                  // tag memory read data ready, = 0 read data not ready; = 1 read data done
   );

   input      [15:0] tcmp_tmem_addr_in;
   input             tcmp_tmem_rdwr,
                     tcmp_tmem_en;
   input      [13:0] tcmp_tmem_tag_in;

   output reg [13:0] tmem_tcmp_tag_out;
   output reg        tmem_tcmp_rdy;        


   logic[13:0] memory [65535:0];

   always @(tcmp_tmem_en, tcmp_tmem_rdwr, tcmp_tmem_addr_in, tcmp_tmem_tag_in)
   begin
      case ({tcmp_tmem_en, tcmp_tmem_rdwr})
         2'b10          :  begin
                              tmem_tcmp_tag_out         = memory[tcmp_tmem_addr_in];
                              tmem_tcmp_rdy             = 1'b1;
                           end
         2'b11          :  begin
                              memory[tcmp_tmem_addr_in] = tcmp_tmem_tag_in;
                              tmem_tcmp_rdy             = 1'b1;
                           end
         default        :  begin
                              tmem_tcmp_rdy             = 1'b0;
                           end
      endcase
   end      





endmodule
