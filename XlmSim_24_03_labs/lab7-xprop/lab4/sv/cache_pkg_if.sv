// IVB checksum: 1581074064
/*-----------------------------------------------------------------
File name     : cache_pkg_if.sv
Developers    : araheja
Created       : Wed Nov  2 11:42:23 2011
Description   :
Notes         :
-------------------------------------------------------------------
Copyright  (c)2011 
-----------------------------------------------------------------*/

interface cache_pkg_if (input clock, input reset );

  // Import UVM package
  import uvm_pkg::*;
  `include "uvm_macros.svh" 

  `define ADDR_WIDTH 32
  `define DATA_WIDTH 32

  /***************************************************************************
   IVB-NOTE : REQUIRED : UVC signal definitions : signals definitions
   -------------------------------------------------------------------------
   Adjust the signal names and add any necessary signals.
   Note that if you change a signal name, you must change it in all of your
   UVC files.
   ***************************************************************************/

  // Actual Signals
  logic sig_valid;
  logic sig_ack;
  logic [31:0] sig_data;
  
  // Control flags
  bit has_checks = 1;
  bit has_coverage = 1;

  // Coverage and assertions to be implemented here
  /***************************************************************************
   IVB-NOTE : REQUIRED : Assertion checks : Interface
   -------------------------------------------------------------------------
   Add assertion checks as required.
   ***************************************************************************/

  // SVA default clocking
  wire uvm_assert_clk = clock && has_checks;
  default clocking master_clk @(negedge uvm_assert_clk);
  endclocking
 
  // SVA Default reset
//  default disable iff (reset);

  // Data must not be X or Z during Data Phase (when valid is raised)
  assertValidAndData: assert property (
    ($rose(sig_valid) |=> !$isunknown(sig_data)))
  else 
    `uvm_error("ERR_DATA_XZ", "Data went to X or Z during Data Phase")

   // main controller interface
   logic [`ADDR_WIDTH-1:0] addr_in;             // address from processor to read the memory
   logic [`DATA_WIDTH-1:0] data_in;             // data to be written into the memory
   logic [`DATA_WIDTH-1:0] data_out;            // data read from the memory
   logic [`DATA_WIDTH-1:0] instr_out;            // data read from the memory
   logic data_rdy;            // read data ready
   logic rdwr;                // read write input, = 0 read ; = 1 write;
   logic req;                 // memory request, = 1 new request; = 0 no request;
   logic gnt;                 // memory grant, = 1 grant given; = 0 no grant;
   logic hit_miss;            // hit or miss status, = 1 hit; = 0 miss;
   logic busy;                // cache busy, = 1 busy; = 0 cache is available;
   logic flush;               // cache flush, = 1 cache flush on; = 0 cache flush off;  
   // external memory interface
   logic [`ADDR_WIDTH-1:0] mem_addr_in;         // external memory address to read
   logic [`DATA_WIDTH-1:0] mem_data_in;         // data to be written into the external memory
   logic [`DATA_WIDTH-1:0] mem_data_out;        // data read from the external memory
   logic                  mem_en;              // enable the external memory
   logic                  mem_rdwr;            // read write input to the external memory, = 0 read ; = 1 write;
   logic                  mem_rdy;             // external memory read data ready, = 0 read data not ready; = 1 read data done



  logic [`ADDR_WIDTH-1:0] max_addr_range = 262148;
  logic [`ADDR_WIDTH-1:0] min_addr_range = 262142;
  
  clocking cb @ (posedge clock);
    input addr_in;
    input min_addr_range;
  endclocking

  modport master (clocking cb);


//  property x_instr_out;
  //  @(negedge data_rdy) (!$isunknown(instr_out));
  //endproperty
//  assert property (x_instr_out);

  property x_data_out;
    @(negedge data_rdy) (!$isunknown(data_out));
  endproperty
  assert property (x_data_out);

  property x_gnt_out;
    @(negedge clock) (!$isunknown(gnt));
  endproperty
  assert property (x_gnt_out);

  property x_data_rdy_out;
    @(negedge clock) (!$isunknown(data_rdy));
  endproperty
  assert property (x_data_rdy_out);

  property x_busy_out;
    @(negedge clock) (!$isunknown(busy));
  endproperty
  assert property (x_busy_out);

endinterface : cache_pkg_if

