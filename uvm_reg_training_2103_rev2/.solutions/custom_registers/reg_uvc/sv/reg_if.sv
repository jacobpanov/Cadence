/*-----------------------------------------------------------------
File name     : reg_if.sv
Developers    : 
Created       : 
Description   : 
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2011 
-----------------------------------------------------------------*/

interface reg_if(input logic clk);
  timeunit 1ns;
  timeprecision 100ps;

  logic [7:0] data_in;
  logic [7:0] data_out;
  logic [4:0] addr;
  logic read;
  logic write;

endinterface : reg_if

