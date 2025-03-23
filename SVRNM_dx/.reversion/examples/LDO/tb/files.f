-access +rw
-gui
-input input.tcl
-profile
-v $COMMON/EEnet/EEIO.sv
-v $COMMON/EEnet/Isrc_ideal.sv
-v $COMMON/EEnet/CapGeq.sv
-v $COMMON/EEnet/VRsrcD.sv
-v ../src/LDO_1.sv
// -v ../src/LDO_2.sv
// -v ../src/LDO_3.sv
// -v ../src/LDO_4.sv
// -v ../src/LDO_5.sv
-v ./anaLoad.sv

./tb.sv
