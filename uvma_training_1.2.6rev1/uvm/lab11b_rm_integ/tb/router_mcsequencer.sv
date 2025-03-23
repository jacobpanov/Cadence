// Jacob Panov
// Yapp Router Multichannel Sequencer
// router_mcsequencer.sv

class router_mcsequencer extends uvm_sequencer;

    hbus_master_sequencer hbus_seqr;
    yapp_tx_sequencer yapp_seqr;

    `uvm_component_utils(router_mcsequencer)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : router_mcsequencer