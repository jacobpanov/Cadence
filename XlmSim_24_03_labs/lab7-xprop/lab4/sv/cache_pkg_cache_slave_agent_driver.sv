// IVB checksum: 3258590357
/*-----------------------------------------------------------------
File name     : cache_pkg_cache_slave_agent_driver.sv
Developers    : araheja
Created       : Wed Nov  2 11:42:23 2011
Description   : This file implements the cache_slave_agent driver functionality
Notes         : 
-------------------------------------------------------------------
Copyright  (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: cache_pkg_cache_slave_agent_driver
//
//------------------------------------------------------------------------------

  /***************************************************************************
   IVB-NOTE : REQUIRED : cache_slave_agent DRIVER functionality : DRIVER
   -------------------------------------------------------------------------
   Modify the following methods to match your protocol:
     o respond_cache_packet() - response driving
     o reset_signals() - cache_slave_agent signals reset values
   Note that if you change/add signals to the physical interface, you must
   also change these methods.
   ***************************************************************************/

class cache_pkg_cache_slave_agent_driver extends uvm_driver #(cache_pkg_cache_packet);

  // The virtual interface used to drive and view HDL signals.
  protected virtual interface cache_pkg_if vif;
    
  // Count cache_packet_responses sent
  int num_sent;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils(cache_pkg_cache_slave_agent_driver)

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  static data_type mem[addr_type];

  function data_type pop_data(addr_type addr);
    if (mem.exists(addr))
      return mem[addr];
    else
      return ('hFFFF);
  endfunction // pop_data

  function void push_data(addr_type addr, data_type data);
    mem[addr] = data;
  endfunction // push_data


  // Additional class methods
  extern virtual task run_phase(uvm_phase phase);
  extern virtual protected task get_and_drive();
  extern virtual protected task reset_signals();
  extern virtual protected task send_response(cache_pkg_cache_packet response);
  extern virtual function void report_phase(uvm_phase phase);
  extern task read_op();
  extern task write_op();


  virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);

    if(!uvm_config_db#(virtual cache_pkg_if)::get(this,"","vif",vif))
	`uvm_error(get_type_name(),"virtual if not configured");

  endfunction
endclass : cache_pkg_cache_slave_agent_driver

  // UVM run() phase
  task cache_pkg_cache_slave_agent_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      get_and_drive();
      reset_signals();
    join
  endtask 

  task cache_pkg_cache_slave_agent_driver::read_op();
    vif.mem_rdy = 'b1;
    vif.mem_data_out = pop_data(vif.mem_addr_in);
    repeat(3) begin
      @(negedge vif.clock)
        if (vif.mem_en && !(vif.mem_rdwr))
          vif.mem_data_out = pop_data(vif.mem_addr_in);
        else
          $display("FATAL ERROR: Expecting vif.mem_en to be asserted ");
        end
        @(posedge vif.clock) #1;
        if ((vif.mem_en == 'b0) || (vif.mem_en =='b1 && vif.mem_rdwr == 'b1))
          vif.mem_rdy = 'b0;
  endtask // read_op
      
  task cache_pkg_cache_slave_agent_driver::write_op();
    push_data(vif.mem_addr_in, vif.mem_data_in);
    repeat(3) begin
      @(negedge vif.clock) begin
        if (vif.mem_en && vif.mem_rdwr)
          push_data(vif.mem_addr_in, vif.mem_data_in);
        else
          $display("FATAL ERROR: Expecting vif.mem_en to be asserted ");
          // Check with dynamic assertion if the vifc.addr_in is incremental
      end
    end
  endtask // write_op




  // Continually detects transfers
  task cache_pkg_cache_slave_agent_driver::get_and_drive();
    @(posedge vif.reset);
    `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM)
    forever begin
      //@(posedge vif.sig_clock iff vif.sig_valid===1'b1);
      @(negedge vif.clock iff vif.mem_en);
      // Get new item from the sequencer
      seq_item_port.get_next_item(rsp);
      // Drive the response
      send_response(rsp);
      // Communicate item done to the sequencer
      seq_item_port.item_done();
    end
  endtask : get_and_drive

  // Reset all signals
  task cache_pkg_cache_slave_agent_driver::reset_signals();
    forever begin
      @(negedge vif.reset);
      `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
      vif.sig_ack      <= 0;
      vif.mem_data_out  <= 32'bz;
      vif.mem_rdy       <= 1'bz;
    end
  endtask : reset_signals

  // Response to a transfer from the DUT
  task cache_pkg_cache_slave_agent_driver::send_response(cache_pkg_cache_packet response);
    `uvm_info(get_type_name(),
      $sformatf("Driving response :\n%s",rsp.sprint()), UVM_HIGH)
/*
    response.data = vif.sig_data;
    vif.sig_ack  <= 1;
    @(posedge vif.sig_clock);
    vif.sig_ack <= 0;
    @(posedge vif.sig_clock);
    num_sent++;
*/

    if (vif.mem_rdwr)
      write_op();
    else if(!(vif.mem_rdwr))
      read_op();
    else
      $display("FATAL ERROR: Expecting vif.mem_rdwr to be either 1 or 0 ");

  endtask : send_response

  // UVM report() phase
  function void cache_pkg_cache_slave_agent_driver::report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),
      $sformatf("\nReport: CACHE_PKG cache_slave_agent driver sent %0d cache_packet responses",
      num_sent), UVM_LOW)
  endfunction 
