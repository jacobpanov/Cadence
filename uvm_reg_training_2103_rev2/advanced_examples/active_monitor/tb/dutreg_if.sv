/*-----------------------------------------------------------------
File name     : dutreg_if.sv
Developers    : Brian Dickinson
Created       : 01/04/22
Description   : Register interface for UVM register active monitoring
Notes         : From the Cadence "SystemVerilog Advanced Register Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2022
-----------------------------------------------------------------*/

interface dutregs_if;

  logic [7:0] update_reg;
   
endinterface
