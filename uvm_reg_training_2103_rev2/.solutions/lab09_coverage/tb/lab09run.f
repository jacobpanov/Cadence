/*-----------------------------------------------------------------
File name     : lab04run.f
Developers    : Kathleen Meade, Brian Dickinson
Created       : 01/04/20
Description   : lab04_regmethods simulator run file
Notes         : From the Cadence "SystemVerilog Register Verification using UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2020
-----------------------------------------------------------------*/
// 64 bit option required for AWS labs
-64

-uvmhome $UVMHOME

// options
//+UVM_VERBOSITY=UVM_MEDIUM
+UVM_VERBOSITY=UVM_LOW
//+UVM_VERBOSITY=UVM_NONE
//+UVM_TESTNAME=test_mc 
//+UVM_TESTNAME=uvm_reset_test 
//+UVM_TESTNAME=uvm_mem_walk_test 
//+UVM_TESTNAME=simple_access_test
+UVM_TESTNAME=simple_function_test
//+UVM_TESTNAME=simple_introspection_test
//+UVM_TESTNAME=memory_access_test
//+UVM_TESTNAME=introspection_seq_test

// default timescale
-timescale 1ns/100ps 

// include directories
-incdir ../../yapp/sv 
-incdir ../../channel/sv
-incdir  ../../hbus/sv 
-incdir ../../clock_and_reset/sv
-incdir ../../router/sv

// compile files

// YAPP UVC package and interface
../../yapp/sv/yapp_pkg.sv
../../yapp/sv/yapp_if.sv 

// Channel UVC package and interface
../../channel/sv/channel_pkg.sv 
../../channel/sv/channel_if.sv 

// HBUS UVC package and interface
../../hbus/sv/hbus_pkg.sv 
../../hbus/sv/hbus_if.sv 

// clock and reset UVC package
../../clock_and_reset/sv/clock_and_reset_pkg.sv 
../../clock_and_reset/sv/clock_and_reset_if.sv 

// register model package
cdns_uvmreg_utils_pkg.sv
yapp_router_regs_rdb.sv

// router module package
../../router/sv/router_module_pkg.sv

// router DUT
../../router_rtl/yapp_router.sv 

// clock generator module
clkgen.sv
// top module for UVM test environment
tb_top.sv
// accelerated top module 
hw_top.sv

// enable backdoor register paths
-access rwc

// coverage options
-coverage U
-covdut tb_top
-covoverwrite
