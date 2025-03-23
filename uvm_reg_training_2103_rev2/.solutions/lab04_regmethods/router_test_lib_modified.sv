/*-----------------------------------------------------------------
File name     : router_test_lib.sv
Developers    : Kathleen Meade, Brian Dickinson
Created       : 01/04/11
Description   : lab09_sb router test library with multichannel sequences
Notes         : From the Cadence "SystemVerilog Accelerated Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: base_test
//
//------------------------------------------------------------------------------

class base_test extends uvm_test;

  // component macro
  `uvm_component_utils(base_test)

  // Testbench handle
  router_tb tb;

  // Register Model and Register Block handles
  yapp_router_regs_t yapp_rm;                     
  yapp_regs_block regs;  

  // YAPP UVC sequencer handle
  yapp_tx_sequencer yapp_seqr;

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // UVM build_phase() phase
  function void build_phase(uvm_phase phase);
    uvm_config_int::set( this, "*", "recording_detail", 1);
    super.build_phase(phase);
    tb = router_tb::type_id::create("tb", this);
  endfunction : build_phase


  // connect phase to connect model and sequencer handles
  function void connect_phase(uvm_phase phase);
    yapp_rm = tb.yapp_rm;
    regs = tb.yapp_rm.router_yapp_regs;
    yapp_seqr = tb.yapp.tx_agent.sequencer;
  endfunction : connect_phase  

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  // start_of_simulation added for lab03
  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), {"start of simulation for ", get_full_name()}, UVM_HIGH);
  endfunction : start_of_simulation_phase

  task run_phase(uvm_phase phase);
    uvm_objection obj = phase.get_objection();
    obj.set_drain_time(this, 2000ns);
  endtask : run_phase

  function void check_phase(uvm_phase phase);
    // configuration checker
    check_config_usage();
  endfunction

endclass : base_test

//------------------------------------------------------------------------------
//
// CLASS: simple_test
// simple integration test 
//
//------------------------------------------------------------------------------

class simple_test extends base_test;

  // component macro
  `uvm_component_utils(simple_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    set_type_override_by_type(yapp_packet::get_type(),short_yapp_packet::get_type());
    uvm_config_wrapper::set(this, "tb.yapp.tx_agent.sequencer.run_phase",
                            "default_sequence",
                            yapp_012_seq::get_type());
    uvm_config_wrapper::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                            "default_sequence",
                            clk10_rst5_seq::get_type());
    uvm_config_wrapper::set(this, "tb.chan?.rx_agent.sequencer.run_phase",
                            "default_sequence",
                            channel_rx_resp_seq::get_type());
   super.build_phase(phase);
  endfunction : build_phase

endclass : simple_test

//------------------------------------------------------------------------------
//
// CLASS: test_uvc_integration
// Exhaustive packets integration test 
//
//------------------------------------------------------------------------------

class test_uvc_integration extends base_test;

  // component macro
  `uvm_component_utils(test_uvc_integration)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
   yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());
    uvm_config_wrapper::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                            "default_sequence",
                            clk10_rst5_seq::get_type());
    uvm_config_wrapper::set(this, "tb.hbus.masters[0].sequencer.run_phase",
                            "default_sequence",
                            hbus_small_packet_seq::get_type());
    uvm_config_wrapper::set(this, "tb.yapp.tx_agent.sequencer.run_phase",
                            "default_sequence",
                            test_uvc_seq::get_type());
    uvm_config_wrapper::set(this, "tb.chan?.rx_agent.sequencer.run_phase",
                            "default_sequence",
                            channel_rx_resp_seq::get_type());
    super.build_phase(phase);
  endfunction: build_phase

endclass : test_uvc_integration

//------------------------------------------------------------------------------
//
// CLASS: test_mc
// Multichannel sequencer test 
//
//------------------------------------------------------------------------------

class test_mc extends base_test;

  // component macro
  `uvm_component_utils(test_mc)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
   yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());
    uvm_config_wrapper::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                            "default_sequence",
                            clk10_rst5_seq::get_type());
    uvm_config_wrapper::set(this, "tb.mcsequencer.run_phase",
                            "default_sequence",
                            router_simple_mcseq::get_type());
    uvm_config_wrapper::set(this, "tb.chan?.rx_agent.sequencer.run_phase",
                            "default_sequence",
                            channel_rx_resp_seq::get_type());

   super.build_phase(phase);
  endfunction : build_phase

endclass : test_mc

//------------------------------------------------------------------------------
//
// CLASS: uvm_reset_test
//-----------------------------------------------------------------------------

class  uvm_reset_test extends base_test;

    uvm_reg_hw_reset_seq reset_seq;

  // component macro
  `uvm_component_utils(uvm_reset_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      reset_seq = uvm_reg_hw_reset_seq::type_id::create("uvm_reset_seq");
      super.build_phase(phase);
      uvm_config_wrapper::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                              "default_sequence",
                              clk10_rst5_seq::get_type());
  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
     phase.raise_objection(this, "Raising Objection to run uvm built in reset test");
     // Set the model property of the sequence to our Register Model instance
     reset_seq.model = tb.yapp_rm;
     // Execute the sequence (sequencer is already set in the testbench)
     reset_seq.start(null);
     phase.drop_objection(this," Dropping Objection to uvm built reset test finished");
  endtask

endclass : uvm_reset_test

//------------------------------------------------------------------------------
//
// CLASS: uvm_mem_walk_test
//-----------------------------------------------------------------------------

class  uvm_mem_walk_test extends base_test;

    uvm_mem_walk_seq mem_walk_seq;

  // component macro
  `uvm_component_utils(uvm_mem_walk_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      mem_walk_seq = uvm_mem_walk_seq::type_id::create("uvm_mem_walk_seq");
      super.build_phase(phase);
      uvm_config_wrapper::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                              "default_sequence",
                              clk10_rst5_seq::get_type());
  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
     phase.raise_objection(this, "Raising Objection to run uvm built in mem test");
     // Set the model property of the sequence to our Register Model instance
     mem_walk_seq.model = tb.yapp_rm;
     // Execute the sequence (sequencer is already set in the testbench)
     mem_walk_seq.start(null);
     phase.drop_objection(this," Dropping Objection to uvm built mem test finished");
  endtask

endclass : uvm_mem_walk_test

//------------------------------------------------------------------------------
//
// CLASS: simple_access_test
//-----------------------------------------------------------------------------

class simple_access_test extends base_test;

  // component macro
  `uvm_component_utils(simple_access_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      super.build_phase(phase);
      uvm_config_wrapper::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                              "default_sequence",
                              clk10_rst5_seq::get_type());
  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
     int rdata, wrdata;
     bit ok;
     uvm_status_e status;
     phase.raise_objection(this, "Raising Objection to run simple_access_test");
     // read/write access check - ctrl_reg
     // Front-door write a unique value.
     // Peek and check the DUT value matches.
     // Poke a new value.
     // Front-door read this new value.
    `uvm_info("SIMPLE_ACCESS", "RW test FDwr/peek/poke/FDrd ctrl_reg", UVM_NONE)
    
    wrdata = 8'h0f;
    regs.ctrl_reg.write(status, wrdata);
    `uvm_info("SIMPLE_ACCESS", $sformatf("WROTE FD ctrl_reg:%2h", wrdata), UVM_NONE)
    #50ns; // allow write to complete
    regs.ctrl_reg.peek(status, rdata);
    `uvm_info("SIMPLE_ACCESS", $sformatf("PEEK ctrl_reg:%2h",rdata), UVM_NONE)
    wrdata = 8'hf0;
    regs.ctrl_reg.poke(status, wrdata);
    `uvm_info("SIMPLE_ACCESS", $sformatf("POKE ctrl_reg:%2h", wrdata), UVM_NONE)
    regs.ctrl_reg.read(status, rdata);
    `uvm_info("SIMPLE_ACCESS", $sformatf("READ FD ctrl_reg:%2h",rdata), UVM_NONE)
    ok = regs.ctrl_reg.predict(8'h00);
    regs.ctrl_reg.mirror(status, UVM_CHECK);

    `uvm_info("SIMPLE_ACCESS", "RO test poke/FDrd/FDwr/peek addr0_cnt_reg", UVM_NONE)
    regs.addr0_cnt_reg.poke(status, wrdata);
    `uvm_info("SIMPLE_ACCESS", $sformatf("POKE addr0_cnt_reg:%2h", wrdata), UVM_NONE)
    regs.addr0_cnt_reg.read(status, rdata);
    `uvm_info("SIMPLE_ACCESS", $sformatf("READ FD addr0_cnt_reg:%2h", rdata), UVM_NONE)
    wrdata = 8'h0f;
    regs.addr0_cnt_reg.write(status, wrdata);
    `uvm_info("SIMPLE_ACCESS", $sformatf("WROTE FD addr0_cnt_reg:%2h (should be ignored)", wrdata), UVM_NONE)  
    #50ns; // allow write to complete
    regs.addr0_cnt_reg.peek(status, rdata);
    `uvm_info("SIMPLE_ACCESS", $sformatf("PEEK addr0_cnt_reg:%2h", rdata), UVM_NONE)

     phase.drop_objection(this, "Raising Objection to run simple_access_test");
     
  endtask

endclass : simple_access_test

//------------------------------------------------------------------------------
//
// CLASS: simple_function_test
//-----------------------------------------------------------------------------

class simple_function_test extends base_test;

  // component macro
  `uvm_component_utils(simple_function_test)

  yapp_012_seq yapp012; 

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      super.build_phase(phase);
      uvm_config_wrapper::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                              "default_sequence",
                              clk10_rst5_seq::get_type());
      uvm_config_wrapper::set(this, "tb.chan?.rx_agent.sequencer.run_phase",
                              "default_sequence",
                              channel_rx_resp_seq::get_type());
      yapp012 = yapp_012_seq::type_id::create("yapp012", this); 
  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
     int rdata, wrdata;
     bit ok;
     uvm_status_e status;
     phase.raise_objection(this, "Raising Objection to run simple_access_test");
    
     // enable router
    regs.en_reg.write(status, 8'h01);
    `uvm_info("SIMPLE_FUNCTION", "Enable router: en_reg:8'h01", UVM_NONE)
     // Max pkt size 63
    regs.ctrl_reg.write(status, 8'h3f);
    `uvm_info("SIMPLE_FUNCTION", "Max Pkt Size: ctrl_reg:8'h3f", UVM_NONE)

    yapp012.start(yapp_seqr);

    regs.addr0_cnt_reg.mirror(status,UVM_CHECK);
    regs.addr1_cnt_reg.mirror(status,UVM_CHECK);
    regs.addr2_cnt_reg.mirror(status,UVM_CHECK);
    regs.addr3_cnt_reg.mirror(status,UVM_CHECK);

    regs.en_reg.write(status, 8'b1110001);
    `uvm_info("SIMPLE_FUNCTION", "Enable counters and router: en_reg:8'hf1", UVM_NONE)

    repeat(2)
      yapp012.start(yapp_seqr);

    // predict packet counter registers
    ok = regs.addr0_cnt_reg.predict(2);
    ok = regs.addr1_cnt_reg.predict(2);
    ok = regs.addr2_cnt_reg.predict(2);
    ok = regs.addr3_cnt_reg.predict(0);

    // read and check counter registers
    regs.addr0_cnt_reg.mirror(status, UVM_CHECK);
    regs.addr1_cnt_reg.mirror(status, UVM_CHECK);
    regs.addr2_cnt_reg.mirror(status, UVM_CHECK);
    regs.addr3_cnt_reg.mirror(status, UVM_CHECK);

    ok = regs.addr0_cnt_reg.predict(5);
    regs.addr0_cnt_reg.mirror(status, UVM_CHECK);
    phase.drop_objection(this, "Raising Objection to run simple_function_test");
     
  endtask

endclass : simple_function_test


