/*-----------------------------------------------------------------
File name     : register_dut.sv
Developers    : Brian Dickinson
Created       : 01/04/22
Description   : This file implements the DUT for the custom register access lab
Notes         : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2022 
-----------------------------------------------------------------*/

///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2022 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : register_dut.sv
// Title       : register Module
// Specification:
//  8 register bytes
//  Enable bits
//    Field 1 of reg_zero is write-enable bit for reg_one
//    e.g. if reg_zero[1] = 1'b0, reg_one is read-only.
//  Write set 5a Read Set
//    register reg_three has a write-set-8'h5A-Read-Set access policy.
//    i.e. when written to any value, register is set to 8'h5A
//         when read, register is set to 8'hFF
//  Aliased register
//    reg_four and reg_five are aliased - writes to either address affect both
// 
///////////////////////////////////////////////////////////////////////////

module register_dut (
        input        clk,
	input        read,
	input        write, 
	input  logic [4:0] addr  ,
	input  logic [7:0] data_in  ,
        output logic [7:0] data_out
	   );
timeunit 1ns;
timeprecision 1ns;

// registers
logic [7:0] reg_zero;
logic [7:0] reg_one;
logic [7:0] reg_two;
logic [7:0] reg_three;
logic [7:0] reg_four;
logic [7:0] reg_five;
logic [7:0] reg_six;
logic [7:0] reg_seven;
  
  initial 
    $timeformat(-9,0," ns",10);
  
  always @(posedge clk)
    // external write operations
    if (write && !read) begin
      #1ns;
      case (addr)
        5'h00 : reg_zero <= data_in;
                // Field 1 of reg_zero is write-enable bit for reg_one
        5'h01 : if (reg_zero[1]) reg_one <= data_in; else $display("DUT: write to disabled reg_one @%t ignored", $time);
        5'h02 : reg_two <= data_in;
        5'h03 : begin
                  // write to reg_three sets 8'h5A
                  reg_three <= 8'h5A;
                end
        5'h04 : begin
                // reg_four and reg_five are aliased - writes to either address affect both
                reg_four <= data_in;
                reg_five <= data_in;
                end
        5'h05 : begin 
                // reg_four and reg_five are aliased - writes to either address affect both
                reg_five <= data_in;
                reg_four <= data_in;
                end
        5'h06 : reg_six <= data_in;
        5'h07 : reg_seven <= data_in;
        default: $display("register module write addr out of space %h", addr);
      endcase
    end

  always @(posedge clk)
    // external read operations
    if (read  && !write) begin
      case (addr)
        5'h00 : data_out <= reg_zero;
        5'h01 : data_out <= reg_one;
        5'h02 : data_out <= reg_two;
        5'h03 : begin
                // read from reg_three returns value and sets reg_three to 8'hFF
                data_out <= reg_three;
                reg_three <= 8'hFF;
                end
        5'h04 : data_out <= reg_four;
        5'h05 : data_out <= reg_five;
        5'h06 : data_out <= reg_six;
        5'h07 : data_out <= reg_seven;
        default: $display("register module read addr out of space %h", addr);
      endcase
    end

endmodule
