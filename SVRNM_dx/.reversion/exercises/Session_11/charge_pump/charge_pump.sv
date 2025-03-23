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




`timescale 1ns/1ps

module charge_pump import cds_rnm_pkg::*; import EE_pkg::*; (
   input wreal4state v_pulse,
   inout EEnet v_out);


   /*component parameters*/
   parameter real 	 Cpump         = 100.00e-6; /*pumping capacitor capacitance*/
   parameter real 	 Cload         = 40.00e-6;  /*load/reservoir capacitance*/
   parameter real 	 Rload_Src     = 10.00;     /*nominal source resistance*/
   parameter real 	 Rsrc          = 0.1;       /*source resistor*/
   parameter real 	 Rsw           = 0.1;       /*switch resistance - discharge phase*/
   parameter real 	 dt            = 1.00e-9;   /*timestep*/


   /*source and state variables*/
   real 	  v_src_p0;   /*source voltage - phase 0 (charge)*/
   real 	  v_src_p1;   /*source voltage - phase 1 (discharge)*/  
   real 	  v_c_pump;   /*pump capacitor voltage*/   
   real 	  v_c_load;   /*load voltage*/            
   real 	  Rload;      /*dynamic source resistance + load resistance*/
   real 	  Rin;        /*dynamic load resistance*/
   
   /*node voltages for the pump capacitor*/
   real 	  v_c_pump_p;
   real 	  v_c_pump_m;

   /*charge flag*/
   wire 	  charge;
   
   /*state differentials*/
   real 	  ddt_v_c_load;  /*differential for load capacitor voltage*/
   real 	  ddt_v_c_pump;  /*differential for pump capacitor voltage*/

   
   /*state space matrix*/
   real 	  A00_discharge,A01_discharge,A10_discharge,A11_discharge;      /*(Discharge)State Transition Matrix*/
   real 	  B00_discharge,B01_discharge,B10_discharge,B11_discharge;      /*(Discharge)Input Matrix*/
   real 	  A00_charge,A01_charge,A10_charge,A11_charge;                  /*(Charge)State Transition Matrix*/
   real 	  B00_charge,B01_charge,B10_charge,B11_charge;                  /*(Charge)Input Matrix*/

   /*(discharge phase) create the state transition matrix - Bashkow Matrix*/
   assign A00_discharge = -1/(Cpump*Rsrc + Cpump*Rsw);
   assign A01_discharge = -1/(Cpump*Rsrc + Cpump*Rsw);
   assign A10_discharge = -1/(Cload*Rsrc + Cload*Rsw);
   assign A11_discharge = -(Rload + Rsrc + Rsw)/(Cload*Rload*Rsrc + Cload*Rload*Rsw);

   /*(discharge phase) create the input matrix*/
   assign B00_discharge = 1/(Cpump*Rsrc + Cpump*Rsw);
   assign B01_discharge = 0.00;
   assign B10_discharge = 1/(Cload*Rsrc + Cload*Rsw);
   assign B11_discharge = 0.00;
   
   /*(charge phase) create the state transition matrix - Bashkow Matrix*/
   assign A00_charge =-1/(Cpump*Rsrc);
   assign A01_charge = 0.00;
   assign A10_charge = 0.00;
   assign A11_charge = -1/(Cload*Rload);
   
   /*(charge phase) create the input matrix*/
   assign B00_charge = 1/(Cpump*Rsrc);
   assign B01_charge = 0.00;
   assign B10_charge = 0.00;
   assign B11_charge = 0.00; 
   

   /*assign differential elements*/
   assign charge = v_src_p0 > 0.00;
   assign ddt_v_c_pump  = charge ? A00_charge*v_c_pump   + A10_charge*v_c_load + B00_charge*v_src_p0:
			  A00_discharge*(-1.00*v_c_pump) + A01_discharge*v_c_load + B00_discharge*v_src_p1;
   assign ddt_v_c_load =  charge ? A10_charge*v_c_pump   + A11_charge*v_c_load + B10_charge*v_src_p0:
			  A10_discharge*(-1.00*v_c_pump) + A11_discharge*v_c_load + B10_discharge*v_src_p1;


   /*source assignments*/
   assign v_src_p0 = v_pulse;
   assign v_src_p1 = 1.00-v_pulse;
   assign v_out    = '{v_c_load,`wrealZState, 0.00};

   /*iniitalization of state variables*/
   initial begin
      v_c_pump   = 0.00;
      v_c_load   = 0.00;
      v_c_pump_p = 0.00;
      v_c_pump_m = 0.00;
   end

   /*detect load variations*/
   real idbg;
   
   initial begin
      Rload = Rload_Src;
      Rin = 0.00;
   end
   
   
   always @(v_out.V, v_out.I, v_out.R)begin
      idbg  = v_out.I;
      Rin   = idbg < 0.1 ? 0.00 : v_out.V/idbg;
      /*Contrived*/
      Rload = Rin > 0.00 ? Rload_Src - 0.95*Rin : Rload_Src;
   end

   /*evaluate state variables*/
   always begin
      v_c_pump = v_c_pump + dt*ddt_v_c_pump;
      v_c_load = v_c_load + dt*ddt_v_c_load;
      

      /*The following code is to determine nodal voltages, this is because the state space
       methodology depends on (or the state space equations are forumated from ) mesh/loop
       analysis. Mesh analysis (KVL - Voltage Drops) yield relative voltage drops across the
       components not the terminal voltages (node analysis). So this is needed to determine
       nodal voltages and set nodal initial voltage conditions (Spice .ic V(node) = X)*/
      
      v_c_pump_p = v_src_p0 - Rsrc*(Cpump*ddt_v_c_pump);
      v_c_pump_m = v_c_pump_p - v_c_pump;
      

      /*sampling loop*/
      #1;
   end




     
endmodule // charge_pump
