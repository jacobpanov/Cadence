/*-----------------------------------------------------------------
File name     : 
Developers    : 
Created       : 
Description   : 
              :  
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: reg_rm_tb
//
//------------------------------------------------------------------------------

class reg_rm_tb extends uvm_env;

  // reg environment
  reg_env reg_uvc;

  // reg model
  reg_model reg_rm;

  // adapter 
  reg_adapter reg2rm;  

  // predictor
  uvm_reg_predictor#(reg_txn) reg_predictor;

  // user frontdoor
  reg7_frontdoor reg7_fd;
  indirect_frontdoor idt_fd; 

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
    reg_rm = reg_model::type_id::create("reg_rm",this);
    reg_rm.build();
    reg_rm.lock_model();
    //reg_rm.default_map.set_auto_predict(1);
    reg_rm.set_hdl_path_root("top.dut");

    uvm_config_db#(reg_model)::set(null,"*","reg_rm",reg_rm);

    // reg adapter
    reg2rm = reg_adapter::type_id::create("reg2rm",this);

    // reg predictor
    reg_predictor = new("reg_predictor",this);
    reg_predictor.adapter = reg2rm;
    reg_predictor.map = reg_rm.default_map;


    // reg7 user frontdoor
    reg7_fd = reg7_frontdoor::type_id::create("reg7_fd");
    reg_rm.custom_registers.reg_seven.set_frontdoor(reg7_fd);

    // indirect register frontdoor
    idt_fd = indirect_frontdoor::type_id::create("idt_fd");
    idt_fd.configure( .idxaddr(5'h10), .idxdata(5'h11));
    reg_rm.custom_registers.reg_eight.set_frontdoor(idt_fd);
    reg_rm.custom_registers.reg_nine.set_frontdoor(idt_fd);

  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    reg_rm.default_map.set_sequencer(reg_uvc.agent.sequencer, reg2rm);
    reg_uvc.agent.monitor.monitor_reg_port.connect(reg_predictor.bus_in);
  endfunction : connect_phase


endclass : reg_rm_tb
