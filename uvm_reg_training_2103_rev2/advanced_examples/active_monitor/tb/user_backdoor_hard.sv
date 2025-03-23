/*-----------------------------------------------------------------
File name     : user_backdoor_hard.sv
Developers    : Brian Dickinson
Created       : 01/04/22
Description   : Hardwired user-defined backdoor connected
                to DUT via hierarchical pathname for UVM register active monitoring
Notes         : From the Cadence "SystemVerilog Advanced Register Verification with UVM" training
                Refer to training material for details of code
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2022
-----------------------------------------------------------------*/

class active_monitor_bkdr extends uvm_reg_backdoor;

  function new(string name = "");
    super.new(name);
  endfunction

  function void read_func(uvm_reg_item rw);
    // overload for backdoor access
    rw.value = new[1];
    rw.value[0] = DUT.reg_six;
    rw.status= UVM_IS_OK;
  endfunction

  // called by backdoor to detect a change on a DUT signal
  virtual local task wait_for_change(uvm_object element);
    // change in value of reg_six in interface
    @(DUT.reg_six);
    `uvm_info("BKDR",$sformatf("detected change %0d",DUT.reg_six),UVM_LOW)
  endtask
  
  // must return 1 to update the mirrored value
  function bit is_auto_updated(uvm_reg_field field);
    return 1;
  endfunction
endclass
