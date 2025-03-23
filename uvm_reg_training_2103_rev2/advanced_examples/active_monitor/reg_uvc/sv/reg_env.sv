/*-----------------------------------------------------------------
File name     : reg_env.sv
Developers    : Kathleen Meade
Created       : 01/04/11
Description   : This file implements the UVC env
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: reg_env
//
//------------------------------------------------------------------------------

class reg_env extends uvm_env;

  // Components of the environment
  reg_agent agent;

  // component macro
  `uvm_component_utils(reg_env)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = reg_agent::type_id::create("agent", this);
  endfunction : build_phase
  
endclass : reg_env
