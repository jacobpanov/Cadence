/*-----------------------------------------------------------------
File name     : router_reference.sv
Developers    : Kathleen Meade, Brian Dickinson
Created       : 01/04/11
Description   : router module UVC reference model for lab09_sbc 
Notes         : From the Cadence "SystemVerilog Accelerated Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------//
// CLASS: router_reference
//
//------------------------------------------------------------------------------
class router_reference extends uvm_component;
 
   //TLM port declarations
   `uvm_analysis_imp_decl(_hbus)  
   `uvm_analysis_imp_decl(_yapp) 

   //TLM exports connected to interface UVC's
   uvm_analysis_imp_hbus  #(hbus_transaction, router_reference) hbus_in;
   uvm_analysis_imp_yapp  #(yapp_packet, router_reference) yapp_in;

   // TLM ports to connect to scoreboard
   uvm_analysis_port #(yapp_packet) sb_add_out;
      
   // Configuration Information
   bit [7:0] max_pktsize_reg = 8'h3F;
   bit [7:0] router_enable_reg = 1'b1;
      
   // Monitor Statistics
   int packets_dropped   = 0;
   int packets_forwarded = 0;
   int jumbo_packets     = 0;
   int bad_addr_packets  = 0;
 
  // Register Model and Register Block handles
  yapp_router_regs_t yapp_rm;                     
  yapp_regs_block regs;  

  function void get_reg_model();
    if (! uvm_config_db#(yapp_router_regs_t)::get(this, "", "yapp_rm", yapp_rm) )
      `uvm_fatal(get_type_name(), "Failed to get register model")
    if (yapp_rm == null)
      `uvm_fatal(get_type_name(), "yapp_rm from config_db is null")
    regs = yapp_rm.router_yapp_regs;
  endfunction

   `uvm_component_utils_begin(router_reference)
    `uvm_field_object(yapp_rm, UVM_ALL_ON)
  `uvm_component_utils_end
  
   function new (string name = "", uvm_component parent = null);
     super.new(name, parent);
     // TLM Connections to Interface UVCs
     hbus_in  = new("hbus_in",  this);
     yapp_in  = new("yapp_in",  this);
     // TLM Connections to the Scoreboard
     sb_add_out    = new("sb_add_out", this);
   endfunction: new

  function void connect_phase(uvm_phase phase);
    get_reg_model();
  endfunction

  // UVM report_phase
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report:\n   Router Reference: Packet Statistics \n     Packets Dropped:   %0d\n     Packets Forwarded: %0d\n     Oversized Packets: %0d\n", packets_dropped, packets_forwarded, jumbo_packets ), UVM_LOW)
    yapp_rm.print();
  endfunction : report_phase

  // HBUS transaction TLM write implementation
  function void write_hbus(hbus_transaction hbus_cmd);
//    `uvm_info(get_type_name(),
//      $sformatf("Received HBUS Transaction: \n%s", hbus_cmd.sprint()), UVM_MEDIUM)
    // For now - capture the max_pktsize_reg and router_enable_reg
    // values whenever a hbus transaction is written
//    if (hbus_cmd.hwr_rd == HBUS_WRITE)
//      case (hbus_cmd.haddr)
//        'h1000 : max_pktsize_reg = hbus_cmd.hdata;
//        'h1001 : router_enable_reg = hbus_cmd.hdata;
//      endcase
  endfunction

  // YAPP transaction TLM write implementation
  function void write_yapp(yapp_packet packet);
    int counter, ok;
    
    `uvm_info(get_type_name(),
      $sformatf("Received Input YAPP Packet: \n%s", packet.sprint()), UVM_LOW)
    max_pktsize_reg = regs.ctrl_reg.max_pkt_size.get_mirrored_value();
    router_enable_reg = regs.en_reg.router_en.get_mirrored_value();
      
    // Check if router is enabled and  packet has "valid size" before 
    // sending to scoreboard
    if (packet.addr == 3) begin
      // address 3 packet
      bad_addr_packets++;
      packets_dropped++;
      `uvm_info(get_type_name(), "YAPP Packet Dropped [BAD ADDRESS]", UVM_LOW)
      // Prediction: increment model address 3 counter if enabled
      if ((regs.en_reg.addr3_cnt_en.get_mirrored_value() == 1) ) begin
        counter = regs.addr3_cnt_reg.get_mirrored_value();
        ok = regs.addr3_cnt_reg.predict(counter + 1);
        `uvm_info(get_type_name(), $sformatf("Increment addr3 counter to %0d", counter), UVM_LOW)
      end
    end
    else if ((router_enable_reg != 0) && (packet.length <= max_pktsize_reg)) begin
      // Valid packet
      // Send packet to Scoreboard via TLM port
      sb_add_out.write(packet);
      packets_forwarded++;
      `uvm_info(get_type_name(), "Sent YAPP Packet to Scoreboard", UVM_LOW)
                  `uvm_info(get_type_name(), $sformatf("Enables %b", regs.en_reg.get_mirrored_value()), UVM_LOW)
      // Prediction: increment model address 012 counters if enabled
      case (packet.addr)
        2'b00:  if ((regs.en_reg.addr0_cnt_en.get_mirrored_value() == 1) ) begin
                  counter = regs.addr0_cnt_reg.get_mirrored_value();
                  ok = regs.addr0_cnt_reg.predict(counter + 1);
                  `uvm_info(get_type_name(), $sformatf("Increment addr0 counter to %0d", counter), UVM_LOW)
                end
        2'b01:  if ((regs.en_reg.addr1_cnt_en.get_mirrored_value() == 1) ) begin
                  counter = regs.addr1_cnt_reg.get_mirrored_value();
                  ok = regs.addr1_cnt_reg.predict(counter + 1);
                  `uvm_info(get_type_name(), $sformatf("Increment addr1 counter to %0d", counter), UVM_LOW)
                end
        2'b10:  if ((regs.en_reg.addr2_cnt_en.get_mirrored_value() == 1) ) begin
                  counter = regs.addr2_cnt_reg.get_mirrored_value();
                  ok = regs.addr2_cnt_reg.predict(counter + 1);
                  `uvm_info(get_type_name(), $sformatf("Increment addr2 counter to %0d", counter), UVM_LOW)
                end
        2'b11: ; // address 3 counter already dealt with
      endcase
      if (packet.calc_parity() != packet.parity) 
        if ((regs.en_reg.parity_err_cnt_en.get_mirrored_value() == 1) ) begin
          counter = regs.parity_err_cnt_reg.get_mirrored_value();
          ok = regs.parity_err_cnt_reg.predict(counter + 1);
        end
    end
    else if ((router_enable_reg != 0) && (packet.length > max_pktsize_reg)) begin
      // Oversized packet dropped
      jumbo_packets++;
      packets_dropped++;
      `uvm_info(get_type_name(), $sformatf("YAPP Packet Dropped [OVERSIZED] - pkt size %h max size %h",packet.length, max_pktsize_reg), UVM_LOW)
      // Prediction: increment model oversized packet counter if enabled
      if ((regs.en_reg.oversized_pkt_cnt_en.get_mirrored_value() == 1) ) begin
        counter = regs.oversized_pkt_cnt_reg.get_mirrored_value();
        ok = regs.oversized_pkt_cnt_reg.predict(counter + 1);
      end
    end
    else if (router_enable_reg == 0) begin
      // Disabled router - packet dropped
      packets_dropped++;
      `uvm_info(get_type_name(), "YAPP Packet Dropped [DISABLED]", UVM_LOW)
    end
         
  endfunction

endclass: router_reference
