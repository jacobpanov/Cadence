// IVB checksum: 1883129052
/*-----------------------------------------------------------------
File name     : example_seq_lib.sv
Developers    : araheja
Created       : Wed Nov  2 11:42:23 2011
Description   : This file implements project-specific sequences
Notes         : Each sequence implements a typical scenario or a
              : combination of existing scenarios.
              : Use this file to define sequences that are specific
              : only to this project (not reusable at a higher level)
              : Reusable sequences belong in the sv/cache_pkg_*_seq_lib.sv files.
-------------------------------------------------------------------
Copyright  (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// SEQUENCE: cache_pkg_demo_seq
//
//------------------------------------------------------------------------------
 
class cache_pkg_demo_seq extends uvm_sequence #(cache_pkg_cache_packet);

  // Required macro for sequences automation
  `uvm_object_utils(cache_pkg_demo_seq)    

  // Parameter for this sequence
  rand bit [31:0] s_data;

  // Constraint for the data parameter
  constraint data_cst { s_data[1:0] == 2'b00; }

  // Constructor
  function new(string name="cache_pkg_demo_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    begin
      `uvm_info(get_type_name(),"Executing...", UVM_HIGH)
      // Send four cache_packets - each cache_packet increments data by 1
      repeat (4) begin
        `uvm_do_with(req, { req.data == s_data; } )
        s_data++;
      end
    end
  endtask

  virtual task pre_body();
    uvm_test_done.raise_objection(this);
  endtask 

  virtual task post_body();
    uvm_test_done.drop_objection(this);
  endtask 

endclass


