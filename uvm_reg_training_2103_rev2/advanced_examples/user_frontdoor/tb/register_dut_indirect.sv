///////////////////////////////////////////////////////////////////////////
// (c) Copyright 2013 Cadence Design Systems, Inc. All Rights Reserved.
//
// File name   : register_dut_indirect.sv
// Title       : register Module
// Specification:
//  Indirect registers
//    reg_eight + reg_nine access through separate addr/data interface
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
// SYSTEMVERILOG: timeunit and timeprecision specification
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
logic [7:0] reg_eight;
logic [7:0] reg_nine;
logic [7:0] indirect_addr;
logic [7:0] indirect_data;

  
  initial 
    $timeformat(-9,0," ns",10);
  
  always @(posedge clk)
    if (write && !read) begin
      #1ns;
      case (addr)
        8'h00 : reg_zero <= data_in;
                // Field 1 of reg_zero is write-enable bit for reg_one
        8'h01 : if (reg_zero[1]) reg_one <= data_in; else $display("DUT: write to disabled reg_one @%t ignored", $time);
        8'h02 : reg_two <= data_in;
        8'h03 : begin
                  // write to reg_three sets 8'h5A
                  reg_three <= 8'h5A;
                end
        8'h04 : begin
                // reg_four and reg_five are aliased - writes to either address affect both
                reg_four <= data_in;
                reg_five <= data_in;
                end
        8'h05 : begin 
                // reg_four and reg_five are aliased - writes to either address affect both
                reg_five <= data_in;
                reg_four <= data_in;
                end
        8'h06 : $display("reg_six is read only");
        8'h07 : reg_seven <= data_in;
        8'h10 : begin
                // address location for indirect registers
                $display("write indirect addr loc %0h",data_in);
                indirect_addr <= data_in;
                end
        8'h11 : begin
                // data location for indirect registers
                $display("write indirect data loc %0h",data_in);
                case (indirect_addr)
                  0: reg_eight <= data_in;
                  1: reg_nine <= data_in;
                  default: $display("unknown indirect address %h", indirect_addr);
                endcase                
                end
        default: $display("register module write addr out of space %h", addr);
      endcase
    end

// SYSTEMVERILOG: always_ff and iff event control
  always @(posedge clk iff ((read == '1)&&(write == '0)) )
    begin
    case (addr)
      8'h00 : data_out <= reg_zero;
      8'h01 : data_out <= reg_one;
      8'h02 : data_out <= reg_two;
      8'h03 : data_out <= reg_three;
      8'h04 : data_out <= reg_four;
      8'h05 : data_out <= reg_five;
      8'h06 : data_out <= reg_six;
      8'h07 : data_out <= reg_seven;
      8'h10 : begin
              // address location for indirect registers
              $display("illegal read from indirect address");
              end
      8'h11 : begin
              // data location for indirect registers
              case (indirect_addr[0])
                0: data_out <= reg_eight;
                1: data_out <= reg_nine;
                default: $display("unknown bit0 in indirect address %b", indirect_addr[0]);
              endcase                
              end
      default: $display("register module read addr out of space %h", addr);
    endcase
    end

endmodule
