-access +rw
-gui
-input input.tcl
-v $COMMON/EEnet/Isrc_ideal.sv
-v $COMMON/EEnet/Isrc.sv
-v $COMMON/EEnet/VRsrcG.sv
-v ./BIAS_stimulus.sv
-v ../solution/BIAS2.sv
tb.sv
