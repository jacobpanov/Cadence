-access +rw
-gui
-input input.tcl
-rnm_tech
-v $COMMON/EEnet/Isrc_ideal_gaussian.sv
-v $COMMON/EEnet/VRsrcG.sv
-v ../src/div2Tx.sv
-v ../src/txBias.sv
-v ../src/txPreAmp.sv
-v ./vcoSource.sv

./tb.sv
