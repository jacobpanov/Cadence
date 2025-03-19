// IVB checksum: 317166729
/*-----------------------------------------------------------------
File name     : cache_pkg_pkg.sv
Developers    : araheja
Created       : Wed Nov  2 11:42:24 2011
Description   : This file imports all the files of the UVC.
Notes         :
-------------------------------------------------------------------
Copyright  (c)2011 
-----------------------------------------------------------------*/


// Bring in the rest of the library (macros)
`include "uvm_macros.svh"

package cache_pkg_pkg;

// UVM class library compiled in a package
import uvm_pkg::*;

`include "cache_pkg_types.sv"
`include "cache_pkg_cache_packet.sv"

`include "golden_mem.sv"
`include "cache_master_checker.sv"

`include "cache_pkg_cache_master_agent_monitor.sv"
`include "cache_pkg_cache_master_agent_driver.sv"
`include "cache_pkg_cache_master_agent_agent.sv"
// Can include universally reusable master sequences here.

`include "cache_slave_checker.sv"

`include "cache_pkg_cache_slave_agent_monitor.sv"
`include "cache_pkg_cache_slave_agent_driver.sv"
`include "cache_pkg_cache_slave_agent_agent.sv"

// Can include universally reusable slave sequences here.
`include "cache_pkg_cache_slave_agent_sequences.sv"
`include "cache_pkg_cache_master_agent_sequences.sv"

`include "cache_pkg_env.sv"

endpackage : cache_pkg_pkg
