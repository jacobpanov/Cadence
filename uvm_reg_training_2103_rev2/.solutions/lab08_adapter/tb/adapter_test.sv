
//------------------------------------------------------------------------------
//
// CLASS: adapter_ext_test
//-----------------------------------------------------------------------------

class adapter_ext_test extends base_test;

  // component macro
  `uvm_component_utils(adapter_ext_test)

  // handle on adapter extension
  adapter_ext ext;

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      super.build_phase(phase);
     ext =  adapter_ext::type_id::create("ext", this);
  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
     uvm_status_e wstatus;
     // call base_test run_phase to inherit set drain time
     super.run_phase(phase);
     phase.raise_objection(this, "Raising Objection to run uvm built in reset test");

     ext.info = "Extension Information";

    `uvm_info("ADAPTER_EXT", "Write en_reg with extension data", UVM_NONE)
     regs.en_reg.write(.status(wstatus), .value(8'hff), .extension(ext));
    #20ns; // allow write to complete

     phase.drop_objection(this," Dropping Objection to uvm built reset test finished");
     
  endtask

endclass : adapter_ext_test


