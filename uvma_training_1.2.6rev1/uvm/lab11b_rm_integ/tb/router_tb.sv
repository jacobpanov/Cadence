// Jacob Panov
// UVM Router Testbench
// router_tb.sv

class router_tb extends uvm_env;

    yapp_router_regs_t yapp_rm;
    hbus_reg_adapter reg2hbus

    `uvm_component_utils_begin(router_tb)
        `uvm_field_object(yapp_rm, UVM_ALL_ON)
    `uvm_component_utils_end

    yapp_env yapp;

    channel_env chan0;
    channel_env chan1;
    channel_env chan2;

    clock_and_reset_env clock_and_reset;

    hbus_env hbus;

    router_mcsequencer mcsequencer;

    router_scoreboard scoreboard;

    function new (string name, uvm_component parent=null);
        super.new(name,parent);
    endfunction : new

    function void build_phase(uvm_phase phase);

        `uvm_info("MSG","In the build phase",UVM_HIGH)
        super.build_phase(phase);
        clock_and_reset = clock_and_reset_env::type_id::create("clock_and_reset", this);
        yapp = yapp_env::type_id::create("yapp", this);

        uvm_config_int::set(this, "chan0", "channel_id", 0);
        uvm_config_int::set(this, "chan1", "channel_id", 1);
        uvm_config_int::set(this, "chan2", "channel_id", 2);
        chan0 = channel_env::type_id::create("chan0", this);
        chan1 = channel_env::type_id::create("chan1", this);
        chan2 = channel_env::type_id::create("chan2", this);

        uvm_config_int::set(this, "hbus", "num_masters", 1);
        uvm_config_int::set(this, "hbus", "num_slaves", 0);
        hbus = hbus_env::type_id::create("hbus", this);

        mcsequencer = router_mcsequencer::type_id::create("mcsequencer", this);

        scoreboard = router_scoreboard::type_id::create("scoreboard", this);

         // router module UVC
        router_mod = router_env::type_id::create("router_mod", this);

        // register model
        yapp_rm = yapp_router_regs_t::type_id::create("yapp_rm",this);
        yapp_rm.build();
        yapp_rm.lock_model();
        yapp_rm.set_hdl_path_root("hw_top.dut");

        // This is implicit prediction, so make sure auto_predict is turned on.
        //  Default is to have an explicit predictor and auto_predict disabled
        yapp_rm.default_map.set_auto_predict(1);

        // Create the adapter 
        reg2hbus= hbus_reg_adapter::type_id::create("reg2bus",this);

    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        
        mcsequencer.hbus_seqr = hbus.masters[0].sequencer;
        mcsequencer.yapp_seqr = yapp.tx_agent.sequencer;

        yapp.tx_agent.monitor.item_collected_port.connect(scoreboard.yapp_analysis_imp);
        hbus.masters[0].monitor.item_collected_port.connect(router_mod.reference.hbus_in);
        chan0.rx_agent.monitor.item_collected_port.connect(scoreboard.channel0_analysis_imp);
        chan1.rx_agent.monitor.item_collected_port.connect(scoreboard.channel1_analysis_imp);
        chan2.rx_agent.monitor.item_collected_port.connect(scoreboard.channel2_analysis_imp);

        yapp_rm.defailt_map.set_sequencer(hbus.masters[0].sequencer, reg2hbus);
        
    endfunction : connect_phase

endclass : router_tb