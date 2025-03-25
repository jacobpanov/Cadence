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
// --------------------------------------------------------------
//
//  Loop Filter Model for PLL
//  Contains 2 trimmable real-valued poles and one zero
//  Integrates input over time with a scaling factor to represent
//  input resistance that performs a current to voltage conversion
//  Use with charge pump phase detector
//
//---------------------------------------------------------------

`timescale 1s / 1fs

`ifndef M_TWO_PI
`define M_TWO_PI 6.28318530717958647652
`endif

module loopFilter2 import cds_rnm_pkg::*; import EE_pkg::*; ( out, vdd, vss, en, in, lock, preChg, trim );

  parameter real vddMin = 1.4;
  parameter real vddMax = 1.8;
  parameter real vssMax = 0.1;
  parameter real iActive = 50e-6;
  parameter real iStandby = 1e-6;
  parameter real prechargeTime = 10e-6;
  parameter real sampleRate = 100e6;
  parameter real scaleFactor = 1e5;
  parameter real fpole0 = 250e3;
  parameter real fpole1 = 350e3;
  parameter real fzero  = 45e3;
  parameter real trimStep = 50e3;
  parameter real trimZStep = 5000;
  parameter real inputR = 10e9;
  parameter real risetime = 400e-15;

  input EEnet in;
  output wreal4state out;
  input logic en;
  inout EEnet vdd;
  inout EEnet vss;
  output logic lock;
  input logic preChg;
  input logic [3:0] trim;

  reg enInt = 0;
  reg filtOn;
  reg warmOn;
  reg preOn;  
  reg vddGood;
  reg vssGood;
  logic vddGoodFilt;
  logic vssGoodFilt;
  real iSupply;

  real lastEdge;
  real lastInputI;
  real accum;
  real sampIn;
  real outInt;
  real outCharge;
  real outSample;
  real data [0:2];  // input pipeline for filter
  real y_data [0:2]; // output pipeline for filter
  real period;
  real w0, w1, wz;  //pole and zero frequencies in radians
  real normConst;
  real numConst1, numConst2, numConst3;
  real num_0;
  real denom_0;
  logic supplyOK;
  logic clk;
  real fPoleError = 0.0; // pole 0 make error
  event startFiltClk, stopFiltClk;
  bit isPulseinProgress = 1'b0;

//  Current source to model active core (background) current
// The value of iSupply changes with the operating state of the module
   Isrc_ideal_gaussian #(.tr(1e-7)) coreLoad (
       .P          (vdd),
       .N          (vss), 
       .ival       (iSupply)
  );

// Supply Checks: The value of supplyOK should be 1 when the
// supply voltages are in the correct range.
  always @ (vdd.V)
      vddGood = ((vdd.V >= vddMin) && (vdd.V < vddMax));
  assign #(240e-9) vddGoodFilt = vddGood;
  
  always @ (vss.V)
      vssGood = ((vss.V <= vssMax) && (vss.V >= -vssMax));
  assign #(240e-9) vssGoodFilt = vssGood;

  assign supplyOK = vddGoodFilt && vssGoodFilt;

