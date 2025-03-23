/*-----------------------------------------------------------------
File name     : router_reg_seqs.sv
Developers    : Kathleen Meade, Brian Dickinson, Lisa Barbay
Created       : 01/04/11
Description   : Register sequences for router using register model
Notes         : From the Cadence "SystemVerilog Register Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

//----------------------------------------------------------------------------
// SEQUENCE: router_reg_base_seq
//----------------------------------------------------------------------------

class router_reg_base_seq extends uvm_reg_sequence;

  `uvm_object_utils(router_reg_base_seq) 
  
  // objection handling
  task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

  function new(string name="router_reg_base_seq");
    super.new(name);
  endfunction
 
  // Register Model and Register Block handles
  yapp_router_regs_t yapp_rm;                     
  yapp_regs_block regs;  

  function void get_reg_model();
    if (! uvm_config_db#(yapp_router_regs_t)::get(get_sequencer(), "", "yapp_rm", yapp_rm) )
      `uvm_fatal(get_type_name(), "Failed to get register model")
    if (yapp_rm == null)
      `uvm_fatal(get_type_name(), "yapp_rm from config_db is null")
    regs = yapp_rm.router_yapp_regs;
  endfunction

  task pre_start();
    get_reg_model();
  endtask

endclass : router_reg_base_seq

//------------------------------------------------------------------------------
//
// CLASS: reg_access_seq
//-----------------------------------------------------------------------------

class reg_access_seq extends router_reg_base_seq;

  `uvm_object_utils(reg_access_seq)

  function new(string name = "reg_access_seq");
    super.new(name);
  endfunction : new

  task body();
     int rdata, wrdata;
     bit ok;
     uvm_status_e status;

     // register queues for results of introspection methods
     uvm_reg allregs[$], rwregs[$], roregs[$], cntregs[$];

    // get all registers
    regs.get_registers(allregs); 
    foreach (allregs[i])
      `uvm_info("INTROSPECTION", $sformatf("Router register %s", allregs[i].get_name()), UVM_NONE)

    // get RW & RO registers with array locator methods (could also use loop)
    rwregs = allregs.find(i) with (i.get_rights() == "RW");
    roregs = allregs.find(i) with (i.get_rights() == "RO");

    // get counter registers with a foreach loop
    // remove mem_size_reg from ro_regs
    foreach (roregs [i]) 
      if ( roregs[i].get_name() != "mem_size_reg" )
        cntregs.push_back(roregs[i]); 
 
    foreach (rwregs [i])
      begin
      // read/write access check 
      // Front-door write a unique value.
      // Peek and check the DUT value matches.
      // Poke a new value.
      // Front-door read this new value.

      `uvm_info("INTROSPECTION", $sformatf("RW test FDwr/peek/poke/FDrd %s", rwregs[i].get_name()), UVM_NONE)
    
      wrdata = 8'hf0;
      rwregs[i].write(status, wrdata);
      `uvm_info("INTROSPECTION", $sformatf("WROTE FD %2h", wrdata), UVM_NONE)
      #20ns; // allow write to complete
      rwregs[i].peek(status, rdata);
      `uvm_info("INTROSPECTION", $sformatf("PEEK %2h",rdata), UVM_NONE)
      wrdata = 8'h0f;
      rwregs[i].poke(status, wrdata);
      `uvm_info("INTROSPECTION", $sformatf("POKE %2h", wrdata), UVM_NONE)
      rwregs[i].read(status, rdata);
      `uvm_info("INTROSPECTION", $sformatf("READ FD %2h",rdata), UVM_NONE)
      //ok = regs[i].predict(8'h00);
      rwregs[i].mirror(status, UVM_CHECK);
    end

    foreach (roregs [i])
      begin
      `uvm_info("INTROSPECTION", $sformatf("RO test poke/FDrd/FDwr/peek %s", roregs[i].get_name()), UVM_NONE)
      roregs[i].poke(status, wrdata);
      `uvm_info("INTROSPECTION", $sformatf("POKE %2h", wrdata), UVM_NONE)
      roregs[i].read(status, rdata);
      `uvm_info("INTROSPECTION", $sformatf("READ FD %2h", rdata), UVM_NONE)
      wrdata = 8'hf0;
      roregs[i].write(status, wrdata);
      `uvm_info("INTROSPECTION", $sformatf("WROTE FD %2h (should be ignored)", wrdata), UVM_NONE)  
      #20ns; // allow write to complete
      roregs[i].peek(status, rdata);
      `uvm_info("INTROSPECTION", $sformatf("PEEK %2h", rdata), UVM_NONE)
     end

    foreach (cntregs [i]) 
      `uvm_info("INTROSPECTION", $sformatf("Count register %s has address offset %0h", cntregs[i].get_name(), cntregs[i].get_offset()), UVM_NONE)

  endtask

endclass : reg_access_seq

