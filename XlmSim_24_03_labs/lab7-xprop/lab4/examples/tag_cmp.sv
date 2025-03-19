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
// File        : tag_cmp.sv                                                                   //  
// Description : This is tag comparision block of cache controller IP.                        //  
//                                                                                            //  
////////////////////////////////////////////////////////////////////////////////////////////////

module tag_cmp 
   (
      mctrl_tcmp_tagcmp_en,           // enable tag compare
      mctrl_tcmp_tagrdwr,             // read write input, = 0 read ; = 1 write;
      mctrl_tcmp_tagaddr_in,          // address from main controller to read the tag memory
      tcmp_mctrl_addr_out,            // address from the comparision block  to main controller for the write back
      tcmp_mctrl_hit_miss,            // hit or miss status, = 1 hit; = 0 miss;
      tcmp_mctrl_tagcmp_done          // Tag comparision done, = 1 done; = 0 not done;
   );

   input         mctrl_tcmp_tagcmp_en,
                 mctrl_tcmp_tagrdwr;
   input  
          [31:0] mctrl_tcmp_tagaddr_in;

   output 
          [31:0] tcmp_mctrl_addr_out;
   output        tcmp_mctrl_hit_miss,   
                 tcmp_mctrl_tagcmp_done;

   reg
          [31:0] tcmp_mctrl_addr_out;
   reg           tcmp_mctrl_hit_miss,   
                 tcmp_mctrl_tagcmp_done;
   reg     
          [13:0] tagmem_data_out;

   logic 
          [13:0] memory [65535:0];

  always@(mctrl_tcmp_tagcmp_en, mctrl_tcmp_tagaddr_in, tagmem_data_out)
  begin
    case ({mctrl_tcmp_tagcmp_en,mctrl_tcmp_tagrdwr})
      2'b00,2'b01 :  begin
        tcmp_mctrl_tagcmp_done = 1'b0;
      end
      2'b10       :  begin
        tagmem_data_out        = memory[mctrl_tcmp_tagaddr_in[17:2]];
        tcmp_mctrl_tagcmp_done = 1'b1;
        case (mctrl_tcmp_tagaddr_in[31:18] == tagmem_data_out)
          1'b0 : begin
            tcmp_mctrl_hit_miss    = 1'b0;
            tcmp_mctrl_tagcmp_done = 1'b1;
            tcmp_mctrl_addr_out    = {tagmem_data_out,mctrl_tcmp_tagaddr_in[17:2], {2'b00}};
          end
          1'b1 : begin
            tcmp_mctrl_hit_miss    = 1'b1;
            tcmp_mctrl_tagcmp_done = 1'b1;
            tcmp_mctrl_addr_out    = {tagmem_data_out,mctrl_tcmp_tagaddr_in[17:2], {2'b00}};
          end
          default : begin
            tcmp_mctrl_tagcmp_done = 1'b0;
          end
        endcase
      end
      2'b11     : begin
        memory[mctrl_tcmp_tagaddr_in[17:2]] = mctrl_tcmp_tagaddr_in[31:18];
      end
      default : begin
        tcmp_mctrl_tagcmp_done = 1'b0;
      end
    endcase 
  end
endmodule
