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

    

  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    reg_rm.default_map.set_sequencer(reg_uvc.agent.sequencer, reg2rm);
    reg_uvc.agent.monitor.monitor_reg_port.connect(reg_predictor.bus_in);
  endfunction : connect_phase

  function void check_phase(uvm_phase phase);
    //reg_rm.print();
  endfunction : check_phase

endclass : reg_rm_tb
