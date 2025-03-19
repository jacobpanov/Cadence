// IVB checksum: 1206677245
/*-----------------------------------------------------------------
File name     : demo_tb.sv
Developers    : araheja
Created       : Wed Nov  2 11:42:23 2011
Description   : This file implements the demo testbench (tb)
Notes         :
-------------------------------------------------------------------
Copyright  (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: demo_tb
//
//------------------------------------------------------------------------------

class demo_tb extends uvm_env;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils(demo_tb)

  // cache_pkg environment
  cache_pkg_env cache_pkg;

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

// Additional class methods
// UVM build() phase
function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  // set vif property for child elements
  uvm_config_db#(virtual cache_pkg_if)::set(this,"*","vif",demo_top.cache_pkg_if);

  cache_pkg = cache_pkg_env::type_id::create("cache_pkg", this);
endfunction


// UVM start_of_simulation() phase
function void start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
  uvm_test_done.set_drain_time(this, 1000);
endfunction 
endclass
