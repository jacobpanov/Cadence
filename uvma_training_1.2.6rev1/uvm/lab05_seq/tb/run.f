/*-----------------------------------------------------------------
File name     : run.f
Description   : lab01_data simulator run template file
Notes         : From the Cadence "SystemVerilog Advanced Verification with UVM" training
              : Set $UVMHOME to install directory of UVM library
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/
// 64 bit option for AWS labs
-64

-uvmhome $UVMHOME

// include directories
//*** add incdir include directories here
-incdir ../sv

+UVM_VERBOSITY=UVM_FULL
+UVM_TESTNAME=incr_payload_test

// compile files

../sv/yapp_pkg.sv

//*** add compile files here
top.sv
