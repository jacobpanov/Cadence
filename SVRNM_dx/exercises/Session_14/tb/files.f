-access +rw
-gui
-input input.tcl
-profile
-v $COMMON/EEnet/EEIO.sv
-v $COMMON/EEnet/Isrc_ideal.sv
-v $COMMON/EEnet/CapGeq.sv
-v $COMMON/EEnet/VRsrcD.sv
-v ../src/LDO.sv
-v ./anaLoad.sv

./tb.sv
