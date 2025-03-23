/*-------------------------------------------------------------------------
File name     : top_dut.sv
Developers    : Brian Dickinson  
Created       : 01/04/22
Description   : This file implements the top level module for the custom register access lab
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2022 
-----------------------------------------------------------------*/

module top;

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // import the MEM UVC package
  import reg_pkg::*;

  // include testbench and test library files
  `include "reg_tb.sv"
  `include "reg_test_lib.sv"

  // clock, reset are generated here for this DUT
  bit clock; 

  // MEM Interface to the DUT
  reg_if in0(clock);

  register_dut DUT (
        .clk(clock),
	.read(in0.read),
	.write(in0.write), 
	.addr(in0.addr),
	.data_in(in0.data_in),
        .data_out(in0.data_out)
	   );

  initial begin
    reg_vif_config::set(null,"*.tb.reg_uvc.agent.*","vif", in0);
    run_test();
  end

  //Generate Clock
  always
    #10 clock = ~clock;

endmodule
