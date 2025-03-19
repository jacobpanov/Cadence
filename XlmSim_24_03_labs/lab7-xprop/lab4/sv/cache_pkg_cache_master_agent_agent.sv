// IVB checksum: 156672590
/*-----------------------------------------------------------------
File name     : cache_pkg_cache_master_agent_agent.sv
Developers    : araheja
Created       : Wed Nov  2 11:42:23 2011
Description   : This file implements the cache_master_agent agent
Notes         :
-------------------------------------------------------------------
Copyright  (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: cache_pkg_cache_master_agent_agent
//
//------------------------------------------------------------------------------

class cache_pkg_cache_master_agent_agent extends uvm_agent;

  cache_pkg_cache_master_agent_monitor monitor;
  uvm_sequencer #(cache_pkg_cache_packet) sequencer;
  cache_pkg_cache_master_agent_driver driver;
  
  /***************************************************************************
   IVB-NOTE : OPTIONAL : cache_master_agent Agent : Agents
   -------------------------------------------------------------------------
   Add cache_master_agent fields, events and methods.
   For each field you add:
     o Update the `uvm_component_utils_begin macro to get various UVM utilities
       for this attribute.
   ***************************************************************************/

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(cache_pkg_cache_master_agent_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build() phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = cache_pkg_cache_master_agent_monitor::type_id::create("monitor", this);
    if(is_active == UVM_ACTIVE) begin
      sequencer = uvm_sequencer #(cache_pkg_cache_packet)::type_id::create("sequencer", this);
      driver = cache_pkg_cache_master_agent_driver::type_id::create("driver", this);
    end
  endfunction

  // UVM connect() phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(is_active == UVM_ACTIVE) begin
      // Binds the driver to the sequencer using consumer-producer interface
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction 

endclass : cache_pkg_cache_master_agent_agent
