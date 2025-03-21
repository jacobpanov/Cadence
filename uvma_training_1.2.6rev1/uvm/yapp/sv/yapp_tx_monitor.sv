// Jacob Panov
// YAPP Input port monitor
// yapp_tx_monitor.sv

class yapp_tx_monitor extends uvm_monitor;

    yapp_packet pkt;
    int num_pkts;
    virtual interface yapp_if vif;

    `uvm_component_utils_begin(yapp_tx_monitor)
        `uvm_field_int(num_pkts, UVM_ALL_ON)
    `uvm_component_utils_end

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void connect_phase(uvm_phase phase);
    if (!yapp_vif_config::get(this, get_full_name(),"vif", vif))
      `uvm_error("NOVIF",{"\n\nvirtual interface must be set for: ",get_full_name(),".vif"})
    endfunction: connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"\nstart of simulation for ", get_full_name()}, UVM_HIGH)
    endfunction : start_of_simulation_phase

    task run_phase(uvm_phase phase);
        @(posedge vif.reset)
        @(negedge vif.reset)
        `uvm_info(get_type_name(), "\nDetected Reset Done\n", UVM_MEDIUM)
        forever begin 
            pkt = yapp_packet::type_id::create("pkt", this);
            
            fork
                vif.collect_packet(pkt.length, pkt.addr, pkt.payload, pkt.parity);
                @(posedge vif.monstart) void'(begin_tr(pkt, "Monitor_YAPP_Packet"));
            join

            pkt.parity_type = (pkt.parity == pkt.calc_parity()) ? GOOD_PARITY : BAD_PARITY;
            end_tr(pkt);
            `uvm_info(get_type_name(), $sformatf("\nPacket Collected :\n%s", pkt.sprint()), UVM_LOW)
            num_pkts++;
        end
    endtask : run_phase

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Report: YAPP Monitor Collected %0d Packets", num_pkts), UVM_LOW)
    endfunction : report_phase

endclass : yapp_tx_monitor