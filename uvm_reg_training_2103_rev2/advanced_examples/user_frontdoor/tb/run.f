
-uvmhome $UVMHOME

// options
//+UVM_VERBOSITY=UVM_FULL 
//+UVM_VERBOSITY=UVM_MEDIUM 
+UVM_VERBOSITY=UVM_LOW 
//+UVM_TESTNAME=base_test
//+UVM_TESTNAME=custom_access_test
//+UVM_TESTNAME=user_frontdoor_test
+UVM_TESTNAME=indirect_frontdoor_test

// default timescale
-timescale 1ns/100ps 

// include directories
-incdir ../reg_uvc/sv 

// compile files

// reg UVC package and interface
../reg_uvc/sv/reg_pkg.sv
../reg_uvc/sv/reg_if.sv 

// reg register model
cdns_uvmreg_utils_pkg.sv
custom_regs_rdb.sv

// access interface
dutreg_if.sv

//  DUT
register_dut_indirect.sv
top_dut.sv
-access rwc
