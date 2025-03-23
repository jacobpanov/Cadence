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
  custom_regs_vendor_Cadence_Design_Systems_library_flat_version_2_0 reg_rm;

  // adapter 
  reg_adapter reg2rm;  

  // predictor
  uvm_reg_predictor#(reg_item) reg_predictor;

  //callbacks
  write_set_5a_cb ws5a_cb;
  enable_bits_cb en1_cb, en2_cb, en3_cb, en4_cb, en5_cb, en6_cb, en7_cb;
  alias_reg_cb alias_reg;

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
    //reg_rm.default_map.set_auto_predict(1);

    //uvm_config_db#(custom_regs_vendor_Cadence_Design_Systems_library_flat_version_2_0)::set(null,"*","reg_rm",reg_rm);
    //uvm_config_db#(reg_model)::set(null,"*.tb.reg_uvc.sequencer","reg_rm",reg_rm);

    // reg adapter
    reg2rm = reg_adapter::type_id::create("reg2rm",this);

    // reg predictor
    reg_predictor = new("reg_predictor",this);
    reg_predictor.adapter = reg2rm;
    reg_predictor.map = reg_rm.default_map;

//  Enable bits
//    Field 1 of reg_zero is write-enable bit for reg_one

    en1_cb = new("en1_cb",reg_rm.custom_registers.reg_zero.field1);
    uvm_reg_field_cb::add(reg_rm.custom_registers.reg_one.reg_one_fld, en1_cb);

//  Write set 5a
//    register reg_three has a write-set-8'h5A access policy.

    ws5a_cb = new("ws5a_cb");
    uvm_reg_field_cb::add(reg_rm.custom_registers.reg_three.reg_three_fld, ws5a_cb);

//  Aliased register
//    reg_four and reg_five are aliased - writes to either address affect both

    alias_reg = new("alias_reg_four",reg_rm.custom_registers.reg_five.reg_five_fld);
    uvm_reg_field_cb::add(reg_rm.custom_registers.reg_four.reg_four_fld, alias_reg);
    alias_reg = new("alias_reg_five",reg_rm.custom_registers.reg_four.reg_four_fld);
    uvm_reg_field_cb::add(reg_rm.custom_registers.reg_five.reg_five_fld, alias_reg);
    

    uvm_reg_field_cb::display();

  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    reg_rm.default_map.set_sequencer(reg_uvc.agent.sequencer, reg2rm);
    reg_uvc.agent.monitor.monitor_reg_port.connect(reg_predictor.bus_in);
  endfunction : connect_phase

  function void check_phase(uvm_phase phase);
    reg_rm.print();
  endfunction : check_phase



endclass : reg_rm_tb
