-access +rw 
-gui
-input ../solution/probes.tcl
-v $COMMON/EEnet/Isrc_ideal_gaussian.sv
-v $COMMON/EEnet/Vvar_ideal.sv
-v ./tbPwrRamp.sv
-v ./rfSource.sv
-v ../solution/solution.sv
../solution/tb_solution.sv

