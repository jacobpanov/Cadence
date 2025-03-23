/*-----------------------------------------------------------------
File name     : reg_rm_test_lib.sv
Developers    : 
Created       : 
Description   : 
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: reg_rm_test_lib
//
//------------------------------------------------------------------------------

class base_test extends uvm_test;

  // component macro
  `uvm_component_utils(base_test)

  // Testbench handle
  reg_rm_tb tb;

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase() phase
  function void build_phase(uvm_phase phase);
    uvm_config_int::set( this, "*", "recording_detail", 1);
    super.build_phase(phase);
    tb = reg_rm_tb::type_id::create("tb", this);
  endfunction : build_phase
  
  function void end_of_elaboration_phase(uvm_phase phase);
    tb.reg_rm.reset();
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  task run_phase(uvm_phase phase);
    uvm_objection obj = phase.get_objection();
    obj.set_drain_time(this, 200ns);
  endtask : run_phase

  function void check_phase(uvm_phase phase);
    // configuration checker
    check_config_usage();
  endfunction

endclass : base_test

class custom_access_test extends base_test;

  `uvm_component_utils(custom_access_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    uvm_config_wrapper::set(this, "tb.reg_uvc.agent.sequencer.run_phase",
                            "default_sequence",
                            custom_access_seq::type_id::get());
   super.build_phase(phase);
  endfunction : build_phase

endclass : custom_access_test

class user_frontdoor_test extends base_test;

  `uvm_component_utils(user_frontdoor_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    uvm_config_wrapper::set(this, "tb.reg_uvc.agent.sequencer.run_phase",
                            "default_sequence",
                            user_frontdoor_seq::type_id::get());
   super.build_phase(phase);
  endfunction : build_phase

endclass : user_frontdoor_test

class indirect_frontdoor_test extends base_test;

  `uvm_component_utils(indirect_frontdoor_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    uvm_config_wrapper::set(this, "tb.reg_uvc.agent.sequencer.run_phase",
                            "default_sequence",
                            indirect_frontdoor_seq::type_id::get());
   super.build_phase(phase);
  endfunction : build_phase

endclass : indirect_frontdoor_test



