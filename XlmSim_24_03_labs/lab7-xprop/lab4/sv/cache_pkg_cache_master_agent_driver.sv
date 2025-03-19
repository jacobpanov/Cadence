// IVB checksum: 681322955
/*-----------------------------------------------------------------
File name     : cache_pkg_cache_master_agent_driver.sv
Developers    : araheja
Created       : Wed Nov  2 11:42:23 2011
Description   : This files implements the cache_master_agent driver functionality.
Notes         : 
-------------------------------------------------------------------
Copyright  (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: cache_pkg_cache_master_agent_driver
//
//------------------------------------------------------------------------------

class cache_pkg_cache_master_agent_driver extends uvm_driver #(cache_pkg_cache_packet);

 /***************************************************************************
  IVB-NOTE : REQUIRED : cache_master_agent DRIVER functionality : DRIVER
  -------------------------------------------------------------------------
  Modify the following methods to match your protocol:
    o drive_cache_packet() - Handshake and cache_packet driving process
    o reset_signals() - cache_master_agent signal reset values
  Note that if you change/add signals to the physical interface, you must
  also change these methods.
  ***************************************************************************/

  // The virtual interface used to drive and view HDL signals.
  protected virtual interface cache_pkg_if vif;
 
  // Count cache_packets sent
  int num_sent;

  // Provide implmentations of virtual methods such as get_type_name and create
  `uvm_component_utils(cache_pkg_cache_master_agent_driver)

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Additional class methods
  extern virtual task run_phase(uvm_phase phase);
  extern virtual protected task get_and_drive();
  extern virtual protected task reset_signals();
  extern virtual protected task drive_cache_packet(cache_pkg_cache_packet cache_packet);
  extern virtual function void report_phase(uvm_phase phase);

  virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);

    if(!uvm_config_db#(virtual cache_pkg_if)::get(this,"","vif",vif))
	`uvm_error(get_type_name(),"virtual if not configured cache master driver");

  endfunction
endclass : cache_pkg_cache_master_agent_driver

  // UVM run() phase
  task cache_pkg_cache_master_agent_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);
    $display("****************Run Phase of cache_master_driver****************");
    fork
      get_and_drive();
      reset_signals();
    join
  endtask

  // Gets cache_packets from the sequencer and passes them to the driver. 
  task cache_pkg_cache_master_agent_driver::get_and_drive();
    @(posedge vif.reset);
    `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM)
    forever begin
      @(posedge vif.clock);
      // Get new item from the sequencer
      seq_item_port.get_next_item(req);
      // Drive the item
      drive_cache_packet(req);
      // Communicate item done to the sequencer
      seq_item_port.item_done();
    end
  endtask : get_and_drive

  // Reset all cache_master_agent signals
  task cache_pkg_cache_master_agent_driver::reset_signals();
    forever begin
      @(negedge vif.reset);
      `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
      //vif.sig_data <= 'hz;
      //vif.sig_valid <= 1'b0;
      vif.req      <= 1'b0;
      vif.addr_in  <= 32'bz;
      vif.data_in  <= 32'bz;
      vif.rdwr     <= 1'bz;
    end
  endtask : reset_signals

  // Gets a cache_packet and drive it into the DUT
  task cache_pkg_cache_master_agent_driver::drive_cache_packet(cache_pkg_cache_packet cache_packet);
    int cnt;
/*
    vif.sig_valid <= 1'b1;  
    vif.sig_data <= cache_packet.data;
    @(posedge vif.sig_clock iff vif.sig_ack === 1);
    vif.sig_valid <= 1'b0;
    vif.sig_data <= 'hz;
    @(posedge vif.sig_clock);    
    num_sent++;
    `uvm_info(get_type_name(), $sformatf("Item %0d Sent ...", num_sent),
      UVM_HIGH)
*/

        int slave_indx;
        vif.req <= 1'b1;
        vif.addr_in <= cache_packet.addr;


  
        if (cache_packet.direction == READ) begin
            $display("READ operation");
            vif.rdwr    <= 1'b0;
        end    
        else begin
            $display("WRITE operation");
            vif.rdwr    <= 1'b1;
            vif.data_in <= cache_packet.data;
        end

        @(posedge vif.gnt) begin
          vif.req = 'b0;
          $display("Grant for request has been received");
        end

        if (cache_packet.direction == READ) begin
          @(posedge vif.data_rdy) begin
            data_type tmp;
            @(negedge vif.clock)
            tmp = vif.data_out;
            //is_hit_miss(vif);
          end
        end

        if (cache_packet.direction == WRITE) begin
          @(negedge vif.busy) begin
            //is_hit_miss(vif);
          end
        end

        @(posedge vif.clock);
  endtask : drive_cache_packet

  // UVM report() phase
  function void cache_pkg_cache_master_agent_driver::report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), 
      $sformatf("\nReport: CACHE_PKG cache_master_agent driver sent %0d cache_packets",
      num_sent), UVM_LOW)
  endfunction 
