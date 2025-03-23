//--------------------------------------------------------------------------------------
// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2019, Cadence Design Systems, Inc. All rights reserved.

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
//--------------------------------------------------------------------------------------
//
// Assertion Library for Mixed Signal Verification 
//
//--------------------------------------------------------------------------------------


// property enable - response
// provides a range of delays over which to look for a response signal to a stimulus, and verifies that
// the response is held for at least 3 clock cycles

property enResp (logic clk, logic enable, logic response, logic disCond);
   @(posedge clk) disable iff (disCond) $rose(enable === 1'b1) |-> ##[0:5] (response === 1'b1)[*3];
endproperty

//usage example
// pllLock: assert property ( enResp(.clk (rtcClk), .enable (pllEn), .response (pllLock), .disCond (!resetn)) )
//      $display("PLL Locked");
//  else
//      $display("PLL Not Locked");

// property event follows event on time, or eventually
//   after event #1 triggers the assertion, it will look for event #2
//   for a number of cycles, or forever if '$' is passed for delVal

property eventFollows (clk, event1, event2, disCond, delVal);
   @(posedge clk) disable iff (disCond) $rose(event1 === 1'b1) |-> ##[0:delVal] (event2 === 1'b1);
endproperty

// function limit test
// Tests an input value against a target value with a tolerance

function logic limitTest (real testVal, real targVal, real tol);
   return ((testVal < (targVal + tol)) && (testVal > (targVal - tol)));
endfunction

//usage example, immediate assertion
//  assertLib assertLib ();
//     .......
//  rxbbIAmpinSpec: assert (assertLib.limitTest (.testVal (bbIp - bbIm), targVal (1.25), .tol (0.25)));
//        $display("rxBB amplitude within expected range");
//    else
//        $display("rxBB amplitude not within expected range");

// function high-side limit test
// Tests an input value against a one-sided max value

function logic limitHiTest (real testVal, real limVal);
   return (testVal < limVal);
endfunction

// function low-side limit test
// Tests an input value against a one-sided min value

function logic limitLoTest (real testVal, real limVal);
   return (testVal > limVal);
endfunction

// function percentage limit test
// Tests an input value against a target value with a tolerance treated as a percentage of the target

function logic limitTestPct (real testVal, real targVal, real pctTol);
   return ( (testVal < (targVal * (1 + pctTol))) && (testVal > (targVal * (1 - pctTol))) );
endfunction

// property triggered limit test
// checks a test condition after a trigger condition is satisfied
// Can be used in conjunction with the limit test functions

property trigLimTest (clk, trigSig, testVal, targVal, tol, disCond);
   @(posedge clk) disable iff (disCond) $rose(trigSig === 1'b1) |-> limitTest(testVal, targVal, tol);
endproperty

//usage example
/*
rxbbITest: assert property
   (trigLimTest(
     .clk (`tbSocRtc), 
     .trigSig (u_rxbbMeas.ready), 
     .testVal(u_rxbbMeas.ipMag + u_rxbbMeas.imMag), 
     .targVal(1.5), 
     .tol(0.25),
     .disCond (!(`tbTxcvrState == 1))))
         $display("rxbb I channel OK");
    else $display("rxbb I channel out of spec");
*/

// property triggered limit test with delay
// when triggered, waits a number of clock cycles before applying the limit test

property trigDelLimTest (clk, trigSig, delVal, testVal, targVal, tol, disCond);
   @(posedge clk) disable iff (disCond) $rose(trigSig === 1'b1) |-> ##[0:delVal] limitTest(testVal, targVal, tol);
endproperty

property trigHiLimTest (clk, trigSig, testVal, limVal, disCond);
   @(posedge clk) disable iff (disCond) $rose(trigSig === 1'b1) |-> limitHiTest(testVal, limVal);
endproperty

property trigLoLimTest (clk, trigSig, testVal, limVal, disCond);
   @(posedge clk) disable iff (disCond) $rose(trigSig === 1'b1) |-> limitLoTest(testVal, limVal);
endproperty

property trigDelHiLimTest (clk, trigSig, delVal, testVal, limVal, disCond);
   @(posedge clk) disable iff (disCond) $rose(trigSig === 1'b1) |-> ##[0:delVal] limitHiTest(testVal, limVal);
endproperty

property trigDelLoLimTest (clk, trigSig, delVal, testVal, limVal, disCond);
   @(posedge clk) disable iff (disCond) $rose(trigSig === 1'b1) |-> ##[0:delVal] limitLoTest(testVal, limVal);
endproperty

