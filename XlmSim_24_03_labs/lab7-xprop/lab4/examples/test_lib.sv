// IVB checksum: 845437381
/*-----------------------------------------------------------------
File name     : test_lib.sv
Developers    : araheja
Created       : Wed Nov  2 11:42:23 2011
Description   : This file implements two kinds of test in the testbench.
Notes         : A test file verifies one or more cases in the test plan. 
-------------------------------------------------------------------
Copyright  (c)2011 
-----------------------------------------------------------------*/

`include "demo_tb.sv"

//----------------------------------------------------------------
//
// TEST: demo_base_test - Base test
//
//----------------------------------------------------------------
class demo_base_test extends uvm_test;

  `uvm_component_utils(demo_base_test)

  demo_tb demo_tb0;
  uvm_table_printer printer;

  function new(string name = "demo_base_test", uvm_component parent);
    super.new(name,parent);
    printer = new();
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Enable transaction recording for everything
    set_config_int("*", "recording_detail", UVM_FULL);
    // Create the testbench
    demo_tb0 = demo_tb::type_id::create("demo_tb0", this);
  endfunction

  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    printer.knobs.depth = 5;
    this.print(printer);
  endfunction 

endclass : demo_base_test

//----------------------------------------------------------------
//
// TEST: default_sequence_test - sets the default sequences
//
//----------------------------------------------------------------
class default_sequence_test extends demo_base_test;
  `uvm_component_utils(default_sequence_test)

  function new(string name = "default_sequence_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    int unsigned itr;

    //
    assert(std::randomize(itr) with {itr inside {[1:10]};} );
    set_config_int("demo_tb0.cache_pkg.cache_master_agent_agent.sequencer","cache_pkg_cache_master_agent_nested_seq.itr",itr);

    // Set the default sequence for the cache_master_agent and cache_slave_agent
    uvm_config_wrapper::set(this,"demo_tb0.cache_pkg.cache_master_agent_agent.sequencer.run_phase",
      "default_sequence",cache_pkg_cache_master_agent_nested_seq::get_type());

    uvm_config_wrapper::set(this,"demo_tb0.cache_pkg.cache_slave_agent_agent.sequencer.run_phase",
      "default_sequence",cache_pkg_cache_slave_agent_resp_seq::get_type());

    super.build_phase(phase);
  endfunction 

endclass

class mul_sequence_test extends demo_base_test;
  `uvm_component_utils(mul_sequence_test)

  function new(string name = "mul_sequence_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
        int unsigned itr;

    //
    assert(std::randomize(itr) with {itr inside {[1:10]};} );
    set_config_int("demo_tb0.cache_pkg.cache_master_agent_agent.sequencer","mul_seq.itr",itr);

    // Set the default sequence for the cache_master_agent and cache_slave_agent
    uvm_config_wrapper::set(this,"demo_tb0.cache_pkg.cache_master_agent_agent.sequencer.run_phase",
      "default_sequence",mul_seq::get_type());

    uvm_config_wrapper::set(this,"demo_tb0.cache_pkg.cache_slave_agent_agent.sequencer.run_phase",
      "default_sequence",cache_pkg_cache_slave_agent_resp_seq::get_type());

    //set_type_override_by_type(cache_pkg_cache_packet::get_type(), short_packet::get_type());

    super.build_phase(phase);

    //set_type_override_by_type(cache_pkg_cache_packet::get_type(), short_packet::get_type());
  endfunction 


  virtual task run_phase(uvm_phase phase);
//    $display("obj = %d", get_objection_count(mul_sequence_test));
    //#200 set_type_override_by_type(cache_pkg_cache_packet::get_type(), short_packet::get_type());

  endtask
endclass