// Create an always-defined enable signal
   always @ (en)
      if (en === 1'b1)  enInt = 1;
      else enInt = 1'b0;

   always @ (posedge (enInt && (supplyOK === 1'b1)))
      begin
          clk = 0;
          outCharge = vdd.V/2;
          outInt = vdd.V/2;
          sampIn = vdd.V/2;
           -> startFiltClk;   //Turn the filter clk on          
          data[0:2] = '{vdd.V/2, vdd.V/2, vdd.V/2};
          y_data[0:2] = '{vdd.V/2, vdd.V/2, vdd.V/2};
          warmOn = 1'b1;
      end

   always @ ( (enInt && (supplyOK === 1'b1)) or trim) begin
      if ( enInt && (supplyOK === 1'b1) && (^trim !== 1'bx) && (^trim !== 1'bz)) begin
          // Initialize the pole and zero (radian) values
          w0 = (fpole0 + ((trim-7) * trimStep)) * (1+fPoleError) * `M_TWO_PI ;
          w1 = (fpole1 + ((trim-7) * trimStep)) * (1+fPoleError) * `M_TWO_PI ;
          wz = (fzero + ((trim-7) * trimZStep)) * (1+fPoleError) * `M_TWO_PI ;
          // These constants implement pole and zero dependent portions of the
          // filter transfer function
          normConst = 1/( ((w0*$pow(period,2)+(2*period))*w1 + (2*period*w0) + 4.0) *wz);
          numConst1 = ($pow(period,2) * w0 * w1 * wz) + (2 * period * w0 * w1);
          numConst2 = 2 * $pow(period,2) * w0 * w1 * wz;
          numConst3 = ($pow(period,2) * w0 * w1 * wz) - (2 * period * w1 * w0);
      end
   end

// Turn-off logic
   always @ ((negedge enInt) or supplyOK)
      begin
          if (supplyOK !== 1'b1) begin
             outInt = `wrealZState;
             filtOn = 1'b0;
             preOn  = 1'b0;
             warmOn = 1'b0;
             lock = 1'bx;
             -> stopFiltClk;
          end
          else if (enInt == 1'b0) begin
             outInt = 0.0;
             filtOn = 1'b0;
             preOn  = 1'b0;
             warmOn = 1'b0;
             lock = 1'b0;
             -> stopFiltClk;
          end
      end

//  after start-up time has elapsed, filter is fully functional
  always @ (posedge warmOn) begin
          #(200e-9);
          if ((enInt == 1'b1) && (supplyOK === 1'b1)) filtOn = 1'b1;
  end

// The filter has a mode that holds its output at 1/2(VDD-VSS).
// This mode is for VCO pre-calibration
  always @ (preChg) begin
     if (preChg === 1'b1) begin
          outCharge = vdd.V/2;
          preOn = 1'b1;
          outInt = (vdd.V - vss.V)/2;
          sampIn = (vdd.V - vss.V)/2;
          data[0:2] = '{sampIn, sampIn, sampIn};
          y_data[0:2] = '{outInt, outInt, outInt};
      end
      else if (preChg === 1'b0) begin
          outInt = outCharge;
          outCharge = 0;
          preOn = 1'b0;
          lastEdge = $realtime;
          lastInputI = 0.0;
          sampIn = outInt;
          accum = 0.0;
      end
  end
   
  // This block generates the filter clock. It is activated and deactivated
  // via the two events startFiltClk and stopFiltClk.
  always
  fork
  begin : filtClkGen
     clk = 1'b0; // Starts at 0
     @startFiltClk forever
        #(period) clk = ~clk;
  end
  @stopFiltClk disable filtClkGen;
  join

  // The input of the filter accumulates "charge"
  always @ (in.I)
     begin
         // impute a rise/fall time to input pump currents and perform trapezoidal/triangular integration
         if ( ($realtime - lastEdge) >= 2*risetime ) begin // wider pulses
             if (isPulseinProgress == 1'b1) begin // pulse in progress since last sample, use half-pulse calc
                 accum = accum + inputR * lastInputI * (2*$realtime - 2*lastEdge - risetime);
                 isPulseinProgress = 1'b0;  //clear flag
             end
             else
                accum = accum + inputR * ($realtime - lastEdge - risetime) * lastInputI;
         end
         else begin // very narrow pulse
             if (isPulseinProgress == 1'b1) begin
                accum = accum +  inputR * (lastInputI * (($realtime - lastEdge)**2) / (2*risetime));
                 isPulseinProgress = 1'b0;  //clear flag
             end
             else
                accum = accum + inputR * (lastInputI/(4*risetime)) * (($realtime - lastEdge)**2);
         end
         // assume rectangular pulses and integrate since last change
         accum = inputR * ($realtime - lastEdge) * lastInputI + accum;
         
         outSample = out;
         // Input changes "clock" a comparison of the filter output with 25% and 75% thresholds
         //    to generate a "lock" signal
         if ( (outSample < (vdd.V*0.75)) && (outSample > (vdd.V*0.25)) && (preOn == 1'b0) ) lock = 1'b1;
         else lock = 1'b0;
         lastInputI = in.I;     // Save last value and time stamp
         lastEdge = $realtime;  // for next integration calculation
     end


// Main Filter Implementation
  always @ (posedge clk)
     begin
        if (filtOn === 1'b1) begin
           sampIn = accum + sampIn; // sample all pulses accumulated since last clock
           accum = 0.0;   // reset accumulator
           // check to see if there is unaccumulated charge at the input
            if (in.I == lastInputI) begin // a pulse is still in progress
              if (($realtime - lastEdge) > risetime) begin // Wider pulse is in progress
                 sampIn = sampIn + inputR * (lastInputI * (2*$realtime - 2*lastEdge - risetime));
                 isPulseinProgress = 1'b1;  // set a flag for next accumulation
              end
              else begin // very narrow pulse in progress
                 sampIn = sampIn + inputR * (lastInputI * (($realtime - lastEdge)**2) / (2*risetime));
                 isPulseinProgress = 1'b1;
              end
              // sampIn = sampIn + (($realtime - lastEdge) * lastInputI * inputR); //add the part of the pulse so far to the accumulated charge
              lastInputI = in.I;  //should not change anything
              lastEdge = $realtime;
           end
   
           // 2nd order Z-domain transfer function requires 3-stage delay line
           data[2] = (data[1] !== 1'bz) ? data[1] : 0.0 ;
           data[1] = (data[0] !== 1'bz) ? data[0] : 0.0 ;
           // Keep X/Z states out of data pipeline...
           data[0] = ((outCharge !== `wrealZState) && (outCharge !== `wrealXState) && (outCharge > 0)) ? outCharge : (sampIn === `wrealZState) ? 0 : sampIn;

           y_data[2] = (y_data[1] !== 1'bz) ? y_data[1] : 0.0;
           y_data[1] = (y_data[0] !== 1'bz) ? y_data[0] : 0.0;

           num_0 = ( (data[0]*numConst1*normConst) + (data[1]*numConst2*normConst) + (data[2]*numConst3*normConst));   
           denom_0 = (((2*$pow(period,2))*w0*w1 - 8) * wz * normConst * y_data[1]) + ( (($pow(period,2)*w0 - (2*period))*w1 - (2*period*w0) + 4) * wz * normConst * y_data[2] );
           y_data[0] = num_0 - denom_0;
        
           outInt = enInt * (((y_data[0] !== 1'bx) && (y_data[0] !== 1'bz)) ? y_data[0] : outInt);
        end
     end

// Transfer function:((T^2*w0*w1*wz+2*T*w0*w1)*z^2+2*T^2*w0*w1*wz*z+T^2*w0*w1*wz-2*T*w0*w1)/(((T^2*w0+2*T)*w1+2*T*w0+4)*wz*z^2+(2*T^2*w0*w1-8)*wz*z+((T^2*w0-2*T)*w1-2*T*w0+4)*wz)

  // Output can be from the filter or from the pre-charge:
  assign out = (outCharge * preOn) +  (1-preOn) * ((outInt > vdd.V) ? vdd.V : (outInt < vss.V) ? vss.V : (outInt));
  assign in  = '{out, 0, 0}; // pass voltage info back to charge pump
  assign iSupply = (iStandby * supplyOK) + (filtOn * iActive); // Set the supply current based on state

   // Initialize some values
  initial
     begin
       period = 1/(2*sampleRate);
       sampIn = 0;
       lock = 1'b0;
     end
endmodule
