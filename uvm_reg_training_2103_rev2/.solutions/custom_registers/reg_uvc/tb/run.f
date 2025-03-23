
-uvmhome $UVMHOME

// options
+UVM_VERBOSITY=UVM_MEDIUM 
//+UVM_VERBOSITY=UVM_LOW 
//+UVM_TESTNAME=base_test
+UVM_TESTNAME=simple_test

// default timescale
-timescale 1ns/100ps 

// include directories
-incdir ../sv 

// compile files

// MEM UVC package and interface
../sv/reg_pkg.sv
../sv/reg_if.sv 

// MEM DUT
../../reg_rtl/reg.sv
top_dut.sv

