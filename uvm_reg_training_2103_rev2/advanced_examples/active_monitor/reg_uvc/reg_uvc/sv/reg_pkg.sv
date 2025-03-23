/*-----------------------------------------------------------------
File name     : reg_pkg.sv
Developers    : Brian Dickinson
Created       : 01/04/22
Description   : This file implements the UVC package for the reg UVC
Notes         : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2022 
-----------------------------------------------------------------*/

package reg_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef uvm_config_db#(virtual interface reg_if) reg_vif_config;
`include "reg_item.sv"
`include "reg_adapter.sv"
`include "reg_monitor.sv"
`include "reg_sequencer.sv"
`include "reg_seqs.sv"
`include "reg_driver.sv"
`include "reg_agent.sv"
`include "reg_env.sv"

endpackage
