// --- Begin Copyright Block -----[ do not move or remove ]------
//
// Copyright (c) 2013, Cadence Design Systems, Inc.  All rights reserved.
// 
// This source file may be used and distributed without restriction 
// provided that this copyright statement is not removed from the file 
// and that any derivative work contains this copyright notice.
//
// --------------------------------------------------------------

// --------------------------------------------------------------
//
// DESCRIPTION:  EE_pkg             
// SystemVerilog package that defines an electrical equivalent net (V-I-R) for
//      use in discrete analog behavioral models.  This net will conform to 
//      Kirchoff's law and resolves the voltage based on all the contributors.
//      See the resolution function notes for more information.

// FUNCTION: 
// The resolution function calculates the voltage on the net based on 
// multiple voltage and/or current contributors.  Each connection is 
// defined  as a voltage source V with series resistor R, plus a parallel 
// current source I.  Positive current is defined as the direction that 
// causes the voltage on the node to increase (in the presence of positive
// impedances).
// This definion uses `wrealZState to indicate no current flow, so if 
// if V or R equals `wrealZState, the V+R portion of the branch conducts 
// no current.  Current of i=`wrealZState is identical to current of zero.
// In the resolution function, all contributions are converted to summing 
// a current into IT and a conductance into GT.  
// If the resistance of any driver is zero, then that driver is an ideal 
// voltage source and will define the voltage on the net.    If a second 
// driver attempts to also drive an ideal voltage to the same net, the 
// result will be an X on the net.
// Normally resolution returns V=resolved voltage, R=effective resistance,
// and I=0.  When ideal voltage source is attached, resolution returns
// V=ideal source voltage, R=0, and I=current flowing to the ideal source.
//
// Cadence package of analog-like nettypes
// For support, contact ams_pe@cadence.com
//     
// CHANGE HISTORY:
//  - initial version: Dan Romaine, Ron Vogelsong
//  - Updated: 2013-07-17 (ronv)
//  - Updated: 2013-09-24 (adwarka)
//  - Updated: 2017-06-26 (xianghui) Change VHI, VLO from +-5.1V to +-999
//  - Updated: 2019-05-30 (zhengbos) Remove sqrt
//
// --- End Copyright Block --------------------------------------


/////////////////////////
package EE_pkg;   ///
/////////////////////////
// Struct to define Voltage, current, and resistance for the electrical nettype:
typedef struct {
    real V;
    real I;
    real R;
}  EEstruct;
 
// Shorthand for standard real constants:
`define Z `wrealZState
`define X `wrealXState

// Uncomment this define to enable debug printing during simulation:
//`define EE_DEBUG 

// Macro to get type of real value: 0=highZ 1=zero 2=value 3=invalid
`define rtype(R) (R===`Z)? 0 : (R==0)? 1 : (R<1e30)? 2 : 3

// Pull in absolute value function & rename like VerilogAMS:
function real abs(input real A); abs = (A<0)? -A:A; endfunction

// Electrical "EEnet" nettype with thevenin equivalent resolution
// Usage:
//   ideal voltage drive:   V=v1, R=0, (I ignored)
//   ideal current drive:   I=i1, R=`Z and/or V=`Z
//   V+R drive:        V=v1, R=r1, I=0 or `Z 
//   I||R drive:           I=i1, R=r1, V=0
//   Combination:              V=v1, R=r1, I=i1
//   No drive:                           I=`Z and (V=`Z or R=`Z)
// Multiple ideal voltage drives will result in `X.
// Ideal currents into large loads or Z will saturate to the 
//   specified VHI or VLO voltages.
// Undriven nodes will resolve to the specified VZ,RZ values.

function automatic EEstruct res_EE (input EEstruct driver[]);
  real VHI=999, VLO=-999; // output voltage clip limits when overdriven
  real VZ=`Z, RZ=`Z;  // resolved voltage & resistance when undriven
  real IT=0, GT=0;    // summed current & conductance for node
  real Vsrc=`Z;       // value of driving voltage source
  reg[7:0] numVsrc=0; // number ideal voltage sources driving pin
  reg[7:0] numErr=0;  // number erroneous drivers to node
  reg[7:0] numInp=0;  // number of inputs connected
  reg[1:0] tv,ti,tr;  // type for each term of each driver
  real Vnom;                // resolved voltage before limiting

begin
  foreach (driver[i]) begin  // sum current & conductance contributions
`ifdef EE_DEBUG
  $display("<><><%d> V=%5.3f  I=%8.2g  R=%8.2g \n",
        i, driver[i].V, driver[i].I, driver[i].R);
`endif  
    numInp+=1;
    tv=`rtype(driver[i].V);
    ti=`rtype(driver[i].I);
    tr=`rtype(driver[i].R);
    if (ti==3 || tr==3 || (tv==3 && tr!=0)) numErr+=1;   // invalid
    else if (tv==0 || tr==0) begin                        // no V
      if (ti==2)  IT+=driver[i].I;                               // I only
    end
    else if (tr==1) begin                                // ideal V
      numVsrc+=1; Vsrc=driver[i].V;
    end
    else begin                                           // nonzero R
      if (ti==2) IT+=driver[i].I;                                    // I term
      GT+=1/driver[i].R;                                                         // R term
      if (tv==2) IT+=driver[i].V/driver[i].R;                                        // V/R term
    end
  end
  if (numErr>0 || numVsrc>1) begin     // improper drive detected
    res_EE.V=`X;     // all errors map to Z for now ... would like to just
    res_EE.I=0;      // do Z at time zero, X thereafter, but can't access
    res_EE.R=RZ;     // "time" from a function!
  end
  else if (numVsrc==1) begin
    res_EE.V=Vsrc;          // ideal voltage drive
    res_EE.I=IT-Vsrc*GT;
    res_EE.R=0;
  end
  else if (GT==0) begin      // open circuited node
    if (IT==0) begin
      res_EE.V=VZ;           // no current - return open ckt info
      res_EE.I=0;
      res_EE.R=RZ;
    end
    else if (IT>0) begin 
      res_EE.V=VHI;           // positive current - clip to VHI
      res_EE.I=0;
      res_EE.R=VHI/IT;       // estimate large signal dV/dI
    end
    else begin
      res_EE.V=VLO;          // negative current - clip to VLO
      res_EE.I=0;
      res_EE.R=-VHI/IT;      // estimate large signal dV/dI
    end
  end
  else begin                 // normal resolution vis sumI/sumG:
    if (IT/GT>VHI) begin
      res_EE.V=VHI;          // saturated high
      res_EE.I=0;
      res_EE.R=VHI/IT;       // estimate large signal dV/dI
    end
    else if (IT/GT<VLO) begin
      res_EE.V=VLO;          // saturated low
      res_EE.I=0;
      res_EE.R=-VHI/IT;      // estimate large signal dV/dI
    end
    else begin
      res_EE.V=IT/GT;        // normal unsaturated result
      res_EE.I=0;
      res_EE.R=1/GT;         // normal on resistance
    end
  end
`ifdef EE_DEBUG
  $display("<%m> V=%5.3f  I=%8.2g  R=%8.2g        typeVIR=%d%d%d  numIVE=%d%d%d,  VIG = %g, %g,%g",
        res_EE.V,res_EE.I,res_EE.R, tv,ti,tr, numInp,numVsrc,numErr, Vsrc, IT, GT );
`endif  
end
 
endfunction

nettype EEstruct EEnet with res_EE;
endpackage
