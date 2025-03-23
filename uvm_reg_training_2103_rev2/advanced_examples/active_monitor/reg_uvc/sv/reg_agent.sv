/*-----------------------------------------------------------------
File name     : reg_agent.sv
Developers    : Kathleen Meade
Created       : 01/04/11
Description   : This file implements the UVC agent
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: reg_agent
//
//------------------------------------------------------------------------------

class reg_agent extends uvm_agent;

  //  This field determines whether an agent is active or passive.
  protected uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  reg_monitor   monitor;
  reg_sequencer sequencer;
  reg_driver    driver;
  
  // component macro
  `uvm_component_utils_begin(reg_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase() method
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = reg_monitor::type_id::create("monitor", this);
    if(is_active == UVM_ACTIVE) begin
      sequencer = reg_sequencer::type_id::create("sequencer", this);
      driver = reg_driver::type_id::create("driver", this);
    end
  endfunction : build_phase

  // UVM connect_phase() method
  function void connect_phase(uvm_phase phase);
    if(is_active == UVM_ACTIVE) 
      // Connect the driver and the sequencer 
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction : connect_phase

endclass : reg_agent

