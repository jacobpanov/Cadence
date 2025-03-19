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
// File        : main_ctrl.sv                                                                 //  
// Description : This is main controller of cache controller IP.                              //  
//                                                                                            //  
////////////////////////////////////////////////////////////////////////////////////////////////

module main_ctrl 
   (
      //top level clock and reset  
     clk,                           // clock input
     reset,                         // reset input
     
     // external memory interface 
     extmem_mctrl_rdy,              // external memory read data ready, = 0 read data not ready; = 1 read data done
     extmem_mctrl_wrrdy,            // external memory write data ready, = 0 write data not ready; = 1 write data done
     extmem_mctrl_data_out,         // data read from the external memory
     mctrl_extmem_en,               // Enable the external memory interface
     mctrl_extmem_rdwr,             // read write input, = 0 read ; = 1 write;
     mctrl_extmem_addr_in,          // external memory address to read
     mctrl_extmem_data_in,          // data to be written into the external memory

     // Data memory interface
     dmem_mctrl_data_out,           // data read from the cache data memory
     dmem_mctrl_rdy,                // cache memory read data ready, = 0 read data not ready; = 1 read data done 
     dmem_mctrl_dirtybit,           // Dirty Bit, = 1 dirty; = 0 no dirty;
     mctrl_dmem_en,                 // Enable the data memory
     mctrl_dmem_rdwr,               // read write input, = 0 read ; = 1 write;
     mctrl_dmem_loc_wr,             // Location write input, = 0 full location; = 1 write 32-bit;
     mctrl_dmem_setdirty,           // Set Dirty Bit, 1 = set dirty, 0 = dont set dirty
     mctrl_dmem_addr_in,            // address from main controller to read the cache data memory
     mctrl_dmem_data_in,            // data to be written into the cache data memory

     // Tag comparision interface    
     tcmp_mctrl_addr_out,           // address from the comparision block  to main controller for the write back
     tcmp_mctrl_hit_miss,           // hit or miss status, = 1 hit; = 0 miss;
     tcmp_mctrl_tagcmp_done,        // Tag comparision done, = 1 done; = 0 not done;
     mctrl_tcmp_tagcmp_en,          // enable tag compare
     mctrl_tcmp_tagrdwr,            // read write input, = 0 read ; = 1 write;
     mctrl_tcmp_addr_in,            // address from main controller to read the tag memory

     // top level interface    
     pint_mctrl_access,             // access to main controller; = 1 access on; = 0 no access;   
     top_mctrl_addr_in,             // address from processor to read the memory
     top_mctrl_data_in,             // data to be written into the memory
     top_mctrl_rdwr,                // read write input, = 0 read ; = 1 write;
     top_mctrl_flush,               // cache flush, = 1 cache flush on; = 0 cache flush off;  
     mctrl_top_rdy,                 // Data for processor read ready, = 0 read data not ready; = 1 read data done 
     mctrl_top_busy,                // cache busy, = 1 busy; = 0 cache is available;
     mctrl_top_gnt,                 // Grant for request,  = 1 grant given; = 0 No grant;
     mctrl_top_hit_miss,            // hit or miss status, = 1 hit; = 0 miss;
     mctrl_top_data_out,             // data read from the memory
     inst_mem_out                  // data read from the memory
   );

   input
                     clk,  
                     reset,    
                     extmem_mctrl_rdy,
                     extmem_mctrl_wrrdy,
                     dmem_mctrl_rdy,
                     dmem_mctrl_dirtybit,
                     tcmp_mctrl_hit_miss,
                     tcmp_mctrl_tagcmp_done,
                     pint_mctrl_access,
                     top_mctrl_rdwr,    
                     top_mctrl_flush; 
   input 
          [4*32-1:0] extmem_mctrl_data_out,
                     dmem_mctrl_data_out;
   input 
          [31:0]     top_mctrl_addr_in,
                     top_mctrl_data_in,
                     tcmp_mctrl_addr_out;   

   output
          [17:0]     mctrl_dmem_addr_in;
   output
          [31:0]     mctrl_extmem_addr_in,
                     mctrl_top_data_out;
   output
          [4*32-1:0] mctrl_extmem_data_in,
                     mctrl_dmem_data_in;
   output   
                     mctrl_dmem_en,
                     mctrl_dmem_rdwr,
                     mctrl_dmem_loc_wr,
                     mctrl_dmem_setdirty,
                     mctrl_tcmp_tagcmp_en,
                     mctrl_tcmp_tagrdwr,
                     mctrl_extmem_en,
                     mctrl_extmem_rdwr,
                     mctrl_top_busy,   
                     mctrl_top_gnt,
                     mctrl_top_hit_miss,
                     mctrl_top_rdy;
   output       
          [31:0]     mctrl_tcmp_addr_in;
   output       
          [31:0]     inst_mem_out;
   reg [31:0] inst_mem_out;

   // Parameter declaration to configure the cache controller
   // Memory size will determine the cache size,
   // Write details on the each parameters
   parameter  mem_size      = 3'b110;       // Cache memory size = 1 MB
   parameter  cache_org     = 3'b001;       // Cache organisation = direct mapped
   parameter  rep_policy    = 3'b001;       // Replacement policy = update always
   parameter  write_policy  = 2'b10;        // Write policy = write back  
   parameter  line_fill     = 1'b0;         // Line fill = Data requested last
   parameter  burst_en      = 1'b0;         // Burst mode enable = off
   parameter  burst_size    = 3'b000;       // Burst size = single word
   parameter  line_buffer   = 1'b0;         // Line buffer = disabled
   parameter  min_valid_addr= 10;         // valid address range
   parameter  max_valid_addr= 20;         // valid address range

   reg
      [17:0]     mctrl_dmem_addr_in;
   reg
      [31:0]     mctrl_extmem_addr_in,
                 mctrl_top_data_out;
   reg
      [4*32-1:0] mctrl_extmem_data_in,
                 mctrl_dmem_data_in;
   reg   
                 mctrl_dmem_en,
                 mctrl_dmem_rdwr,
                 mctrl_dmem_loc_wr,
                 mctrl_dmem_setdirty,
                 mctrl_tcmp_tagcmp_en,
                 mctrl_tcmp_tagrdwr,
                 mctrl_extmem_en,
                 mctrl_extmem_rdwr,
                 mctrl_top_busy,   
                 mctrl_top_gnt,
                 mctrl_top_hit_miss,
                 mctrl_top_rdy;
   reg       
      [31:0]     mctrl_tcmp_addr_in;

   reg 
                 op_rdwr;
   reg 
      [31:0]     op_addr_in,
                 op_data_in;

  enum {IDLE, TAG_CMP, WRITE_BACK, READ_MEM} next_state;


  //xprop related registers
  reg[31:0] mem1, mem2;
  parameter fifo_depth = 20;
  reg [31:0] fifo_addr_in[fifo_depth];
  reg [31:0] fifo_data_in[fifo_depth];
  reg        fifo_rdwr[fifo_depth];
  int depth = 0;
  reg inst_mem_en;



  /////////////////////////////////////////////////////////////////////////
  // This is the sequential block where state machine is sampled on each //
  // posedge of the clock. This block also does the reset.               //
  /////////////////////////////////////////////////////////////////////////
  always @(posedge clk or negedge reset) begin
    if (reset == 1'b0) begin
      mctrl_extmem_en       <= 1'b0;
      mctrl_extmem_rdwr     <= 1'b0; 
      mctrl_top_rdy         <= 1'b0;
      mctrl_top_gnt         <= 1'b0;
      mctrl_top_busy        <= 1'b0;
      mctrl_tcmp_tagcmp_en  <= 1'b0;
      mctrl_tcmp_tagrdwr    <= 1'b0; 
      mctrl_dmem_en         <= 1'b0;  
      mctrl_dmem_rdwr       <= 1'b0;
      mctrl_dmem_loc_wr     <= 1'b0;
      mctrl_dmem_setdirty   <= 1'b0;
      next_state            <= IDLE;
      mem1                  <= 32'hF0F0;
      mem2                  <= 32'hF00F;
      inst_mem_en           <= 1'b0;
    end 
    else begin
      case (next_state)
        ////////////////////////////////////////////////////////////////////
        // IDLE state:                                                    // 
        //     Idle state waits for request from the processor            //
        //                                                                // 
        //  Once request is there:                                        //
        //     1. It will assert the grant for one clock cycle            //
        //        and will also assert the busy.                          //
        //     2. It stores the rdwr, addr and data from the processor in //
        //        the local register.                                     //
        //     3. It enables the tagmemory in read mode (through tag      //
        //        compare block) and passes the addr for comparision      //
        //     4. It enables the data memory in the read mode and passes  //
        //        the 17:0 address bits to the data memory                //
        //     5. It moves to tag_cmp state                               //   
        ////////////////////////////////////////////////////////////////////
        IDLE : begin
          mctrl_top_rdy   <= 1'b0;
          case (pint_mctrl_access)
            1'b0 : begin
              mctrl_top_gnt         <= 1'b0;
              mctrl_top_busy        <= 1'b0;
              mctrl_tcmp_tagcmp_en  <= 1'b0;
              mctrl_tcmp_tagrdwr    <= 1'b0; 
              mctrl_dmem_en         <= 1'b0;  
              mctrl_dmem_rdwr       <= 1'b0;
              mctrl_dmem_loc_wr     <= 1'b0;
              mctrl_dmem_setdirty   <= 1'b0;
              mctrl_extmem_en       <= 1'b0;
              next_state            <= IDLE;
            end
            1'b1 : begin
              mctrl_top_gnt         <= 1'b1;
              mctrl_top_busy        <= 1'b1;
              op_rdwr               <= top_mctrl_rdwr;
              op_addr_in            <= top_mctrl_addr_in;
              op_data_in            <= top_mctrl_data_in;
              mctrl_tcmp_tagcmp_en  <= 1'b1;
              mctrl_tcmp_tagrdwr    <= 1'b0; 
              mctrl_tcmp_addr_in    <= top_mctrl_addr_in;
              mctrl_dmem_en         <= 1'b1;  
              mctrl_dmem_rdwr       <= 1'b0;
              mctrl_dmem_loc_wr     <= 1'b0;
              mctrl_dmem_addr_in    <= top_mctrl_addr_in[17:0];
              next_state            <= TAG_CMP;
            end
            default : begin
              mctrl_top_gnt         <= 1'b0;
              mctrl_top_busy        <= 1'b0;
              mctrl_tcmp_tagcmp_en  <= 1'b0;
              mctrl_tcmp_tagrdwr    <= 1'b0; 
              mctrl_dmem_en         <= 1'b0;  
              mctrl_dmem_rdwr       <= 1'b0;
              mctrl_dmem_loc_wr     <= 1'b0;
              mctrl_dmem_setdirty   <= 1'b0;
              mctrl_extmem_en       <= 1'b0;
              next_state            <= IDLE;
            end
          endcase  
        end

        ////////////////////////////////////////////////////////////////////
        // TAG_CMP state:                                                 // 
        //     Tag cmp state waits for tag_cmp_done status                //
        //                                                                // 
        //  Once tag_cmp_done is asserted from tag comparision block, it  //
        //  checks for the hitmiss status from the tag comparision block  //
        //  and read-write operation.                                     //  
        //     rdwr  hitmiss   Cache Status                               //
        //      0     0         Read miss                                 // 
        //      0     1         Read hit                                  // 
        //      1     0         Write miss                                // 
        //      1     1         Write hit                                 // 
        ////////////////////////////////////////////////////////////////////
        TAG_CMP : begin
          mctrl_top_gnt         <= 1'b0;
          case({tcmp_mctrl_tagcmp_done,op_rdwr,tcmp_mctrl_hit_miss})
            3'b000,3'b001,3'b010,3'b011    : begin
              next_state         <= TAG_CMP;
            end 
      
            ////////////////////////////////////////////////////////////////////
            // Read miss or Write miss in TAG_CMP state:                      // 
            //     Tag cmp state will disable the operation in the tag memory //
            //     and data memory by disabling the respective enables. It    //
            //     also passes the hit miss status to the top.                //
            //                                                                //
            //     It checks for the dirty bit.                               //
            //     Dirty bit = 0 ; data in data memory needs no write back,   //
            //     read the memory directly. It will:                         //
            //     1. Enable the external memory in the read mode and passes  //
            //        the registered address.                                 //
            //     2. State moves to the READ_MEM                             //
            //                                                                // 
            //     Dirty bit = 1 ; data in data memory need write back, write // 
            //     the data from the data memory into the external memory It  //
            //     will:                                                      //
            //     1. Enable the external memory in the write mode and passes //
            //        the address from the compare block and passes the entire//
            //        data from the data memory                               //
            //     2. State moves to the WRITEBACK                            //
            ////////////////////////////////////////////////////////////////////
            3'b100,3'b110 : begin
              mctrl_top_hit_miss    <= tcmp_mctrl_hit_miss;
              mctrl_tcmp_tagcmp_en  <= 1'b0;
              mctrl_dmem_en         <= 1'b0;  
              case (dmem_mctrl_dirtybit)
                1'b0 : begin
                  mctrl_extmem_en       <= 1'b1;
                  mctrl_extmem_rdwr     <= 1'b0;
                  mctrl_extmem_addr_in  <= {op_addr_in[31:2],2'b00};
                  next_state            <= READ_MEM;
                end
                1'b1 : begin
                  case (dmem_mctrl_rdy)
                    1'b0 : begin
                      next_state <= TAG_CMP;
                    end
                    1'b1 : begin
                      mctrl_extmem_en       <= 1'b1;
                      mctrl_extmem_rdwr     <= 1'b1;
                      mctrl_extmem_addr_in  <= tcmp_mctrl_addr_out;
                      mctrl_extmem_data_in  <= dmem_mctrl_data_out;
                      next_state            <= WRITE_BACK;
                    end
                    default : begin
                      next_state <= TAG_CMP;
                    end
                  endcase  
                end
                default : begin
                  next_state <= TAG_CMP;
                end
              endcase  
            end 
        
            ////////////////////////////////////////////////////////////////////
            // Read hit in TAG_CMP state:                                     // 
            //     Tag cmp state will disable the operation in the tag memory //
            //     and data memory by disabling the respective enables. It    //
            //     also passes the hit miss status to the top.                //
            //                                                                //
            //     It waits for the data memory ready                         //
            //     Once the data memory is ready it will:                     //
            //     1. Based on the last two bits of the address, send out     //
            //        the data memory data to the top and will also assert    //
            //        top ready signal.                                       //
            //     2. State will move to idle waiting for new request with    //
            //        busy de-asserted.                                       //       
            ////////////////////////////////////////////////////////////////////
            3'b101 : begin
              mctrl_top_hit_miss    <= tcmp_mctrl_hit_miss;
              mctrl_tcmp_tagcmp_en  <= 1'b0;
              mctrl_dmem_en         <= 1'b0;  
              case (dmem_mctrl_rdy)
                1'b0 : begin
                  next_state <= TAG_CMP;
                end
                1'b1 : begin
                  mctrl_top_rdy   <= 1'b1;
                  case (op_addr_in[1:0])
                    2'b00 : begin
                      mctrl_top_data_out <= dmem_mctrl_data_out[1*32-1:0*32];
                    end
                    2'b01 : begin
                      mctrl_top_data_out <= dmem_mctrl_data_out[2*32-1:1*32];
                    end
                    2'b10 : begin
                      mctrl_top_data_out <= dmem_mctrl_data_out[3*32-1:2*32];
                    end
                    2'b11 : begin
                      mctrl_top_data_out <= dmem_mctrl_data_out[4*32-1:3*32];
                    end
                    default : begin
                      next_state <= TAG_CMP;
                    end
                  endcase  
                  mctrl_top_busy        <= 1'b0;
                  next_state            <= IDLE;
                end
                default : begin
                  next_state <= TAG_CMP;
                end
              endcase  
            end 

            ////////////////////////////////////////////////////////////////////
            // Write hit in TAG_CMP state:                                    // 
            //     Tag cmp state will disable the operation in the tag memory //
            //     by disabling enable. It also passes the hit miss status to //
            //     the top.                                                   //
            //                                                                //
            //     It enables the data memory in the write mode and           // 
            //     1. Passes the registered address                           //
            //     2. Sets the word write to '1'(mctrl_dmem_loc_wr).          //
            //     3. Sets the dirty bit to one (mctrl_dmem_setdirty).        //
            //     4. Based on last two bits of the registered address, it    //
            //        passes the data to the data memory                      //
            //     5. State will move to idle waiting for new request with    //
            //        busy de-asserted.                                       //       
            ////////////////////////////////////////////////////////////////////
            3'b111 : begin
              mctrl_tcmp_tagcmp_en  <= 1'b0;
              mctrl_top_hit_miss    <= tcmp_mctrl_hit_miss;
              mctrl_dmem_en         <= 1'b1;  
              mctrl_dmem_rdwr       <= 1'b1;
              mctrl_dmem_addr_in    <= op_addr_in[17:0];
              mctrl_dmem_loc_wr     <= 1'b1;
              mctrl_dmem_setdirty   <= 1'b1;
              case (op_addr_in[1:0])
                2'b00 : begin
                  mctrl_dmem_data_in[1*32-1:0*32] <= op_data_in;
                end
                2'b01 : begin
                  mctrl_dmem_data_in[2*32-1:1*32] <= op_data_in;
                end
                2'b10 : begin
                  mctrl_dmem_data_in[3*32-1:2*32] <= op_data_in;
                end
                2'b11 : begin
                  mctrl_dmem_data_in[4*32-1:3*32] <= op_data_in;
                end
                default : begin
                  next_state         <= TAG_CMP;
                end
              endcase  
              mctrl_top_busy        <= 1'b0;
              next_state            <= IDLE;
            end 
            default : begin
              next_state         <= TAG_CMP;
            end
          endcase
        end

        ////////////////////////////////////////////////////////////////////
        // WRITE BACK state:                                              // 
        //     Write back state waits external memory ready.              //
        //                                                                // 
        //  Once external memory is ready, it will:                       //
        //     1. Enable the external memory in the read mode and passes  //
        //        the registered address.                                 //
        //     2. Stae will move to READMEM                               //
        ////////////////////////////////////////////////////////////////////
        WRITE_BACK : begin
          mctrl_extmem_en       <= 1'b0;
          case (extmem_mctrl_wrrdy)
            1'b0 : begin
              next_state <= WRITE_BACK;
            end
            1'b1 : begin
              mctrl_extmem_en       <= 1'b1;
              mctrl_extmem_rdwr     <= 1'b0;
              mctrl_extmem_addr_in  <= {op_addr_in[31:2],2'b00};
              next_state <= READ_MEM;
            end
            default : begin
              next_state <= WRITE_BACK;
            end
          endcase  
        end

        ////////////////////////////////////////////////////////////////////
        // READ MEMORY state:                                             // 
        //     Read memory state waits external memory ready.             //
        //                                                                // 
        //  Once external memory is ready, it will:                       //
        //  1. Enable the tag memory in write mode and passes the         //
        //     registered address.                                        //
        //  2. Enable the data memory in write mode and passes the 17:0   //
        //     address bits, external memory data will be passed to the   //
        //     data memory [This is the updatation of cache with miss     //
        //     data both in read and write] and sets the dirty bit to '0' //
        //  3. Based on registered read-write operation, it will:         //
        //      3.a For read operation, based on last two bits of addr    //
        //          will pass the external memory data to the top and     //
        //          assert the top ready signal                           //
        //      3.b For write, it will write the 32-bit data from top to  //
        //          the cache location based on last two bits of addr     //
        //  4. State will move to IDLE state in both 3.a and 3.b. Also    //
        //     Busy will be deasserted in both cases.                     // 
        ////////////////////////////////////////////////////////////////////
        READ_MEM : begin
          mctrl_extmem_en       <= 1'b0;
          case (extmem_mctrl_rdy)
            1'b0 : begin
              next_state <= READ_MEM;
            end
            1'b1 : begin
              mctrl_tcmp_tagcmp_en  <= 1'b1;
              mctrl_tcmp_tagrdwr    <= 1'b1; 
              mctrl_tcmp_addr_in    <= op_addr_in;
              mctrl_dmem_en         <= 1'b1;  
              mctrl_dmem_rdwr       <= 1'b1;
              mctrl_dmem_loc_wr     <= 1'b0;
              mctrl_dmem_addr_in    <= op_addr_in[17:0];
              case (op_rdwr)
                1'b0 : begin
                  mctrl_dmem_data_in  <= extmem_mctrl_data_out;
                  mctrl_dmem_setdirty <= 1'b0;
                  mctrl_top_rdy       <= 1'b1;
                  case (op_addr_in[1:0])
                    2'b00 : begin
                      mctrl_top_data_out <= extmem_mctrl_data_out[1*32-1:0*32];
                    end
                    2'b01 : begin
                      mctrl_top_data_out <= extmem_mctrl_data_out[2*32-1:1*32];
                    end
                    2'b10 : begin
                      mctrl_top_data_out <= extmem_mctrl_data_out[3*32-1:2*32];
                    end
                    2'b11 : begin
                      mctrl_top_data_out <= extmem_mctrl_data_out[4*32-1:3*32];
                    end
                    default : begin
                      next_state <= READ_MEM;
                    end
                  endcase  
                  mctrl_top_busy        <= 1'b0;
                  next_state <= IDLE;
                end
                1'b1 : begin
                  mctrl_dmem_setdirty <= 1'b1;
                  case (op_addr_in[1:0])
                    2'b00 : begin
                      mctrl_dmem_data_in[4*32-1:1*32] <= extmem_mctrl_data_out[4*32-1:1*32];
                      mctrl_dmem_data_in[1*32-1:0*32] <= op_data_in;
                    end
                    2'b01 : begin
                      mctrl_dmem_data_in[4*32-1:2*32] <= extmem_mctrl_data_out[4*32-1:2*32];
                      mctrl_dmem_data_in[2*32-1:1*32] <= op_data_in;
                      mctrl_dmem_data_in[1*32-1:0*32] <= extmem_mctrl_data_out[1*32-1:0*32];
                    end
                    2'b10 : begin
                      mctrl_dmem_data_in[4*32-1:3*32] <= extmem_mctrl_data_out[4*32-1:3*32];
                      mctrl_dmem_data_in[3*32-1:2*32] <= op_data_in;
                      mctrl_dmem_data_in[2*32-1:0*32] <= extmem_mctrl_data_out[2*32-1:0*32];
                    end
                    2'b11 : begin
                      mctrl_dmem_data_in[4*32-1:3*32] <= op_data_in;
                      mctrl_dmem_data_in[3*32-1:0*32] <= extmem_mctrl_data_out[3*32-1:0*32];
                    end
                    default : begin
                      next_state <= READ_MEM;
                    end
                  endcase  
                  mctrl_top_busy   <= 1'b0;
                  next_state       <= IDLE;
                end
                default : begin
                  next_state <= READ_MEM;
                end
              endcase  
            end
            default : begin
              next_state <= READ_MEM;
            end
          endcase  
        end
        default : begin
          mctrl_top_gnt         <= 1'b0;
          mctrl_top_busy        <= 1'b0;
          mctrl_tcmp_tagcmp_en  <= 1'b0;
          mctrl_tcmp_tagrdwr    <= 1'b0; 
          mctrl_dmem_en         <= 1'b0;  
          mctrl_dmem_rdwr       <= 1'b0;
          mctrl_dmem_loc_wr     <= 1'b0;
          mctrl_dmem_setdirty   <= 1'b0;
          mctrl_extmem_en       <= 1'b0;
          next_state            <= IDLE;
        end
      endcase  
    end
  end


  always @(posedge mctrl_top_busy) begin
              fifo_rdwr[depth]               <= top_mctrl_rdwr;
              fifo_addr_in[depth]            <= top_mctrl_addr_in;
              fifo_data_in[depth]            <= top_mctrl_data_in;
              if(top_mctrl_addr_in < min_valid_addr)
                inst_mem_en = 1'b1;
              else if(top_mctrl_addr_in > min_valid_addr && top_mctrl_addr_in < max_valid_addr)
                inst_mem_en = 1'b0;
              else
                inst_mem_en = 1'bx;

              depth++;
  end
  

  always @(negedge mctrl_top_busy)
  begin
  if(!top_mctrl_rdwr)
    if(inst_mem_en)
      inst_mem_out <= mem1;
    else
      inst_mem_out <= mem2;
  end

endmodule
