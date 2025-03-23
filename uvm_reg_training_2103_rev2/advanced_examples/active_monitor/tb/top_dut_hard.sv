/*-----------------------------------------------------------------
File name     : top_dut_hard.sv
Developers    : Brian Dickinson
Created       : 01/04/22
Description   : Hardwired top level module using user-defined backdoor connected
                to DUT via hierarcical pathname for UVM register active monitoring
Notes         : From the Cadence "SystemVerilog Advanced Register Verification with UVM" training
                Refer to training material for details of code
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2022
-----------------------------------------------------------------*/

module top;

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // import the reg UVC package
  import reg_pkg::*;

  // import reg model package
  import reg_rm_pkg::*;

  // include user backdoor
  `include "user_backdoor_hard.sv"

  // include testbench and test library files
  `include "reg_rm_tb_hard.sv"
  `include "reg_test_lib.sv"
  // include register API sequences
  `include "reg_rm_seqs.sv"

  // clock, reset are generated here for this DUT
  bit clock; 

  // MEM Interface to the DUT
  reg_if in0(clock);

  register_dut_hard DUT (
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
