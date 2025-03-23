import cds_rnm_pkg::*;
import EE_pkg::*;

`timescale 1s/1ps

module tb;

`define STOP_TIME 50e-6

   wire v_pulse;
   wire v_out;

   /*
    pulse generation
    */
   pulse_gen pulse_gen(.v_pulse(v_pulse));

   /*
    state space model of a Switched Capacitor Voltage Doubler
    */
   charge_pump charge_pump(.v_pulse(v_pulse),
			   .v_out(v_out));
   
   /*
    load model
    */
   load load(.v_out(v_out));
   
   /* Set a stop point */
   initial begin
      #(`STOP_TIME) $finish;
   end


endmodule // tb


/*model of pulse generator*/
module pulse_gen(v_pulse);

   parameter int period = 10;

   output wreal4state v_pulse;
   real   v_drv;

   assign v_pulse = v_drv;
   
   always #(period*1ns) v_drv = v_drv == 0.00 ? 1.00 : 0.00;
     
endmodule // pulse_gen

/*a random load class*/
class random_load;
   
   /*random load current*/
   rand real i_load;

   /*constrained*/
   constraint load_range {
      i_load > 0.00;
      i_load < 10.00;
   }
   
endclass


/*model of load*/
module load(v_out);

   inout EEnet v_out;
   real  i_load;
   bit randOK;

   random_load load = new();
  
   /*load oscillation*/
   always begin
      randOK = load.randomize();
      i_load = (randOK) ? load.i_load : 0.0;
      #50us;
   end
   
   assign v_out = '{`wrealZState, i_load, `wrealZState};

endmodule // load

