// Jacob Panov
// YAPP Input port transmit driver
// yapp_tx_driver.sv

class yapp_tx_driver extends uvm_driver #(yapp_packet);

    virtual interface yapp_if vif;
    int num_sent;
    
    `uvm_component_utils_begin(yapp_tx_driver)
        `uvm_field_int(num_sent, UVM_ALL_ON)
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
        fork
        get_and_drive();
        reset_signals();
        join
    endtask : run_phase

    task get_and_drive();
        @(posedge vif.reset);
        @(negedge vif.reset);
        `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM)
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info(get_type_name(), $sformatf("Sending Packet :\n%s", req.sprint()), UVM_HIGH)
       
            fork
                begin
                foreach (req.payload[i])
                    vif.payload_mem[i] = req.payload[i];
                    vif.send_to_dut(req.length, req.addr, req.parity, req.packet_delay);
                end
                @(posedge vif.drvstart) void'(begin_tr(req, "Driver_YAPP_Packet"));
            join

            end_tr(req);
            num_sent++;
            seq_item_port.item_done();
        end
    endtask : get_and_drive

    task reset_signals();
        forever vif.yapp_reset();
    endtask : reset_signals

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("\nReport: yapp_tx_driver sent %0d packets\n", num_sent), UVM_LOW)
    endfunction : report_phase

endclass : yapp_tx_driver