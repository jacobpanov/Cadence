/*-----------------------------------------------------------------
File name     : hbus_adapter_extension.sv
Developers    : Brian Dickinson
Created       : 01/05/22
Description   : Extension for HBUS UVC adapter
Notes         : From the Cadence "SystemVerilog Register Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2022
-----------------------------------------------------------------*/
//------------------------------------------------------------------------------
//
// CLASS: adapter_ext
//-----------------------------------------------------------------------------

class adapter_ext extends uvm_object;

  `uvm_object_utils(adapter_ext)

  // object constructor
  function new(string name = "adapter_ext");
    super.new(name);
  endfunction : new

  string info;

endclass


