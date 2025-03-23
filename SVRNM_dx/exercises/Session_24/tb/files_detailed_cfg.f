-access +rw
-gui
-clean
-top vlogCnfg_tb
-v $COMMON/EEnet/Isrc_ideal_gaussian.sv
-v $COMMON/EEnet/Isrc_ideal.sv
-v ../src/dualBBA.sv
-v ../src/dcocDAC.sv 
-v ../src/ADC_refGen.sv
-v ../src/sarDAC.sv
-v ../src/sarSamplingMux.sv
-v ../src/sarLogic.sv
-v ../src/sarComparator.sv
../src/ADC_8bit_simple.sv
../src/ADC_8bit_detailed.sv
-v ../src/rxbb.sv

-v ./rxBB_stimulus.sv
-compcnfg ./config_sch.v
rxBB_sim.sv
