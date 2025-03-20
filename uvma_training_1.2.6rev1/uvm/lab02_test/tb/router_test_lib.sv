// Jacob Panov
// UVM Router Testbench Library
// router_test_lib.sv

class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    router_tb tb;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tb = new("tb", this);
        `uvm_info("MSG", "\nTest build phase executed\n", UVM_HIGH)
    endfunction : build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

endclass : base_test

class test2 extends base_test;

  `uvm_component_utils(test2)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : test2