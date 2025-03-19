// IVB checksum: 2834963854
/*-----------------------------------------------------------------
File name     : cache_pkg_cache_slave_agent_monitor.sv
Developers    : araheja
Created       : Wed Nov  2 11:42:23 2011
Description   : This file implements the cache_slave_agent monitor.
              : The cache_slave_agent monitor monitors the activity of
              : its interface bus.
Notes         :
-------------------------------------------------------------------
Copyright  (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: cache_pkg_cache_slave_agent_monitor
//
//------------------------------------------------------------------------------

class cache_pkg_cache_slave_agent_monitor extends uvm_monitor;
  
  // The virtual interface needed for this component to drive
  // and view HDL signals.
  protected virtual interface cache_pkg_if vif;
  cache_slave_checker c;

  // Count cache_packet responses collected
  int num_col;

  // The following two bits are used to control whether checks and coverage are
  // done in the monitor
  bit checks_enable = 1;
  bit coverage_enable = 1;
  
  // This TLM port is used to connect the monitor to the scoreboard
  uvm_analysis_port#(cache_pkg_cache_packet) item_collected_port;

  // Current monitored cache_packet 
  protected cache_pkg_cache_packet cache_packet;
 
  // Covergroup for cache_packet
  covergroup cache_slave_agent_cache_packet_cg;
    option.per_instance = 1;
    data_type : coverpoint cache_packet.data_type;
  endgroup : cache_slave_agent_cache_packet_cg

  // Provide UVM automation and utility methods
  `uvm_component_utils_begin(cache_pkg_cache_slave_agent_monitor)
    `uvm_field_int(checks_enable, UVM_DEFAULT)
    `uvm_field_int(coverage_enable, UVM_DEFAULT)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new(string name, uvm_component parent);
    super.new(name, parent);
    // Create the covergroup only if coverage is enabled
    void'(get_config_int("coverage_enable", coverage_enable));
    if (coverage_enable) begin
      cache_slave_agent_cache_packet_cg = new();
      cache_slave_agent_cache_packet_cg.set_inst_name("cache_slave_agent_cache_packet_cg");
    end
    // Create the TLM port
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  // Additional class methods
  extern virtual task run_phase(uvm_phase phase);
  extern virtual protected task collect_response();
  extern virtual protected function void perform_checks();
  extern virtual protected function void perform_coverage();
  extern virtual function void report_phase(uvm_phase phase);

  virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);

    if(!uvm_config_db#(virtual cache_pkg_if)::get(this,"","vif",vif))
	`uvm_error(get_type_name(),"virtual if not configured");

  endfunction
endclass : cache_pkg_cache_slave_agent_monitor

  // UVM run() phase
  task cache_pkg_cache_slave_agent_monitor::run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      collect_response();
    join_none
  endtask

  /***************************************************************************
   IVB-NOTE : REQUIRED : cache_slave_agent Monitor : Monitors
   -------------------------------------------------------------------------
   Modify the collect_response() method to match your protocol.
   Note that if you change/add signals to the physical interface, you must
   also change this method. 
   ***************************************************************************/
  
  // Collect cache_slave_agent cache_packet (response)
  task cache_pkg_cache_slave_agent_monitor::collect_response();

/*
    // This monitor re-uses its data item for ALL cache_packets
    cache_packet = cache_pkg_cache_packet::type_id::create("cache_packet", this);
    forever begin
      @(posedge vif.sig_clock iff vif.sig_ack === 1);
      // Enable cache_packet recording
      void'(begin_tr(cache_packet, "CACHE_PKG CACHE_SLAVE_AGENT Monitor"));
      cache_packet.data = vif.sig_data;
      cache_packet.data_type = vif.sig_data[0]==1'b0 ? CACHE_PKG_EVEN : CACHE_PKG_ODD;
      @(posedge vif.sig_clock);
      end_tr(cache_packet);
      `uvm_info(get_type_name(),
        $sformatf("cache_slave_agent cache_packet collected :\n%s",
        cache_packet.sprint()), UVM_HIGH)
      if (checks_enable)
        perform_checks();
      if (coverage_enable)
        perform_coverage();
      // Send cache_packet to scoreboard via TLM write()
      item_collected_port.write(cache_packet);
      num_col++;
    end
*/

   c = new();
   forever begin
    c.check(vif);
   end
  endtask : collect_response
  
  /***************************************************************************
  IVB-NOTE : OPTIONAL : cache_slave_agent Monitor Protocol Checks : Checks
  -------------------------------------------------------------------------
  Add protocol checks within the perform_checks() method. 
  ***************************************************************************/
  // perform__checks
  function void cache_pkg_cache_slave_agent_monitor::perform_checks();
    // Add checks here
  endfunction : perform_checks
  
 /***************************************************************************
  IVB-NOTE : OPTIONAL : cache_slave_agent Monitor Coverage : Coverage
  -------------------------------------------------------------------------
  Modify the cache_slave_agent_cache_packet_cg coverage group to match your protocol.
  Add new coverage groups, and edit the perform_coverage() method to sample them
  ***************************************************************************/

  // Triggers coverage events
  function void cache_pkg_cache_slave_agent_monitor::perform_coverage();
    cache_slave_agent_cache_packet_cg.sample();
  endfunction : perform_coverage

  // UVM report() phase
  function void cache_pkg_cache_slave_agent_monitor::report_phase(uvm_phase phase); 
    super.report_phase(phase);
    `uvm_info(get_type_name(), 
      $sformatf("\nReport: CACHE_PKG cache_slave_agent monitor collected %0d cache_packet responses",
      num_col), UVM_LOW)
  endfunction
