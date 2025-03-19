// IVB checksum: 604844779
/*-----------------------------------------------------------------
File name     : cache_pkg_env.sv
Developers    : araheja
Created       : Wed Nov  2 11:42:23 2011
Description   : This file implements the UVC env.
Notes         :
-------------------------------------------------------------------
Copyright  (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: cache_pkg_env
//
//------------------------------------------------------------------------------

class cache_pkg_env extends uvm_env;

  // Virtual Interface variable
  protected virtual interface cache_pkg_if vif;
 
  // The following two bits are used to control whether checks and coverage are
  // done both in the bus monitor class and the interface.
  bit checks_enable = 1; 
  bit coverage_enable = 1;

  // Components of the environment
  cache_pkg_cache_master_agent_agent cache_master_agent_agent;
  cache_pkg_cache_slave_agent_agent cache_slave_agent_agent;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(cache_pkg_env)
    `uvm_field_int(checks_enable, UVM_DEFAULT)
    `uvm_field_int(coverage_enable, UVM_DEFAULT)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Additional class methods
  extern virtual function void build_phase(uvm_phase phase);
  extern protected task update_vif_enables();
  extern virtual task run_phase(uvm_phase phase);

endclass : cache_pkg_env

  // UVM build() phase
  function void cache_pkg_env::build_phase(uvm_phase phase);
    super.build();
    cache_master_agent_agent = cache_pkg_cache_master_agent_agent::type_id::create("cache_master_agent_agent", this);
    cache_slave_agent_agent = cache_pkg_cache_slave_agent_agent::type_id::create("cache_slave_agent_agent", this);

    if(!uvm_config_db#(virtual cache_pkg_if)::get(this,"","vif",vif))
	`uvm_error("NOVIF","virtual if not configured");
  endfunction 

  // Function to assign the checks and coverage bits
  task cache_pkg_env::update_vif_enables();
    // Make assignments at time zero based upon config
    vif.has_checks <= checks_enable;
    vif.has_coverage <= coverage_enable;
    forever begin
      // Make assignments whenever enables change after time zero
      @(checks_enable || coverage_enable);
      vif.has_checks <= checks_enable;
      vif.has_coverage <= coverage_enable;
    end
  endtask : update_vif_enables

  // UVM run() phase
  task cache_pkg_env::run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      update_vif_enables();
    join_none
  endtask
