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

// Package for custom UDN definition
// This is a structured UDN with 3 fields: V, status, numDrive
// Field descriptions:
// V        : (real)      Voltage value
// status   : (enum int)  Can have one of 3 values:
//                        0 - ideal, 1 - combination drive w/ 200-ohm series 
//                        resistance on each driver, 2 - high-impedance (inactive)
// drivers  : (int)       Number of active drivers in the combination drive case.
//                        This will help calculate the effective series resistance
//                        of the combination drive. It will be 1 in the ideal drive
//                        case and will be 0 in all other cases.
//
// Values driven on the net will be of the format '{V,status,drivers}
// However, the resolution function only considers the V value and status 
// value on the driver input when resolving the final drive.
// The final value of the resolution function will reflect the voltage,
// number of drivers and status (ideal, non-ideal, inactive) of the
// net under consideration.
// Combination drive should be read by models as a voltage source with series 
// resistance. In the case of multiple combination drives, the equivalent resistance
// is equal to (200/drivers) ohm.

`define Z `wrealZState
`define X `wrealXState

// Package definition
package myUDN_pkg;
  
  // Status enum
  typedef enum {IDEAL,COMBO,INACTIVE} status_e;
  
  // Datatype declaration
  typedef struct {
    real V;           // Voltage value
    status_e status;  // Status flag
    int drivers;      // Number of drivers
  } myUDT;

  // Resolution function
  function automatic myUDT myUDR (input myUDT driver[]);
    int numIdeal=0, numComb=0, numInactive=0;
    int totalDrivers=0;
    real sumV=0, Vsrc=0;
    begin
      foreach(driver[i]) begin
        case(driver[i].status)
          IDEAL:    begin
                      numIdeal++;         //Increment number of ideal drivers
                      Vsrc = driver[i].V; //Should only be one driver.
                    end
          COMBO:    begin
                      numComb++;            //Increment number of combination drivers
                      sumV += driver[i].V;  //Final drive voltage will be the average
                    end
          INACTIVE: numInactive++;
        endcase
        totalDrivers++;
      end
      if (numIdeal>1) begin //Multiple ideal drives -> set to inactive
        myUDR.V = `Z;
        myUDR.status = INACTIVE;
        myUDR.drivers = 0;
`ifdef MYUDN_DEBUG
        $display("Multiple ideal drives, numIdeal=%d. Driving out Z", numIdeal);
`endif
      end
      else if (numIdeal==1) begin //Single ideal drive
        myUDR.V = Vsrc;
        myUDR.status = IDEAL;
        myUDR.drivers = 1;
`ifdef MYUDN_DEBUG
        $display("Ideal, numIdeal=%d, Vsrc=%f",numIdeal,Vsrc);
`endif
      end
      else if (numInactive==totalDrivers) begin //Open-circuited/inactive drive
        myUDR.V = `Z;
        myUDR.status = INACTIVE;
        myUDR.drivers = 0;
`ifdef MYUDN_DEBUG
        $display("Inactive, numInactive=%d",numInactive);
`endif
      end
      else begin //Combination drive
        myUDR.V = sumV/numComb;
        myUDR.status = COMBO;
        myUDR.drivers = numComb;
`ifdef MYUDN_DEBUG
        $display("Combination, numComb=%d, sumV=%f",numComb,sumV);
`endif
      end
    end   
  endfunction

  // Nettype Declaration
  nettype myUDT myUDN with myUDR;

endpackage

`undef Z
`undef X
