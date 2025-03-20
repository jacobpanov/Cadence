// Jacob Panov
// UVM Router Testbench
// router_tb.sv

class router_tb extends uvm_env;

    `uvm_component_utils(router_tb)

    yapp_env yapp;

    function new (string name, uvm_component parent=null);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        `uvm_info("MSG","\nIn the build phase",UVM_HIGH)
        super.build_phase(phase);
        yapp = new("yapp", this);
    endfunction : build_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"\nstart of simulation for ", get_full_name()}, UVM_HIGH)
    endfunction : start_of_simulation_phase

endclass : router_tb