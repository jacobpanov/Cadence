// IVB checksum: 2519887621
/*-----------------------------------------------------------------
File name     : cache_pkg_cache_packet.sv
Developers    : araheja
Created       : Wed Nov  2 11:42:23 2011
Description   :  This file declares the UVC cache_packet. It is
              :  used by both cache_master_agent and cache_slave_agent.
Notes         :
-------------------------------------------------------------------
Copyright  (c)2011 
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// CLASS: cache_pkg_cache_packet
//
//------------------------------------------------------------------------------

typedef enum bit {CACHE_EVEN, CACHE_ODD } cache_data_type_e;


class cache_pkg_cache_packet extends uvm_sequence_item;

  /***************************************************************************
   IVB-NOTE : REQUIRED : cache_packet definitions : Item definitions
   ---------------------------------------------------------------------------
   Adjust the cache_packet attribute names as required and add any 
   necessary attributes.
   Note that if you change an attribute name, you must change it in all of your
   UVC files.
   Make sure to edit the uvm_object_utils_begin to get various utilities (like
   print and copy) for each attribute that you add.
  ***************************************************************************/           
  //rand bit [31:0] data;
  rand cache_pkg_data_type_e data_type;
 
  static rand logic[31:0] addr;
  rand logic[31:0] data;
  rand int temp;
  rand cache_direction_enum   direction;

  `uvm_object_utils_begin(cache_pkg_cache_packet)
    `uvm_field_int(data, UVM_DEFAULT)
    `uvm_field_enum(cache_pkg_data_type_e, data_type, UVM_DEFAULT)
  `uvm_object_utils_end

  // Constraints go here

  constraint c_direction {
    direction inside { READ, WRITE };
  }
 
  constraint c_addr {
    0 <= addr && addr <= 5242870;
  }

/*
  constraint default_data_type_c { solve data_type before data;
    data_type == CACHE_PKG_EVEN -> data[0] == 1'b0;
    data_type == CACHE_PKG_ODD -> data[0] == 1'b1; }
*/
  // Constructor - required syntax for UVM automation and utilities
  function new (string name = "unnamed-cache_pkg_cache_packet");
    super.new(name);
    $display("CACHE PKT");
  endfunction : new

endclass : cache_pkg_cache_packet


//class short_packet extends uvm_sequence_item;
class short_packet extends cache_pkg_cache_packet;

  /***************************************************************************
   IVB-NOTE : REQUIRED : cache_packet definitions : Item definitions
   ---------------------------------------------------------------------------
   Adjust the cache_packet attribute names as required and add any 
   necessary attributes.
   Note that if you change an attribute name, you must change it in all of your
   UVC files.
   Make sure to edit the uvm_object_utils_begin to get various utilities (like
   print and copy) for each attribute that you add.
  ***************************************************************************/           
  //rand bit [31:0] data;
  rand cache_pkg_data_type_e data_type;
 
  static rand logic[31:0] addr;
  rand logic[31:0] data;
  rand int temp;
  rand cache_direction_enum   direction;

  `uvm_object_utils_begin(short_packet)
    `uvm_field_int(data, UVM_DEFAULT)
    `uvm_field_enum(cache_pkg_data_type_e, data_type, UVM_DEFAULT)
  `uvm_object_utils_end

  // Constraints go here

  constraint c_direction {
    direction inside { READ, WRITE};
  }
 
  constraint c_addr {
    0 <= addr && addr <= 5242870;
  }

/*
  constraint default_data_type_c { solve data_type before data;
    data_type == CACHE_PKG_EVEN -> data[0] == 1'b0;
    data_type == CACHE_PKG_ODD -> data[0] == 1'b1; }
*/
  // Constructor - required syntax for UVM automation and utilities
  function new (string name = "unnamed-cache_pkg_cache_packet");
    super.new(name);
    $display ("SHORT PACKET");
  endfunction : new

endclass : short_packet
