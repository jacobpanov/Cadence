/*-----------------------------------------------------------------
File name     : reg_rm_tb_scale.sv
Developers    : Brian Dickinson
Created       : 01/04/22
Description   : Scaled Register testbench using user-defined backdoor connected
                to DUT via array of SV interfaces for UVM register active monitoring
Notes         : From the Cadence "SystemVerilog Advanced Register Verification with UVM" training
                Refer to training material for details of code
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2022
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
  uvm_reg_predictor#(reg_item) reg_predictor;

  // user backdoor
  active_monitor_bkdr r_bd[0:1];
  uvm_reg regs[$];

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

    uvm_config_db#(reg_model)::set(null,"*","reg_rm",reg_rm);

    // reg adapter
    reg2rm = reg_adapter::type_id::create("reg2rm",this);

    // reg predictor
    reg_predictor = new("reg_predictor",this);
    reg_predictor.adapter = reg2rm;
    reg_predictor.map = reg_rm.default_map;

    regs = {reg_rm.registers.reg_six,reg_rm.registers.reg_seven};
    foreach (r_bd [i]) begin
      r_bd[i] = new($sformatf("r_bd%0d",i));
      `uvm_info("CHK",$sformatf("idx %0d, backdoor %s, reg %s",i,regs[i].get_name(),r_bd[i].get_name()),UVM_LOW)
      regs[i].set_backdoor(r_bd[i]);
      r_bd[i].start_update_thread(regs[i]);
      if (!regif_cfg::get(this,"",$sformatf("rif%0d",i+6),r_bd[i].rif)) 
        `uvm_error("VIF",$sformatf("Interface get failed for user backdoor rif%0d", i))
    end 

/* 
   // reg_six active monitoring
   r6_bd = new("r6_bd");
   reg_rm.registers.reg_six.set_backdoor(r6_bd);
   r6_bd.start_update_thread(reg_rm.registers.reg_six); 
   if (!regif_cfg::get(this,"","rif6",r6_bd.rif))
      `uvm_error("VIF","Interface get failed for user backdoor rif6")
    
   // reg_seven active monitoring
   r7_bd = new("r7_bd");
   reg_rm.registers.reg_seven.set_backdoor(r7_bd);
   r7_bd.start_update_thread(reg_rm.registers.reg_seven); 
   if (!regif_cfg::get(this,"","rif7",r7_bd.rif))
      `uvm_error("VIF","Interface get failed for user backdoor rif7")
*/
    
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    reg_rm.default_map.set_sequencer(reg_uvc.agent.sequencer, reg2rm);
    reg_uvc.agent.monitor.monitor_reg_port.connect(reg_predictor.bus_in);
  endfunction : connect_phase

  function void check_phase(uvm_phase phase);
    `uvm_info("REG",$sformatf("reg_six is %0d", reg_rm.registers.reg_six.get_mirrored_value()), UVM_LOW) 
    `uvm_info("REG",$sformatf("reg_seven is %0d", reg_rm.registers.reg_seven.get_mirrored_value()), UVM_LOW) 
  endfunction

endclass : reg_rm_tb
