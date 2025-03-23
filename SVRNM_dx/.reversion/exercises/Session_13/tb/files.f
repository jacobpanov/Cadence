-access +rw 
-gui
-input probes.tcl
-v $COMMON/EEnet/Isrc_ideal_gaussian.sv
-v $COMMON/EEnet/Vvar_ideal.sv
-v ./tbPwrRamp.sv
-v ./rfSource.sv
-v ../src/lna.sv
./tb.sv

