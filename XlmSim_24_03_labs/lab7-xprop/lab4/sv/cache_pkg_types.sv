// IVB checksum: 2159369081
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
// cache_pkg cache_packet enums, parameters, and events
//
//------------------------------------------------------------------------------

`ifndef DEFINE_CONST
 `define DEFINE_CONST
  `define low_hit_addr 0
  `define high_hit_addr (2**18)-2
  `define low_miss_addr (2**18)+1
  `define high_miss_addr (2**19)-1
  `define ADDR_WIDTH 32
  `define DATA_WIDTH 32
`endif
typedef enum bit {CACHE_PKG_EVEN, CACHE_PKG_ODD } cache_pkg_data_type_e;
typedef enum {RESET_ASSERT, WRITE_READ_SAME_ADDR, WRITE_READ_SAME_ADDR_HIT, READ_WRITE_READ_SAME_ADDR, WRITE_READ_WRITE_SAME_ADDR, WRITE_READ_DIFF_ADDR, CONT_READ, CONT_READ_HIT, READMISS_CONT_READ, WRITEMISS_WRITE_READ} transaction_type;
typedef logic [31:0] addr_type;
typedef logic [31:0] data_type;
//typedef virtual cache_ifc my_vifc_type;
typedef enum {CONTINOUS_RUN} slave_sequence_type;
typedef enum { READ = 0,
               WRITE = 1
             } cache_direction_enum;
typedef enum {ACTIVE, PASSIVE} active_passive_enum;
