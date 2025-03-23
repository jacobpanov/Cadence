-access +rw
-gui
-clean
-v $COMMON/EEnet/Isrc_ideal_gaussian.sv
-v $COMMON/EEnet/Isrc_ideal.sv
-v ../src/dualBBA.sv
-v ../src/dcocDAC.sv 
-v ../src/ADC_refGen.sv
-v ../src/ADC_8bit_simple.sv
-v ../src/rxbb.sv

-v ./rxBB_stimulus.sv

rxBB_sim.sv
