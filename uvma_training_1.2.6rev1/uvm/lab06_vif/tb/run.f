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
+UVM_TESTNAME=short_yapp_012
-timescale 1ns/1ns

// compile files

../sv/yapp_pkg.sv
../sv/yapp_if.sv
clkgen.sv
tb_top.sv
hw_top.sv
../../router_rtl/yapp_router.sv
