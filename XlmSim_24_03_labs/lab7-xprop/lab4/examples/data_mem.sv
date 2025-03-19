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
// File        : data_mem.sv                                                                  //  
// Description : This is data memory module of cache controller IP.                           //  
//                                                                                            //  
////////////////////////////////////////////////////////////////////////////////////////////////

module data_mem 
   (
      mctrl_dmem_en,              // Enable the data memory;
      mctrl_dmem_rdwr,            // read write input, = 0 read ; = 1 write;
      mctrl_dmem_loc_wr,          // Location write input, = 0 full location; = 1 write 32-bit;
      mctrl_dmem_addr_in,         // address from main controller to read the cache data memory
      mctrl_dmem_data_in,         // data to be written into the cache data memory
      mctrl_dmem_setdirty,        // Set Dirty Bit, 1 = set dirty, 0 = dont set dirty
      dmem_mctrl_data_out,        // data read from the cache data memory     
      dmem_mctrl_dirtybit,        // Dirty Bit, = 1 dirty; = 0 no dirty;
      dmem_mctrl_rdy              // cache memory read data ready, = 0 read data not ready; = 1 read data done 
 ); 

  input  [17:0]     mctrl_dmem_addr_in;
  input  [4*32-1:0] mctrl_dmem_data_in;
  input             mctrl_dmem_en,       
                    mctrl_dmem_setdirty,
                    mctrl_dmem_loc_wr,
                    mctrl_dmem_rdwr;       

  output [4*32-1:0] dmem_mctrl_data_out;  
  output            dmem_mctrl_dirtybit,
                    dmem_mctrl_rdy;
 
  //////////////////////////////////////////////////////////////
  // datamem is the data memory for the cache. Since the size //
  // the present cache (first phase RTL) is 1MB with each line//
  // of cache having 4*32bits, storage lines in the cahce will//
  // be 65536 which is 2^^16.                                 //
  //                                                          //
  // In future this needs to be changed to                    //
  //                                                          // 
  // No of Cache lines  = Total Cache Size / Line Width       //
  //                                                          //
  //            Where Line Width will be                      //
  //                                                          //
  //               = External memory Data Width *             //
  //                      Cache Line Size                     //
  // Also, +1 in the width is for dirty bit storage           //                     
  //                                                          //
  //////////////////////////////////////////////////////////////
  reg    [4*32-1+1:0] datamem [65535:0];
  reg    [4*32-1:0]   dmem_mctrl_data_out;  
  reg                 dmem_mctrl_dirtybit,
                      dmem_mctrl_rdy;

  always @( mctrl_dmem_en,mctrl_dmem_rdwr,mctrl_dmem_loc_wr, mctrl_dmem_addr_in,mctrl_dmem_setdirty) 
  begin
    case ({mctrl_dmem_en,mctrl_dmem_rdwr,mctrl_dmem_loc_wr})
      3'b000,3'b001,3'b010,3'b011 : begin 
        dmem_mctrl_rdy = 1'b0;
      end

      // Data memory is read by the main controller entire location or
      // 32 bit
      3'b100,3'b101 : begin
        dmem_mctrl_data_out = datamem[mctrl_dmem_addr_in[17:2]][4*32-1:0];
        dmem_mctrl_dirtybit = datamem[mctrl_dmem_addr_in[17:2]][4*32];
        dmem_mctrl_rdy      = 1'b1;
      end
      
      // Data memory is written from the main controller entire
      // location
      3'b110: begin
        datamem[mctrl_dmem_addr_in[17:2]][4*32-1:0] = mctrl_dmem_data_in;
        case (mctrl_dmem_setdirty)
          1'b0 : begin
            datamem[mctrl_dmem_addr_in[17:2]][4*32] = 1'b0;
          end
          1'b1 : begin
            datamem[mctrl_dmem_addr_in[17:2]][4*32] = 1'b1;
          end
          default : begin
            datamem[mctrl_dmem_addr_in[17:2]][4*32] = 1'b0;
          end
        endcase  
      end

      // Data memory is written from the main controller 32-bit
      3'b111: begin
        case (mctrl_dmem_addr_in[1:0])
          2'b00 : begin
            datamem[mctrl_dmem_addr_in[17:2]][1*32-1:0*32] = mctrl_dmem_data_in[1*32-1:0*32];
          end
          2'b01 : begin
            datamem[mctrl_dmem_addr_in[17:2]][2*32-1:1*32] = mctrl_dmem_data_in[2*32-1:1*32];
          end
          2'b10 : begin
            datamem[mctrl_dmem_addr_in[17:2]][3*32-1:2*32] = mctrl_dmem_data_in[3*32-1:2*32];
          end
          2'b11 : begin
            datamem[mctrl_dmem_addr_in[17:2]][4*32-1:3*32] = mctrl_dmem_data_in[4*32-1:3*32];
          end
          default : begin
            dmem_mctrl_rdy = 1'b0;
          end
        endcase  
        case (mctrl_dmem_setdirty)
          1'b0 : begin
            datamem[mctrl_dmem_addr_in[17:2]][4*32] = 1'b0;
          end
          1'b1 : begin
            datamem[mctrl_dmem_addr_in[17:2]][4*32] = 1'b1;
          end
          default : begin
            datamem[mctrl_dmem_addr_in[17:2]][4*32] = 1'b0;
          end
        endcase  
      end

      default : begin
        dmem_mctrl_rdy = 1'b0;
      end
    endcase
  end
endmodule
