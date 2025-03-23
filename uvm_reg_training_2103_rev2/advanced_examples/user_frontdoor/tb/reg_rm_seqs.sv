/*-----------------------------------------------------------------
File name     : reg_rm_seqs.sv
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
// SEQUENCE: register base sequence - base sequence with objections from which 
// all sequences can be derived and get for register model
//
//------------------------------------------------------------------------------
class reg_rm_base_seq extends uvm_sequence#(reg_txn);
  
  // register model handle for register sequences
 reg_model reg_rm;
  
  `uvm_object_utils(reg_rm_base_seq)

  // Constructor
  function new(string name="reg_rm_base_seq");
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


  function void get_reg_model();
    if (! uvm_config_db#(reg_model)::get(get_sequencer(),"","reg_rm",reg_rm))
      `uvm_fatal(get_type_name(), "Failed to get register model")
    if (reg_rm == null)
      `uvm_fatal(get_type_name(), "reg_rm from config_db is null")
  endfunction

  task pre_start();
    get_reg_model();
  endtask


endclass : reg_rm_base_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: custom_access_seq for reg_custom_access.sv rtl
//
//------------------------------------------------------------------------------
class custom_access_seq extends reg_rm_base_seq;

  // Required macro for sequences automation
  `uvm_object_utils(custom_access_seq)

  // Constructor
  function new(string name="custom_access_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    uvm_status_e status;
    logic [7:0] value, bitset;
    uvm_reg regs[$];
    
    reg_rm.get_registers(regs); 

    `uvm_info(get_type_name(), "Executing custom_access_seq sequence", UVM_LOW)

//  Enable bits
//    Field 1 of reg_zero is write-enable bit for reg_one
//    if reg_zero[1] = 1'b0, reg_one is read-only.
      reg_rm.custom_registers.reg_zero.write(status, 8'h0);
      `uvm_info(get_type_name(), "Write to unenabled reg_one", UVM_LOW)
      reg_rm.custom_registers.reg_one.write(status, 8'h1);
      reg_rm.custom_registers.reg_one.read(status, value);
      if (value !== 8'h0)
         `uvm_error(get_full_name(), $sformatf("Read %h from un-enabled reg_one, expected 8'h0", value))
      `uvm_info(get_full_name, $sformatf("Read %h from reg_one", value), UVM_MEDIUM) 
      reg_rm.custom_registers.reg_zero.write(status, 8'h2);
      `uvm_info(get_type_name(), "Write to enabled reg_one", UVM_LOW)
      reg_rm.custom_registers.reg_one.write(status, 8'h5);
      reg_rm.custom_registers.reg_one.read(status, value);
      if (value !== 8'h5)
         `uvm_error(get_full_name(), $sformatf("Read %h from enabled reg_one, expected 8'h5", value))
      `uvm_info(get_full_name, $sformatf("Read %h from reg_one", value), UVM_MEDIUM) 

//  Write set 5a
//    register reg_three has a write-set-8'h5A access policy.
//    i.e. when written to any value, register is set to 8'h5A
      `uvm_info(get_type_name(), "Write to write-set-8'h5A reg_three", UVM_LOW)
      reg_rm.custom_registers.reg_three.write(status, 8'h1);
      reg_rm.custom_registers.reg_three.read(status, value);
      if (value !== 8'h5a)
         `uvm_error(get_full_name(), $sformatf("Read %h from ws2a reg_three, expected 8'h5a", value))
      `uvm_info(get_full_name, $sformatf("Read %h from reg_three", value), UVM_MEDIUM) 

//  Aliased register
//    reg_four and reg_five are aliased - writes to either address affect both
    `uvm_info(get_type_name(), "testing aliased registers", UVM_LOW)
    // clear both registers
    reg_rm.custom_registers.reg_four.write(status, 8'h00);
    reg_rm.custom_registers.reg_five.write(status, 8'h00);
    reg_rm.custom_registers.reg_four.write(status, 8'ha5);
    `uvm_info(get_type_name(), "Write to reg_four ha5", UVM_MEDIUM)
    reg_rm.custom_registers.reg_four.read(status, value);
    if (value !== 8'ha5)
       `uvm_error(get_full_name(), $sformatf("Read %h from aliased reg_four, expected 8'ha5", value))
    `uvm_info(get_full_name, $sformatf("Read %h from reg_four", value), UVM_MEDIUM) 
    reg_rm.custom_registers.reg_five.read(status, value);
    if (value !== 8'ha5)
       `uvm_error(get_full_name(), $sformatf("Read %h from aliased reg_five, expected 8'ha5", value))
    `uvm_info(get_full_name, $sformatf("Read %h from reg_five", value), UVM_MEDIUM) 
    reg_rm.custom_registers.reg_five.write(status, 8'hff);
    `uvm_info(get_type_name(), "Write to reg_five hff", UVM_LOW)
    reg_rm.custom_registers.reg_five.read(status, value);
    if (value !== 8'hff)
       `uvm_error(get_full_name(), $sformatf("Read %h from aliased reg_five, expected 8'hff", value))
    `uvm_info(get_full_name, $sformatf("Read %h from reg_five", value), UVM_MEDIUM) 
    reg_rm.custom_registers.reg_four.read(status, value);
    if (value !== 8'hff)
       `uvm_error(get_full_name(), $sformatf("Read %h from aliased reg_four, expected 8'hff", value))
    `uvm_info(get_full_name, $sformatf("Read %h from reg_four", value), UVM_MEDIUM) 

  endtask

endclass : custom_access_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: user frontdoor test
//
//------------------------------------------------------------------------------
class user_frontdoor_seq extends reg_rm_base_seq;

  // Required macro for sequences automation
  `uvm_object_utils(user_frontdoor_seq)

  uvm_status_e status;
  logic [7:0] rvalue, wvalue;
  int ok;
  uvm_reg regs[$];

  // Constructor
  function new(string name="user_frontdoor_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    
    `uvm_info(get_type_name(), "Executing user_frontdoor_seq sequence", UVM_LOW)

//  user frontdoor test
// read/write reg_seven via frontdoor
      ok = randomize(wvalue); 
      reg_rm.custom_registers.reg_seven.write(status, wvalue);
      `uvm_info(get_type_name(), $sformatf("Write %h to reg_seven", wvalue), UVM_LOW)
      reg_rm.custom_registers.reg_seven.peek(status, rvalue);
      `uvm_info(get_type_name(), $sformatf("Peek %h from reg_seven", rvalue), UVM_LOW)
      reg_rm.custom_registers.reg_seven.read(status, rvalue);
      `uvm_info(get_type_name(), $sformatf("Read %h from reg_seven", rvalue), UVM_LOW)
  endtask

endclass : user_frontdoor_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: indirect frontdoor test
//
//------------------------------------------------------------------------------
class indirect_frontdoor_seq extends reg_rm_base_seq;

  // Required macro for sequences automation
  `uvm_object_utils(indirect_frontdoor_seq)

  uvm_status_e status;
  logic [7:0] rvalue, wvalue, pvalue;
  int ok;
  uvm_reg regs[$];

  // Constructor
  function new(string name="indirect_frontdoor_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    
    `uvm_info(get_type_name(), "Executing indirect_frontdoor_seq sequence", UVM_LOW)

//  indirect_frontdoor_seq
// read/write reg_eight via frontdoor
      ok = randomize(wvalue); 
      `uvm_info(get_type_name(), $sformatf("Write %h to reg_eight", wvalue), UVM_LOW)
      reg_rm.custom_registers.reg_eight.write(status, wvalue);
      reg_rm.custom_registers.reg_eight.peek(status, pvalue);
      `uvm_info(get_type_name(), $sformatf("peek %h from reg_eight", pvalue), UVM_LOW)
      reg_rm.custom_registers.reg_eight.read(status, rvalue);
      `uvm_info(get_type_name(), $sformatf("Read %h from reg_eight", rvalue), UVM_LOW)
      ok = randomize(wvalue); 
      `uvm_info(get_type_name(), $sformatf("Write %h to reg_nine", wvalue), UVM_LOW)
      reg_rm.custom_registers.reg_nine.write(status, wvalue);
      reg_rm.custom_registers.reg_nine.peek(status, pvalue);
      `uvm_info(get_type_name(), $sformatf("peek %h from reg_nine", pvalue), UVM_LOW)
      reg_rm.custom_registers.reg_nine.read(status, rvalue);
      `uvm_info(get_type_name(), $sformatf("Read %h from reg_nine", rvalue), UVM_LOW)
  endtask

endclass : indirect_frontdoor_seq


