// Jacob Panov
// UVM Router Testbench
// router_tb.sv

class router_tb extends uvm_env;

    `uvm_component_utils(router_tb)

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

    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        mcsequencer.hbus_seqr = hbus.masters[0].sequencer;
        mcsequencer.yapp_seqr = yapp.tx_agent.sequencer;

        yapp.rx_agent.analysis_port.connect(scoreboard.yapp_analysis_imp);
        chan0.rx_agent.analysis_port.connect(scoreboard.channel0_analysis_imp);
        chan1.rx_agent.analysis_port.connect(scoreboard.channel1_analysis_imp);
        chan2.rx_agent.analysis_port.connect(scoreboard.channel2_analysis_imp);
        
    endfunction : connect_phase

endclass : router_tb