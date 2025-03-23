/*-----------------------------------------------------------------
File name     : reg_test_lib.sv
Developers    : Brian Dickinson
Created       : 01/04/22
Description   : This file implements the test library for the custom register access lab
Notes         : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2022 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: reg_test_lib
//
//------------------------------------------------------------------------------

class base_test extends uvm_test;

  `uvm_component_utils(base_test)

  // Testbench handle
  reg_rm_tb tb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    // create testbench instance
    uvm_config_int::set( this, "*", "recording_detail", 1);
    super.build_phase(phase);
    tb = reg_rm_tb::type_id::create("tb", this);
  endfunction : build_phase
  
  function void end_of_elaboration_phase(uvm_phase phase);
    // reset register model and print topology
    tb.reg_rm.reset();
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  task run_phase(uvm_phase phase);
    // drain time
    uvm_objection obj = phase.get_objection();
    obj.set_drain_time(this, 200ns);
  endtask : run_phase

  function void check_phase(uvm_phase phase);
    // configuration checker
    check_config_usage();
  endfunction

endclass : base_test

class custom_access_test extends base_test;

  `uvm_component_utils(custom_access_test)

  // register model and block handles
  custom_regs_vendor_Cadence_Design_Systems_library_flat_version_2_0 reg_rm;
  T_registers_25 regs;      

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void connect_phase(uvm_phase phase);
    // assign model and block handles to model instantiation
    reg_rm = tb.reg_rm;
    regs = reg_rm.custom_registers;
  endfunction : connect_phase

  task run_phase(uvm_phase phase);
    uvm_status_e status;
    logic [7:0] value, bitset;
    super.run_phase(phase);
    phase.raise_objection(this, "Raising Objection for custom access test");
    #5ns;
    `uvm_info(get_type_name(), "Executing custom_access_test", UVM_LOW)

//  Write set 5a Read Clear
//    register reg_three has a write-set-8'h5A-Read-Clear access policy.
//    i.e. when written to any value, register is set to 8'h5A
//         when read, register is set to 8'h00
      `uvm_info(get_type_name(), "Write to write-set-8'h5A reg_three", UVM_LOW)
      regs.reg_three.write(status, 8'h1);
      `uvm_info(get_full_name, "First read from reg_three: expect 8'h5a", UVM_LOW) 
      regs.reg_three.mirror(status, UVM_CHECK);
      `uvm_info(get_full_name, "Second read from reg_three: expect 8'hFF", UVM_LOW) 
      regs.reg_three.mirror(status, UVM_CHECK);


    //  Enable bits
    //    Field 1 of reg_zero is write-enable bit for reg_one
    //    if reg_zero[1] = 1'b0, reg_one is read-only.
      regs.reg_zero.write(status, 8'h0);
      `uvm_info(get_type_name(), "Write to unenabled reg_one", UVM_LOW)
      regs.reg_one.write(status, 8'h1);
      regs.reg_one.mirror(status, UVM_CHECK);
      regs.reg_zero.write(status, 8'h2);
      `uvm_info(get_type_name(), "Write to enabled reg_one", UVM_LOW)
      regs.reg_one.write(status, 8'h5);
      regs.reg_one.mirror(status, UVM_CHECK);


//  Aliased register
//    reg_four and reg_five are aliased - writes to either address affect both
    `uvm_info(get_type_name(), "testing aliased registers", UVM_LOW)
    // clear both registers
    regs.reg_four.write(status, 8'h00);
    regs.reg_five.write(status, 8'h00);
    // write ha5 to reg_four
    `uvm_info(get_type_name(), "Write to reg_four ha5", UVM_MEDIUM)
    regs.reg_four.write(status, 8'ha5);
    // check both registers
    regs.reg_four.mirror(status, UVM_CHECK);
    regs.reg_five.mirror(status, UVM_CHECK);
    // write hff to reg_five
    `uvm_info(get_type_name(), "Write to reg_five hff", UVM_LOW)
    regs.reg_five.write(status, 8'hff);
    // check both registers
    regs.reg_four.mirror(status, UVM_CHECK);
    regs.reg_five.mirror(status, UVM_CHECK);


     phase.drop_objection(this," Dropping Objection for custom access test");

  endtask : run_phase

endclass : custom_access_test



