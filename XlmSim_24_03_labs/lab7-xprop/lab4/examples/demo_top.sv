// IVB checksum: 3625011654
/*-----------------------------------------------------------------
File name     : demo_top.sv
Developers    : araheja
Created       : Wed Nov  2 11:42:23 2011 
Description   :
Notes         :
-------------------------------------------------------------------
Copyright  (c)2011 
-----------------------------------------------------------------*/

//`include "dut_dummy.v"
`include "cache_pkg_if.sv"
`include "cache_pkg_pkg.sv"

module demo_top;
  
  // Import UVM Package
  import uvm_pkg::*;

  // Import the CACHE_PKG UVC Package
  import cache_pkg_pkg::*;

  // Include the test library
  `include "test_lib.sv"

  // clock, reset are generated here for this DUT
  reg reset;
  reg clock; 

  // CACHE_PKG Interface to the DUT
  cache_pkg_if cache_pkg_if(clock, reset);

/*
  dut_dummy dut(
    .reset(reset),
    .clock(clock),
    // CACHE_PKG interface signals connection
    .cache_pkg_data(cache_pkg_if.sig_data),
    .cache_pkg_valid(cache_pkg_if.sig_valid),
    .cache_pkg_ack(cache_pkg_if.sig_ack)
  );
*/
  initial begin
    run_test();
  end

  initial begin
    reset <= 1'b0;
    clock <= 1'b0;
    #51 reset = 1'b1;
  end

  //Generate Clock
  always
    #5 clock = ~clock;


   logic [31:0] ADDR_IN;
   logic [31:0] DATA_IN;
   wire logic [31:0] DATA_OUT;
//   wire logic [31:0] INSTR_OUT;
   logic [31:0] INSTR_OUT;
   wire logic DATA_RDY ;           // read data ready
   logic		 RDWR ;               // read write input, = 0 read ; = 1 write;
logic		 REQ ;                // memory request, = 1 new request; = 0 no request;
wire 	     GNT;                 // memory grant, = 1 grant given; = 0 no grant;
wire		 HIT_MISS;            // hit or miss status, = 1 hit; = 0 miss;
wire		 BUSY;                // cache busy, = 1 busy; = 0 cache is available;
logic		 FLUSH;               // cache flush, = 1 cache flush on; = 0 cache flush off;  
wire   logic [31:0] MEM_ADDR_IN;
wire   logic [31:0] MEM_DATA_IN;
       logic [31:0] MEM_DATA_OUT;
wire   logic        MEM_EN;              // enable the external memory
wire		        MEM_RDWR;            // read write input to the external memory, = 0 read ; = 1 write;
logic		        MEM_RDY;             // external memory read data ready, = 0 read data not ready; = 1 read data done
   

   cache_top  dut (
                  // main controller interface
                  clock,                 // clock input
		          reset,               // reset input 
		          ADDR_IN,             // address from processor to read the memory
		          DATA_IN,             // data to be written into the memory
		          DATA_OUT,            // data read from the memory
		          INSTR_OUT,            // data read from the memory
		          DATA_RDY,            // read data ready
		          RDWR,                // read write input, = 0 read ; = 1 write;
		          REQ,                 // memory request, = 1 new request; = 0 no request;
		          GNT,                 // memory grant, = 1 grant given; = 0 no grant;
		          HIT_MISS,            // hit or miss status, = 1 hit; = 0 miss;
		          BUSY,                // cache busy, = 1 busy; = 0 cache is available;
		          FLUSH,               // cache flush, = 1 cache flush on; = 0 cache flush off;  
	              // external memory interface
		          MEM_ADDR_IN,         // external memory address to read
		          MEM_DATA_IN,         // data to be written into the external memory
		          MEM_DATA_OUT,        // data read from the external memory
		          MEM_EN,              // enable the external memory
		          MEM_RDWR,            // read write input to the external memory, = 0 read ; = 1 write;
		          MEM_RDY              // external memory read data ready, = 0 read data not ready; = 1 read data done
                  );
   

   assign ADDR_IN = cache_pkg_if.addr_in;
   assign DATA_IN = cache_pkg_if.data_in;
   assign cache_pkg_if.data_out = DATA_OUT;
   assign cache_pkg_if.instr_out = INSTR_OUT;
   assign cache_pkg_if.data_rdy = DATA_RDY;
   assign RDWR = cache_pkg_if.rdwr;
   assign REQ = cache_pkg_if.req;
   assign cache_pkg_if.gnt = GNT;
   assign cache_pkg_if.hit_miss = HIT_MISS;
   assign cache_pkg_if.busy = BUSY;
   assign FLUSH = cache_pkg_if.flush;
   assign cache_pkg_if.mem_addr_in = MEM_ADDR_IN;
   assign cache_pkg_if.mem_data_in = MEM_DATA_IN;
   assign MEM_DATA_OUT = cache_pkg_if.mem_data_out;
   assign cache_pkg_if.mem_en = MEM_EN;
   assign cache_pkg_if.mem_rdwr = MEM_RDWR;
   assign MEM_RDY = cache_pkg_if.mem_rdy;



   logic [31:0] memory [0:8*65536-1];

   task spec();
     $display("calling from specman");
   endtask

   task preload_cache();
      for (int i = 0; i < ((8*65536)-1) ; i++)
	  begin
		 cache_pkg_cache_slave_agent_driver::mem[i] = memory[i];
		 golden_mem::mem[i]         = memory [i];
	  end
   endtask

   task automatic preload_golden_tag(ref [13:0] tag_mem[65535:0]);
      for (int i = 0; i < ((2**18)-1) ; i++)
	  begin
		 cache_slave_checker::tag_mem[i] = tag_mem[i];
	  end
   endtask

   initial begin
      $readmemb("./preload/extmem.txt",memory,0,8*65536-1);
      $readmemb("./preload/readable_datamem.txt",demo_top.dut.d_mem.datamem,0,65536-1);
      $readmemb("./preload/tagmem.txt",demo_top.dut.tag_compare.memory,0,65536-1);
      preload_cache();
      preload_golden_tag(demo_top.dut.tag_compare.memory);
   end


  property x_instr_out;
    @(negedge DATA_RDY) (!$isunknown(INSTR_OUT));
  endproperty
  assert property (x_instr_out);
endmodule
