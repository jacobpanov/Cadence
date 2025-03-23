-access +rw
-gui
-clean
-linedebug
-rnm_coerce detailed
-input ../solution/input.tcl
-svseed random
-covfile ../solution/covfile
./modelError_pkg.sv
-v $COMMON/EEnet/Vvar_ideal.sv
-v $COMMON/EEnet/Isrc_ideal_gaussian.sv
-v ../src/chgPumpPhDet.sv  
-v ../src/divider2.sv
-v ../src/loopFilter2.sv  
-v ../src/PLL_top.sv  
-v ../src/refClkGen.sv  
-v ../src/vco_rf.sv
-v ../solution/PLL_stimulus_solution.sv 
-v ./tbPwrRamp.sv
-v ../solution/pllLockTimeMeas.sv
-v ../solution/coverages_solution.sv

../solution/tb.sv
