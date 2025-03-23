-access +rw
-gui
-clean
-v $COMMON/EEnet/Isrc_ideal_gaussian.sv
-v $COMMON/EEnet/Isrc_ideal.sv
-v ../src/dualBBA.sv
-v ../src/dcocDAC.sv 
-v ../src/ADC_refGen.sv
-v ../solution/ADC_8bit_solution.sv
-v ../src/rxbb.sv

-v ../solution/rxBB_stimulus_solution.sv

rxBB_sim.sv
