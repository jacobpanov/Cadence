/*-----------------------------------------------------------------
File name     : reg_monitor.sv
Developers    : 
Created       :
Description   :
              :
              :
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: reg_monitor
//
//------------------------------------------------------------------------------

class reg_monitor extends uvm_monitor;

  // Collected Data handle
  reg_item regtr;

  virtual interface reg_if vif;

  // analysis port for lab09*
  uvm_analysis_port#(reg_item) monitor_reg_port;

  `uvm_component_utils(reg_monitor)

  function new (string name, uvm_component parent);
    super.new(name, parent);
    monitor_reg_port = new("monitor_reg_port",this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    if (!reg_vif_config::get(this, get_full_name(),"vif", vif))
      `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Inside the run() phase", UVM_MEDIUM)
    collect_items();
  endtask : run_phase

  task collect_items();
    forever begin
      @(posedge vif.clk iff (vif.write | vif.read));
      if (vif.write & vif.read)
        `uvm_error("REG_WR","Register read/write error") 
      else begin
        regtr = reg_item::type_id::create("regtr",this);
        void'(this.begin_tr(regtr, "Register_item"));
        regtr.addr = vif.addr;
        if (vif.write) begin
          regtr.reg_wr = REG_WR;
          regtr.data = vif.data_in;
          `uvm_info("REG_WR",$sformatf("Write collected- Address:%d  Data:%h", regtr.addr, regtr.data),UVM_HIGH)
        end
        else begin  // READ protocol
          regtr.reg_wr = REG_RD;
          @(negedge vif.clk);
          regtr.data = vif.data_out;
          `uvm_info("REG_WR",$sformatf("Read collected- Address:%d  Data:%h", regtr.addr, regtr.data),UVM_HIGH)
        end
      // finish transaction recording
      this.end_tr(regtr);
      monitor_reg_port.write(regtr);
      end
    end
  endtask  

endclass : reg_monitor
