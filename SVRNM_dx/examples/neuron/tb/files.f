-access +rw
-gui
-input input.tcl
-rnm_tech
-profile
//-xprof
-nowarn NSVCER:SAWSTP:WARIPR
-v $COMMON/EEnet/EEIO.sv
-v $COMMON/EEnet/CapGeq.sv
-v $COMMON/EEnet/VRsrcD.sv
-v $COMMON/EEnet/CapDeq.sv
-v ../src/xNOR.sv
-v ../src/xOR.sv
-v ../src/comparator.sv
-v ../src/msNeuron.sv

tb.sv
