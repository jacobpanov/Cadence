// Jacob Panov
// YAPP Sequencer Module
// yapp_tx_sequencer.sv

class yapp_tx_sequencer extends uvm_sequencer #(yapp_packet);

  yapp_packet packet;

  `uvm_component_utils(yapp_tx_sequencer)

  function new(string name, uvm_component parent);   
    super.new(name, parent);     // important!!
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH)
  endfunction : start_of_simulation_phase

endclass : yapp_tx_sequencer