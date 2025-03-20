// Jacob Panov
// YAPP Input port agent
// yapp_tx_agent.sv

class yapp_tx_agent extends uvm_agent;

    `uvm_component_utils_begin(yapp_tx_agent)
    `uvm_component_utils_end

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"\nstart of simulation for ", get_full_name()}, UVM_HIGH)
    endfunction : start_of_simulation_phase

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = new("monitor", this);
        if (is_active == UVM_ACTIVE) begin
            sequencer = new("sequencer", this);
            driver = new("driver", this);
        end
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        if(is_active == UVM_ACTIVE) driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction : connect_phase

endclass : yapp_tx_agent