// IVB checksum: 1442151048
/*-----------------------------------------------------------------
File name     : cache_pkg_cache_slave_agent_seq_lib.sv
Developers    : araheja
Created       : Wed Nov  2 11:42:24 2011
Description   : This file implements several sequence kinds
Notes         : Each sequence implements a typical scenario or a
              : combination of existing scenarios.
              : Cadence recommends defining reusable sequences in 
              : this directory and project-specific sequences in the
              : project directory ("examples").
-------------------------------------------------------------------
Copyright  (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// SEQUENCE: cache_pkg_cache_slave_agent_resp_seq
//
//------------------------------------------------------------------------------
 
class cache_pkg_cache_slave_agent_resp_seq extends uvm_sequence #(cache_pkg_cache_packet);
  `uvm_object_utils(cache_pkg_cache_slave_agent_resp_seq)

  // Constructor
  function new(string name="cache_pkg_cache_slave_agent_resp_seq");
    super.new(name);
  endfunction
  
  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(),"Executing... (forever)", UVM_HIGH)
    // Allocate once
    `uvm_create(rsp)
    forever begin
      // Randomize and send many times
      `uvm_rand_send(rsp)
    end
  endtask : body
  
endclass 
