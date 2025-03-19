// IVB checksum: 1588456054
/*-----------------------------------------------------------------
File name     : cache_pkg_cache_master_agent_seq_lib.sv
Developers    : araheja
Created       : Wed Nov  2 11:42:23 2011
Description   : This file implements several sequence kinds
Notes         : Each sequence implements a typical scenario or a
              : combination of existing scenarios.
              : Cadence recommends defining reusable sequences in 
              : this directory and project-specific sequences in the
              : project directory ("examples").
-------------------------------------------------------------------
Copyright  (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// SEQUENCE: cache_pkg_cache_master_agent_cache_packet_seq
//
//------------------------------------------------------------------------------
 
/*
class cache_pkg_cache_master_agent_cache_packet_seq extends uvm_sequence #(cache_pkg_cache_packet);
  `uvm_object_utils(cache_pkg_cache_master_agent_cache_packet_seq)
  
  // Parameter for this sequence
  rand bit [31:0] s_data;

  // Constructor
  function new(string name="cache_pkg_cache_master_agent_cache_packet_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    begin
      `uvm_info(get_type_name(), "Executing...", UVM_HIGH)
      +`uvm_do_with(req, { req.data == s_data; } )
    end
  endtask

  virtual task pre_body();
    uvm_test_done.raise_objection(this);
  endtask

  virtual task post_body();
    uvm_test_done.drop_objection(this);
  endtask

endclass 
*/

class cache_pkg_cache_master_agent_cache_packet_seq extends uvm_sequence #(cache_pkg_cache_packet);
  `uvm_object_utils(cache_pkg_cache_master_agent_cache_packet_seq)
  
  // Parameter for this sequence
  rand bit [31:0] s_data, start_addr, write_data;
  constraint addr_ct {(262142 <= start_addr && start_addr <= 262148); }

  // Constructor
  function new(string name="cache_pkg_cache_master_agent_cache_packet_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    begin
      `uvm_info(get_type_name(), "Executing...", UVM_HIGH)
      //`uvm_do_with(req, { req.data == s_data; } )
      `uvm_do_with(req, { req.addr == start_addr; req.data == s_data; req.direction == WRITE; } )
      `uvm_do_with(req, { req.addr == start_addr; req.data == s_data; req.direction == READ; } )

    end
  endtask

  virtual task pre_body();
    uvm_test_done.raise_objection(this);
  endtask

  virtual task post_body();
    uvm_test_done.drop_objection(this);
  endtask

endclass 





class read_seq extends uvm_sequence #(cache_pkg_cache_packet);
  `uvm_object_utils(read_seq)
  
  // Parameter for this sequence
  rand bit [31:0] s_data, start_addr, write_data;
  //constraint addr_ct {(262142 <= start_addr && start_addr <= 262148); }
  constraint addr_ct {(11 <= start_addr && start_addr <= 19); }

  // Constructor
  function new(string name="read_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    begin
      `uvm_info(get_type_name(), "Executing...", UVM_HIGH)
      `uvm_do_with(req, { req.addr == start_addr; req.data == s_data; req.direction == READ; } )

    end
  endtask

  virtual task pre_body();
    uvm_test_done.raise_objection(this);
  endtask

  virtual task post_body();
    uvm_test_done.drop_objection(this);
  endtask

endclass




class x_read_seq extends uvm_sequence #(cache_pkg_cache_packet);
  `uvm_object_utils(x_read_seq)

  // Parameter for this sequence
  rand bit [31:0] s_data, start_addr, write_data;
  //constraint addr_ct {(262142 <= start_addr && start_addr <= 262148); }
  constraint addr_ct {(22<= start_addr && start_addr <= 40); }

  // Constructor
  function new(string name="x_read_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    begin
      `uvm_info(get_type_name(), "Executing...", UVM_HIGH)
      `uvm_do_with(req, { req.addr == start_addr; req.data == s_data; req.direction == READ; } )

    end
  endtask

  virtual task pre_body();
    uvm_test_done.raise_objection(this);
  endtask

  virtual task post_body();
    uvm_test_done.drop_objection(this);
  endtask

endclass

class write_seq extends uvm_sequence #(cache_pkg_cache_packet);
  `uvm_object_utils(write_seq)
  
  // Parameter for this sequence
  rand bit [31:0] s_data, start_addr, write_data;
  //constraint addr_ct {(262142 <= start_addr && start_addr <= 262148); }
  constraint addr_ct {(0 <= start_addr && start_addr <= 9); }

  // Constructor
  function new(string name="write_seq");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    begin
      `uvm_info(get_type_name(), "Executing...", UVM_HIGH)
      `uvm_do_with(req, { req.addr == start_addr; req.data == s_data; req.direction == WRITE; } )

    end
  endtask

  virtual task pre_body();
    uvm_test_done.raise_objection(this);
  endtask

  virtual task post_body();
    uvm_test_done.drop_objection(this);
  endtask

endclass




//------------------------------------------------------------------------------
//
// SEQUENCE: cache_pkg_cache_master_agent_nested_seq
//
//------------------------------------------------------------------------------
 
class cache_pkg_cache_master_agent_nested_seq extends uvm_sequence #(cache_pkg_cache_packet);
  `uvm_object_utils(cache_pkg_cache_master_agent_nested_seq)

  // Sequence that will be called in this sequence
  cache_pkg_cache_master_agent_cache_packet_seq cache_pkg_seq;

  // Parameter for this sequence

  // Constructor
  function new(string name="cache_pkg_cache_master_agent_nested_seq");
    super.new(name);
  endfunction
  
  // Sequence body definition
  virtual task body();
	int itr;
	uvm_component parent = get_sequencer();
    begin
      void'(parent.get_config_int("cache_pkg_cache_master_agent_nested_seq.itr", itr));

      `uvm_info(get_type_name(),
         $sformatf("Executing... (%0d cache_pkg_cache_master_agent_cache_packet sequences)",itr), UVM_HIGH)
      for(int i = 0; i < itr; i++) begin
        `uvm_do(cache_pkg_seq)
      end
    end
  endtask

  virtual task pre_body();
    uvm_test_done.raise_objection(this);
  endtask 

  virtual task post_body();
    uvm_test_done.drop_objection(this);
  endtask 
endclass


class mul_seq extends uvm_sequence #(cache_pkg_cache_packet);
  `uvm_object_utils(mul_seq)

  // Sequence that will be called in this sequence
  read_seq  cache_pkg_read_seq;
  x_read_seq  cache_pkg_x_read_seq;
  write_seq cache_pkg_write_seq;

  // Parameter for this sequence

  // Constructor
  function new(string name="mul_seq");
    super.new(name);
  endfunction
  
  // Sequence body definition
  virtual task body();
	int itr;
	uvm_component parent = get_sequencer();
    begin
      void'(parent.get_config_int("mul_seq.itr", itr));

      $display("value seq = %d", itr);
      `uvm_info(get_type_name(),
         $sformatf("Executing... (%0d cache_pkg_cache_master_agent_cache_packet sequences)",itr), UVM_HIGH)
      for(int i = 0; i < 100; i++) begin
        `uvm_do(cache_pkg_write_seq)
        `uvm_do(cache_pkg_read_seq)
        `uvm_do(cache_pkg_x_read_seq)
      end
    end
  endtask

  virtual task pre_body();
    uvm_test_done.raise_objection(this);
  endtask 

  virtual task post_body();
    uvm_test_done.drop_objection(this);
  endtask 
endclass
