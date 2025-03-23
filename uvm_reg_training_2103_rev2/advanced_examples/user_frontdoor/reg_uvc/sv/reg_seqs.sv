/*-----------------------------------------------------------------
File name     : reg_seqs.sv
Developers    : 
Created       : 
Description   : 
Notes         : 
              : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// SEQUENCE: base yapp sequence - base sequence with objections from which 
// all sequences can be derived
//
//------------------------------------------------------------------------------
class reg_base_seq extends uvm_sequence#(reg_txn);
  
  // Required macro for sequences automation
  `uvm_object_utils(reg_base_seq)

  // Constructor
  function new(string name="reg_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    if (starting_phase != null) begin
      starting_phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  task post_body();
    if (starting_phase != null) begin
      starting_phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass : reg_base_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: read/write all addresses rw_all
//
//------------------------------------------------------------------------------
class reg_rw_all extends reg_base_seq;

  // Required macro for sequences automation
  `uvm_object_utils(reg_rw_all)

  // Constructor
  function new(string name="reg_rw_all");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing reg_rw_all sequence", UVM_LOW)
    for (int i = 0; i< 8; i++)
      `uvm_do_with( req, {req.reg_wr == REG_WR; req.addr == i;})
    for (int i = 0; i< 8; i++)
      `uvm_do_with( req, {req.reg_wr == REG_RD; req.addr == i;})
  endtask

endclass : reg_rw_all


