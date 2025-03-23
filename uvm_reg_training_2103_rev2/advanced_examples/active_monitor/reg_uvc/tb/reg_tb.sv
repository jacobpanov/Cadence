/*-----------------------------------------------------------------
File name     : 
Developers    : 
Created       : 
Description   : 
              :  
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: reg_tb
//
//------------------------------------------------------------------------------

class reg_tb extends uvm_env;

  // component macro
  `uvm_component_utils(reg_tb)

  // reg environment
  reg_env reg_uvc;

  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  // UVM build() phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // MEM UVC
    reg_uvc = reg_env::type_id::create("reg_uvc", this);

  endfunction : build_phase

endclass : reg_tb
