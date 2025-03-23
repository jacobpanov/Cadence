/*-----------------------------------------------------------------
File name     : reg_rm_test_lib.sv
Developers    : 
Created       : 
Description   : 
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: reg_rm_test_lib
//
//------------------------------------------------------------------------------

class base_test extends uvm_test;

  // component macro
  `uvm_component_utils(base_test)

  // Testbench handle
  reg_rm_tb tb;

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase() phase
  function void build_phase(uvm_phase phase);
    uvm_config_int::set( this, "*", "recording_detail", 1);
    super.build_phase(phase);
    tb = reg_rm_tb::type_id::create("tb", this);
  endfunction : build_phase
  
  function void end_of_elaboration_phase(uvm_phase phase);
    tb.reg_rm.reset();
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  task run_phase(uvm_phase phase);
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

  // register model handle
  custom_regs_vendor_Cadence_Design_Systems_library_flat_version_2_0 reg_rm;
  T_registers_25 regs;      

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void connect_phase(uvm_phase phase);
    reg_rm = tb.reg_rm;
    regs = reg_rm.custom_registers;
  endfunction : connect_phase

  task run_phase(uvm_phase phase);
    uvm_status_e status;
    logic [7:0] value, bitset;
    super.run_phase(phase);
    phase.raise_objection(this, "Raising Objection for custom access test");

    `uvm_info(get_type_name(), "Executing custom_access_test", UVM_LOW)

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

//  Write set 5a
//    register reg_three has a write-set-8'h5A access policy.
//    i.e. when written to any value, register is set to 8'h5A
      `uvm_info(get_type_name(), "Write to write-set-8'h5A reg_three", UVM_LOW)
      regs.reg_three.write(status, 8'h1);
      regs.reg_three.read(status, value);
      if (value !== 8'h5a)
         `uvm_error(get_full_name(), $sformatf("Read %h from ws2a reg_three, expected 8'h5a", value))
      `uvm_info(get_full_name, $sformatf("Read %h from reg_three", value), UVM_MEDIUM) 
      regs.reg_three.mirror(status, UVM_CHECK);

//  Aliased register
//    reg_four and reg_five are aliased - writes to either address affect both
    `uvm_info(get_type_name(), "testing aliased registers", UVM_LOW)
    // clear both registers
    regs.reg_four.write(status, 8'h00);
    regs.reg_five.write(status, 8'h00);
    regs.reg_four.write(status, 8'ha5);
    `uvm_info(get_type_name(), "Write to reg_four ha5", UVM_MEDIUM)
    regs.reg_four.read(status, value);
    if (value !== 8'ha5)
       `uvm_error(get_full_name(), $sformatf("Read %h from aliased reg_four, expected 8'ha5", value))
    `uvm_info(get_full_name, $sformatf("Read %h from reg_four", value), UVM_MEDIUM) 
    regs.reg_five.read(status, value);
    if (value !== 8'ha5)
       `uvm_error(get_full_name(), $sformatf("Read %h from aliased reg_five, expected 8'ha5", value))
    `uvm_info(get_full_name, $sformatf("Read %h from reg_five", value), UVM_MEDIUM) 
    regs.reg_five.write(status, 8'hff);
    `uvm_info(get_type_name(), "Write to reg_five hff", UVM_LOW)
    regs.reg_five.read(status, value);
    if (value !== 8'hff)
       `uvm_error(get_full_name(), $sformatf("Read %h from aliased reg_five, expected 8'hff", value))
    `uvm_info(get_full_name, $sformatf("Read %h from reg_five", value), UVM_MEDIUM) 
    regs.reg_four.read(status, value);
    if (value !== 8'hff)
       `uvm_error(get_full_name(), $sformatf("Read %h from aliased reg_four, expected 8'hff", value))
    `uvm_info(get_full_name, $sformatf("Read %h from reg_four", value), UVM_MEDIUM) 

     phase.drop_objection(this," Dropping Objection for custom access test");

  endtask : run_phase

endclass : custom_access_test



