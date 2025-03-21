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
--incdir /home/jpanov/Cadence/uvma_training_1.2.6rev1/uvm/lab01_data/sv

// compile files
/home/jpanov/Cadence/uvma_training_1.2.6rev1/uvm/lab01_data/sv/yapp_packet.sv
/home/jpanov/Cadence/uvma_training_1.2.6rev1/uvm/lab01_data/sv/yapp_pkg.sv

//*** add compile files here
top.sv
