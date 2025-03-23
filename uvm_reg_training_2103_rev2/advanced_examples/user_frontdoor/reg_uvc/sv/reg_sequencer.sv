/*-----------------------------------------------------------------
File name     : reg_sequencer.sv
Developers    : 
Created       : 
Description   : 
Notes         : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: reg_sequencer
//
//------------------------------------------------------------------------------

class reg_sequencer extends uvm_sequencer #(reg_txn);

  `uvm_component_utils(reg_sequencer)

  function new(string name, uvm_component parent);   
    super.new(name, parent);     // important!!
  endfunction

endclass : reg_sequencer


