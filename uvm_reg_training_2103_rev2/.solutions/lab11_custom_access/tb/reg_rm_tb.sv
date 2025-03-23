/*-----------------------------------------------------------------
File name     : reg_rm_tb.sv
Developers    : Brian Dickinson
Created       : 01/04/22
Description   : This file implements the testbench for the custom register access lab
Notes         : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2022 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: reg_rm_tb
//
//------------------------------------------------------------------------------

class reg_rm_tb extends uvm_env;

  // reg UVC
  reg_env reg_uvc;

  // reg model
  custom_regs_vendor_Cadence_Design_Systems_library_flat_version_2_0 reg_rm;

  // adapter 
  reg_adapter reg2rm;  

  // predictor
  uvm_reg_predictor#(reg_item) reg_predictor;

  //callbacks
  write_set_5a_read_set_cb ws5ars_cb;

  enable_bits_cb enable_cb;

  alias_reg_cb alias_cb;

  `uvm_component_utils_begin(reg_rm_tb)
    `uvm_field_object(reg_rm, UVM_ALL_ON)
  `uvm_component_utils_end

  function new (string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction : new

  // UVM build() phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // reg UVC
    reg_uvc = reg_env::type_id::create("reg_uvc", this);

    // reg Model
    reg_rm = custom_regs_vendor_Cadence_Design_Systems_library_flat_version_2_0::type_id::create("reg_rm",this);
    reg_rm.build();
    reg_rm.lock_model();

    // reg adapter
    reg2rm = reg_adapter::type_id::create("reg2rm",this);

    // reg predictor
    reg_predictor = new("reg_predictor",this);
    reg_predictor.adapter = reg2rm;
    reg_predictor.map = reg_rm.default_map;

    //  Write set 5a Read set
    //    register reg_three has a write-set-8'h5A_read_set access policy.
    ws5ars_cb = new("ws5ars_cb");
    uvm_reg_field_cb::add(reg_rm.custom_registers.reg_three.reg_three_fld, ws5ars_cb);


    //  Enable bits
    //    Field 1 of reg_zero is write-enable bit for reg_one
    //    e.g. if reg_zero[1] = 1'b0, reg_one is read-only.
    enable_cb = new("enable_cb", reg_rm.custom_registers.reg_zero.field1);
    uvm_reg_field_cb::add(reg_rm.custom_registers.reg_one.reg_one_fld, enable_cb);



    //  Aliased register
    //    reg_four and reg_five are aliased - writes to either address affect both
    alias_cb = new("alias_reg_four",reg_rm.custom_registers.reg_five.reg_five_fld); 
    uvm_reg_field_cb::add(reg_rm.custom_registers.reg_four.reg_four_fld, alias_cb);
    alias_cb = new("alias_reg_five",reg_rm.custom_registers.reg_four.reg_four_fld); 
    //uvm_reg_field_cb::add(reg_rm.custom_registers.reg_five.reg_five_fld, alias_cb);
    

  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    reg_rm.default_map.set_sequencer(reg_uvc.agent.sequencer, reg2rm);
    reg_uvc.agent.monitor.monitor_reg_port.connect(reg_predictor.bus_in);
  endfunction : connect_phase

  function void check_phase(uvm_phase phase);
    //reg_rm.print();
  endfunction : check_phase

endclass : reg_rm_tb
