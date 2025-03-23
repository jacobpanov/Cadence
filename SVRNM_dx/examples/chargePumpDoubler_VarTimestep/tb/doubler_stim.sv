// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2020, Cadence Design Systems, Inc. All rights reserved.

// The model contained herein is the proprietary and confidential information 
// of Cadence, and is supplied subject to, and may be used only by Cadences 
// customer in accordance with a previously executed license and maintenance 
// agreement between Cadence and that customer. This model is intended for use 
// with products only from Cadence Design Systems, Inc.  The use or sharing of 
// any models from this library or any of its modified/extended form is 
// strictly prohibited with any non-Cadence products.

// ALL MATERIALS FURNISHED BY CADENCE HEREUNDER ARE PROVIDED "AS IS" WITHOUT 
// WARRANTY OF ANY KIND, AND CADENCE SPECIFICALLY DISCLAIMS ANY WARRANTY OF 
// NONINFRINGEMENT, FITNESS FOR A PARTICULAR PURPOSE OR MERCHANTABILITY. 
// CADENCE SHALL NOT BE LIABLE FOR ANY COSTS OF PROCUREMENT OF SUBSTITUTES, 
// LOSS OF PROFITS, INTERRUPTION OF BUSINESS, OR FOR ANY OTHER SPECIAL, 
// CONSEQUENTIAL OR INCIDENTAL DAMAGES, HOWEVER CAUSED, WHETHER FOR BREACH OF 
// WARRANTY, CONTRACT, TORT, NEGLIGENCE, STRICT LIABILITY OR OTHERWISE.
// --------------------------------------------------------------

//systemVerilog HDL for "CP", "doubler_stim" "systemVerilog"

// Tests: unloaded charge, add & change load, loaded discharge, 
//   loaded charge, overload, incrementally increase clock freq;
//   Then repeat loaded & unloaded charge with larger input resistance.

`timescale 1ns/1ps
 
module doubler_stim ( 
  output logic CK,   // logical clock signal 
  output real Vdd,   // input voltage
  output real Rin,   // input resistance
  output real Rload  // load resistance
  );

  reg cken=0;        // enable for clock generation
  real Per=1000;     // clock period (ns)
  bit CKint=0;       // internal clock        
  always #(Per/2) CKint = !CKint;  
  assign CK = CKint & cken; // external clock uses enable

  // Timing adjusted in here to simplify measurement:  clock goes to low
  // at start of each cycle, measurement is performed at that point by 
  // the testbench, and all control changes 10ns after that point
  // so that output will be in passive state during control change.
  // 
  event Meas;             // event flag to measure at
  task DelMeas;           // Task to perform delay and measure at end
   input integer Tt;      // pass delay value to this task
   begin
     #(Tt-1.5*Per);       // delay until a bit before end of test time
     fork                 // execute these two tasks in parallel:
       #(1.5*Per);                // wait for the rest of test time 
       @(negedge CKint) ->Meas;   // generate measure event at neg edge of clock
     join
   end
  endtask

  initial begin
    `ifdef REPEAT
       repeat(100) begin
    `endif
    Vdd=1.5; Rin=0;               // input ideal power supply
    Rload=1e6;   #10000;          // load nearly open-circuited
    cken=1;      DelMeas(90000);  // enable clock, wait to charge up to 3V output
    Rload=3000;  DelMeas(100000); // add 1mA load, expect slight voltage change
    Rload=600;   DelMeas(100000); // change to 5mA load, larger voltage drop
    `ifdef REPEAT
       end
    `endif
    cken=0;      DelMeas(100000); // disable clock, output discharges
    cken=1;      DelMeas(100000); // enable clock, charging while loaded
    Per=2000;    DelMeas(120000); // slower clock, double voltage error
    Per=500;     DelMeas(30000);  // faster clock, half of voltage error
    Rload=100;   DelMeas(20000);  // 30mA nominal output, very heavily loaded
    Per=250;     DelMeas(20000);  // 2tau high + 2tau low (non-fully-transferred)
    Per=125;     DelMeas(20000);  // 1tau high + 1tau low (way over-clocked)
    cken=0;      DelMeas(30000);  // disable clocking, discharge heavily loaded
    Per=1000; Rload=600; Rin=1;   // added small Rin, with 5mA nominal load
    cken=1;      DelMeas(50000);  // loaded charging
    cken=0;      DelMeas(50000);  // discharge again
    Rin=4;cken=1;DelMeas(20000);  // loaded charging with Rin at 2/3rds of 2*Rsw
    Rload=100;   DelMeas(30000);  // add heavy output loading
    $stop;          // done testing
  end

endmodule
