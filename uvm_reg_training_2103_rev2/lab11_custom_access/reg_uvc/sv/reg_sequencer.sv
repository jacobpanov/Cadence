/*-----------------------------------------------------------------
File name     : reg_sequencer.sv
Developers    : Brian Dickinson
Created       : 01/04/22
Description   : This file implements the sequencer for the reg UVC
Notes         : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2022 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: reg_sequencer
//
//------------------------------------------------------------------------------

class reg_sequencer extends uvm_sequencer #(reg_item);

  `uvm_component_utils(reg_sequencer)

  function new(string name, uvm_component parent);   
    super.new(name, parent);     // important!!
  endfunction

endclass : reg_sequencer


