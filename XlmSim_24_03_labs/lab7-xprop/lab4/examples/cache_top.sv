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
// File        : cache_top.sv                                                                 //  
// Description : This is top module of cache controller IP.                                   //  
//                                                                                            //  
module cache_top #(int high = 31)
   (
      // main controller interface
          clk,                 // clock input
		  reset,               // reset input 
		  addr_in,             // address from processor to read the memory
		  data_in,             // data to be written into the memory
		  data_out,            // data read from the memory
		  instr_out,            // data read from the memory
		  data_rdy,            // read data ready
		  rdwr,                // read write input, = 0 read ; = 1 write;
		  req,                 // memory request, = 1 new request; = 0 no request;
		  gnt,                 // memory grant, = 1 grant given; = 0 no grant;
		  hit_miss,            // hit or miss status, = 1 hit; = 0 miss;
		  busy,                // cache busy, = 1 busy; = 0 cache is available;
		  flush,               // cache flush, = 1 cache flush on; = 0 cache flush off;  
	  // external memory interface
		  mem_addr_in,         // external memory address to read
		  mem_data_in,         // data to be written into the external memory
		  mem_data_out,        // data read from the external memory
		  mem_en,              // enable the external memory
		  mem_rdwr,            // read write input to the external memory, = 0 read ; = 1 write;
		  mem_rdy              // external memory read data ready, = 0 read data not ready; = 1 read data done
   );
   //input var packet1::R str;
   //typedef enum logic [1:0] {red, blue, green} colours;
   //parameter type CL = colours;
   //input string str[];
   //input string str;
   //CL col;



   input 
                clk,
		        reset,
		        rdwr,       
		        req,       
		        flush,        
		        mem_rdy;
   input 		 
		 [high:0] addr_in,
		        data_in,   
		        mem_data_out;   


   output
		 [31:0] instr_out;
   output
		 [31:0] data_out,  
		        mem_addr_in,   
		        mem_data_in;
   output	  
		        data_rdy,
				hit_miss,   
		        busy,        
		        gnt,       
		        mem_en,
		        mem_rdwr;        

   // Parameter declaration to configure the cache controller
   // Memory size will determine the cache size,
   // Write details on the each parameters
   parameter   mem_size      = 3'b110;       // Cache memory size = 1 MB
   parameter   cache_org     = 3'b001;       // Cache organisation = direct mapped
   parameter   rep_policy    = 3'b001;       // Replacement policy = update always
   parameter   write_policy  = 2'b10;        // Write policy = write back  
   parameter   line_fill     = 1'b0;         // Line fill = Data requested last
   parameter   burst_en      = 1'b0;         // Burst mode enable = off
   parameter   burst_size    = 3'b000;       // Burst size = single word
   parameter   line_buffer   = 1'b0;         // Line buffer = disabled
			 
   wire	 
	    [17:0]     mctrl_dmem_addr_in;         // need to change the width to make it configurable 
   wire	 
		[31:0]     mctrl_tcmp_addr_in,
		           tcmp_mctrl_addr_out,
	               mctrl_extmem_addr_in;       // need to change the width to make it configurable 
   wire	
   	    [4*32-1:0] mctrl_dmem_data_in,         // need to change the width to make it configurable
   	               mctrl_extmem_data_in,       // need to change the width to make it configurable
   		           dmem_mctrl_data_out,        // need to change the width to make it configurable
   		           extmem_mctrl_data_out;      // need to change the width to make it configurable
   wire	 
                   clk,
			       reset,
   			       pint_mctrl_access,
				   tcmp_mctrl_tagcmp_done,
   			       mctrl_tcmp_tagcmp_en,
   			       dmem_mctrl_rdy,
   			       tcmp_mctrl_hit_miss,
                   mctrl_dmem_en,
                   mctrl_dmem_rdwr,
                   mctrl_dmem_loc_wr,
				   mctrl_dmem_setdirty,
				   dmem_mctrl_dirtybit,
                   mctrl_extmem_en,
                   mctrl_extmem_rdwr,
                   extmem_mctrl_rdy,
                   extmem_mctrl_wrrdy,
                   mctrl_tcmp_tagrdwr;
   
   processor_interface p_int
      (
         .clk(clk),             
         .reset(reset),           
         .top_pint_req(req),    
         .pint_mctrl_access(pint_mctrl_access)	  
	  );

   main_ctrl
     /*  #(
         .mem_size(mem_size),      
         .cache_org(cache_org),    
         .rep_policy(rep_policy),  
		 .write_policy(write_policy),
		 .line_fill(line_fill),  
		 .burst_en(burst_en),  
		 .burst_size(burst_size),
		 .line_buffer(line_buffer)
	  )*/		 
   controller (
        .clk(clk),  
		.reset(reset),      
	  	.extmem_mctrl_rdy(extmem_mctrl_rdy),
	  	.extmem_mctrl_wrrdy(extmem_mctrl_wrrdy),
		.extmem_mctrl_data_out(extmem_mctrl_data_out),
	  	.mctrl_extmem_en(mctrl_extmem_en),
	  	.mctrl_extmem_rdwr(mctrl_extmem_rdwr),
		.mctrl_extmem_addr_in(mctrl_extmem_addr_in),
		.mctrl_extmem_data_in(mctrl_extmem_data_in),
		.mctrl_dmem_en(mctrl_dmem_en),
		.mctrl_dmem_rdwr(mctrl_dmem_rdwr),
		.mctrl_dmem_loc_wr(mctrl_dmem_loc_wr),
		.mctrl_dmem_setdirty(mctrl_dmem_setdirty),
		.mctrl_dmem_addr_in(mctrl_dmem_addr_in),
		.mctrl_dmem_data_in(mctrl_dmem_data_in),
		.dmem_mctrl_data_out(dmem_mctrl_data_out),
		.dmem_mctrl_rdy(dmem_mctrl_rdy),
		.dmem_mctrl_dirtybit(dmem_mctrl_dirtybit),
	    .mctrl_tcmp_tagcmp_en(mctrl_tcmp_tagcmp_en),
	    .mctrl_tcmp_tagrdwr(mctrl_tcmp_tagrdwr),
		.mctrl_tcmp_addr_in(mctrl_tcmp_addr_in),
		.tcmp_mctrl_hit_miss(tcmp_mctrl_hit_miss),
		.tcmp_mctrl_tagcmp_done(tcmp_mctrl_tagcmp_done),
		.tcmp_mctrl_addr_out(tcmp_mctrl_addr_out),
		.pint_mctrl_access(pint_mctrl_access),
		.top_mctrl_addr_in(addr_in),    
		.top_mctrl_data_in(data_in),   
		.top_mctrl_rdwr(rdwr),    
		.top_mctrl_flush(flush), 
		.mctrl_top_rdy(data_rdy),
		.mctrl_top_busy(busy),   
		.mctrl_top_gnt(gnt),   
		.mctrl_top_hit_miss(hit_miss),
		.mctrl_top_data_out(data_out),
		.inst_mem_out(instr_out) 
	  );
	  
   extmem_interface ext_int
      (
        .clk(clk),  
		.reset(reset),      
	    .mctrl_extmem_en(mctrl_extmem_en),
	    .mctrl_extmem_rdwr(mctrl_extmem_rdwr),
		.mctrl_extmem_addr_in(mctrl_extmem_addr_in),
		.mctrl_extmem_data_in(mctrl_extmem_data_in),
		.extmem_mctrl_rdy(extmem_mctrl_rdy),
	  	.extmem_mctrl_wrrdy(extmem_mctrl_wrrdy),
		.extmem_mctrl_data_out(extmem_mctrl_data_out),
	    .extmem_top_en(mem_en),
	    .extmem_top_rdwr(mem_rdwr),
		.extmem_top_addr_in(mem_addr_in),
		.extmem_top_data_in(mem_data_in),
		.top_extmem_data_out(mem_data_out),
		.top_extmem_rdy(mem_rdy)
	  );

   data_mem d_mem
      (
	    .mctrl_dmem_en(mctrl_dmem_en),
		.mctrl_dmem_setdirty(mctrl_dmem_setdirty),
	    .mctrl_dmem_rdwr(mctrl_dmem_rdwr),
	    .mctrl_dmem_loc_wr(mctrl_dmem_loc_wr),
		.mctrl_dmem_addr_in(mctrl_dmem_addr_in),
		.mctrl_dmem_data_in(mctrl_dmem_data_in),
		.dmem_mctrl_data_out(dmem_mctrl_data_out),
		.dmem_mctrl_dirtybit(dmem_mctrl_dirtybit),
		.dmem_mctrl_rdy(dmem_mctrl_rdy)
	  );

   tag_cmp tag_compare
      (
	    .mctrl_tcmp_tagcmp_en(mctrl_tcmp_tagcmp_en),
	    .mctrl_tcmp_tagrdwr(mctrl_tcmp_tagrdwr),
		.mctrl_tcmp_tagaddr_in(mctrl_tcmp_addr_in),
		.tcmp_mctrl_addr_out(tcmp_mctrl_addr_out),
		.tcmp_mctrl_hit_miss(tcmp_mctrl_hit_miss),
		.tcmp_mctrl_tagcmp_done(tcmp_mctrl_tagcmp_done)
	  );


/*
  property x_instr_out;
    @(negedge data_rdy) (!$isunknown(instr_out));
  endproperty
  assert property (x_instr_out);
*/
endmodule


