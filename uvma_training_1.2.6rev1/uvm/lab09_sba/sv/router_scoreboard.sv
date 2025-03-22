// Jacob Panov
// UVM Scoreboard for Router
// router_scoreboard.sv

typedef enum bit {EQUALITY, UVM} comp_t;

class router_scoreboard extends uvm_scoreboard;

  `uvm_analysis_imp_decl(_yapp)
  `uvm_analysis_imp_decl(_channel0)
  `uvm_analysis_imp_decl(_channel1)
  `uvm_analysis_imp_decl(_channel2)

  uvm_analysis_imp_yapp #(yapp_packet, router_scoreboard) yapp_analysis_imp;
  uvm_analysis_imp_channel0 #(channel_packet, router_scoreboard) channel0_analysis_imp;
  uvm_analysis_imp_channel1 #(channel_packet, router_scoreboard) channel1_analysis_imp;
  uvm_analysis_imp_channel2 #(channel_packet, router_scoreboard) channel2_analysis_imp;

  // Queues for each address
  yapp_packet queue_yapp[$];
  channel_packet queue_channel0[$];
  channel_packet queue_channel1[$];
  channel_packet queue_channel2[$];

  // Counters
  int num_packets_received;
  int num_wrong_packets;
  int num_matched_packets;

  yapp_packet sb_packet;

  comp_t compare_policy = UVM; 
   
   `uvm_component_utils_begin(router_scoreboard)
     `uvm_field_enum(comp_t, compare_policy, UVM_ALL_ON)
   `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name, parent);
    num_packets_received = 0;
    num_wrong_packets = 0;
    num_matched_packets = 0;
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    yapp_analysis_imp = new("yapp_analysis_imp", this);
    channel0_analysis_imp = new("channel0_analysis_imp", this);
    channel1_analysis_imp = new("channel1_analysis_imp", this);
    channel2_analysis_imp = new("channel2_analysis_imp", this);
  endfunction : build_phase

  // Custom comparison function
  function bit packet_compare(yapp_packet pkt1, channel_packet pkt2);
    // Implement your comparison logic here
    return (pkt1.field1 == pkt2.field1) && (pkt1.field2 == pkt2.field2);
  endfunction : packet_compare

  // Write implementation for YAPP
  virtual task write_yapp(yapp_packet pkt);
    `uvm_info(get_type_name(), $sformatf("Scoreboard Received YAPP Packet: %s", pkt.sprint()), UVM_LOW)
    $cast(sb_packet, pkt.clone()); // Correct syntax for cloning a packet
    queue_yapp.push_back(sb_packet);
    num_packets_received++;
  endtask : write_yapp

  // Write implementation for Channel 0
  virtual task write_channel0(channel_packet pkt);
    `uvm_info(get_type_name(), $sformatf("Scoreboard Received Channel Packet 0: %s", pkt.sprint()), UVM_LOW)
    if (queue_yapp.size() > 0) begin
      yapp_packet yapp_pkt = queue_yapp.pop_front();
      if (packet_compare(yapp_pkt, pkt)) begin
        `uvm_info(get_type_name(), "Packets match", UVM_LOW)
        num_matched_packets++;
      end else begin
        `uvm_error(get_type_name(), "Packets do not match")
        num_wrong_packets++;
      end
    end else begin
      `uvm_error(get_type_name(), "No YAPP packets in queue to compare")
    end
    num_packets_received++;
  endtask : write_channel0

  // Write implementation for Channel 1
  virtual task write_channel1(channel_packet pkt);
    `uvm_info(get_type_name(), $sformatf("Scoreboard Received Channel Packet 1: %s", pkt.sprint()), UVM_LOW)
    if (queue_yapp.size() > 0) begin
      yapp_packet yapp_pkt = queue_yapp.pop_front();
      if (packet_compare(yapp_pkt, pkt)) begin
        `uvm_info(get_type_name(), "Packets match", UVM_LOW)
        num_matched_packets++;
      end else begin
        `uvm_error(get_type_name(), "Packets do not match")
        num_wrong_packets++;
      end
    end else begin
      `uvm_error(get_type_name(), "No YAPP packets in queue to compare")
    end
    num_packets_received++;
  endtask : write_channel1

  // Write implementation for Channel 2
  virtual task write_channel2(channel_packet pkt);
    `uvm_info(get_type_name(), $sformatf("Scoreboard Received Channel Packet 2: %s", pkt.sprint()), UVM_LOW)
    if (queue_yapp.size() > 0) begin
      yapp_packet yapp_pkt = queue_yapp.pop_front();
      if (packet_compare(yapp_pkt, pkt)) begin
        `uvm_info(get_type_name(), "Packets match", UVM_LOW)
        num_matched_packets++;
      end else begin
        `uvm_error(get_type_name(), "Packets do not match")
        num_wrong_packets++;
      end
    end else begin
      `uvm_error(get_type_name(), "No YAPP packets in queue to compare")
    end
    num_packets_received++;
  endtask : write_channel2

  // Report phase
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Number of packets received: %0d", num_packets_received), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Number of matched packets: %0d", num_matched_packets), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Number of wrong packets: %0d", num_wrong_packets), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Number of YAPP packets left in queue: %0d", queue_yapp.size()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Number of Channel 0 packets left in queue: %0d", queue_channel0.size()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Number of Channel 1 packets left in queue: %0d", queue_channel1.size()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Number of Channel 2 packets left in queue: %0d", queue_channel2.size()), UVM_LOW)
  endfunction : report_phase

endclass : router_scoreboard