// Jacob Panov
// YAPP Input port monitor
// yapp_tx_monitor.sv

class yapp_tx_monitor extends uvm_monitor;

    `uvm_component_utils_begin(yapp_tx_monitor)
    `uvm_component_utils_end

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"\nstart of simulation for ", get_full_name()}, UVM_HIGH)
    endfunction : start_of_simulation_phase

    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "\nInside the monitor\n", UVM_LOW);
    endtask : run_phase

endclass : yapp_tx_monitor