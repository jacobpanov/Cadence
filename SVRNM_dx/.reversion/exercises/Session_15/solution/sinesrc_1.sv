// EEnet Sinusoidal Source with active event update

`timescale 1ns/1ps

module sinesrc  import EE_pkg::*; (output EEnet P, input real vdc,vm,fsin);

parameter real rs=0;             // optional output resistance (ohms)
parameter real ptspercyc=12;     // output max sample stepsize (ns)
const real pi=3.14159;

real Phs,Vout;     // present phase (cycles) and output voltage (V)
real T0,F0;        // time (ns) and frequency (Hz) at last timepoint
real dT;           // actual timestep size (seconds)
real Td=1s;        // maximum timestep size (ns)

always begin                     // DRIVE UPDATE PROCEDURE:
  dT = ($realtime-T0)/1s;        // timestep size since previous point
  Phs += dT*F0;                  // update the phase to present time
  Vout = vdc+vm*$sin(2*pi*Phs);  // update output drive
  T0=$realtime;                  // save time for use next step
// EVENT-ONLY FORMAT:
  F0 = fsin;                     // save frequency value
  @(P.V,P.I,P.R,vdc,vm,fsin);    // wait for net or control change
end

assign P = '{Vout,0.0,rs};       // drive output net

endmodule

