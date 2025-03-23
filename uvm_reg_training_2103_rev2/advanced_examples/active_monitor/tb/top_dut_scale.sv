/*-----------------------------------------------------------------
File name     : top_dut_scale.sv
Developers    : Brian Dickinson
Created       : 01/04/22
Description   : Scaled Register testbench using multiple user-defined backdoor instances connected
                to DUT via array of SV interfaces for UVM register active monitoring
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

  typedef uvm_config_db#(virtual interface dutregs_if) regif_cfg;

  // include user backdoor
  `include "user_backdoor_generic.sv"

  // include testbench and test library files
  `include "reg_rm_tb_scale.sv"
  `include "reg_test_lib.sv"
  // include register API sequences
  `include "reg_rm_seqs.sv"

  // clock, reset are generated here for this DUT
  bit clock; 

  // access interface to DUT interface

  dutregs_if rifs[1:0]();

  virtual interface dutregs_if rifvif[1:0] = rifs;
  assign rifs[0].update_reg = DUT.reg_six;
  assign rifs[1].update_reg = DUT.reg_seven;

  // MEM Interface to the DUT
  reg_if in0(clock);

  register_module DUT (
        .clk(clock),
	.read(in0.read),
	.write(in0.write), 
	.addr(in0.addr),
	.data_in(in0.data_in),
        .data_out(in0.data_out)
	   );

  initial begin
    reg_vif_config::set(null,"*.tb.reg_uvc.agent.*","vif", in0);
    for (int i = 0; i<2; i++) 
      regif_cfg::set(null,"*.tb",$sformatf("rif%0d",i+6),rifvif[i]);
    //regif_cfg::set(null,"*.tb","rif7",rif7);
    run_test();
  end

  //Generate Clock
  always
    #10 clock = ~clock;

endmodule
