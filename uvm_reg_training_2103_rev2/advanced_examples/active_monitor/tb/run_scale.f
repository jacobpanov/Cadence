// -----------------------------------------------------------------
// File name     : run_scale.f
// Developers    : Brian Dickinson
// Created       : 01/04/22
// Description   : run file for Register interface for UVM register active monitoring
//                 using scaled user-defined backdoor connected
//                 to DUT via array of SV interfaces for UVM register active monitoring
//                 Execute via xrun -f run_scale.f
// Notes         : From the Cadence "SystemVerilog Advanced Register Verification with UVM" training
// -------------------------------------------------------------------
// Copyright Cadence Design Systems (c)2022
// -------------------------------------------------------------------


-uvmhome $UVMHOME

// options
//+UVM_VERBOSITY=UVM_FULL 
+UVM_VERBOSITY=UVM_MEDIUM 
//+UVM_VERBOSITY=UVM_LOW 
//+UVM_TESTNAME=base_test
//+UVM_TESTNAME=custom_access_test
+UVM_TESTNAME=reg_six_test

// default timescale
-timescale 1ns/100ps 

// include directories
-incdir ../reg_uvc/sv 

// compile files

// reg UVC package and interface
../reg_uvc/sv/reg_pkg.sv
../reg_uvc/sv/reg_if.sv 

// reg register model
../reg_rm/reg_rm_pkg.sv

// access interface
dutreg_if.sv

//  DUT
register_dut_generic.sv
top_dut_scale.sv

