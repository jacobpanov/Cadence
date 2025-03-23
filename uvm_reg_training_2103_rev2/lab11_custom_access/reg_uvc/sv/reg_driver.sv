/*-----------------------------------------------------------------
File name     : reg_driver.sv
Developers    : Brian Dickinson
Created       : 01/04/22
Description   : This file implements the driver for the reg UVC
Notes         : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2022 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: reg_driver
//
//------------------------------------------------------------------------------

class reg_driver extends uvm_driver #(reg_item);

  virtual interface reg_if vif;

  // component macro
  `uvm_component_utils(reg_driver)

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    if (!reg_vif_config::get(this,"","vif", vif))
      `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: build_phase

  // UVM run_phase
  task run_phase(uvm_phase phase);
    forever begin
      // Get new item from the sequencer
      seq_item_port.get_next_item(req);
      // Drive the item
      send_to_dut(req);
      // Communicate item done to the sequencer
      seq_item_port.item_done();
    end
  endtask : run_phase

  task send_to_dut(input reg_item item);
    vif.write <= 0;
    vif.read  <= 0;
    vif.addr <= 0;
    @(negedge vif.clk);
    void'(this.begin_tr(item, "Register_Transaction"));

    vif.addr <= item.addr;

    if (item.reg_wr == REG_WR) begin  // WRITE protocol
      vif.write <= 1;
      vif.read  <= 0;
      vif.data_in  <= item.data;
      @(negedge vif.clk);
      vif.write <= 0;
    end
    else begin  // READ protocol
      vif.write <= 0;
      vif.read  <= 1;
      @(negedge vif.clk);
      vif.read <= 0;
      item.data = vif.data_out;
    end
    @(posedge vif.clk);
    // finish item recording
    this.end_tr(item);
  endtask : send_to_dut

endclass : reg_driver
