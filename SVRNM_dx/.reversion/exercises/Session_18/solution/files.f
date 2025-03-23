-access +rw
-gui
-input input.tcl
-rnm_tech
-v $COMMON/EEnet/Isrc_ideal_gaussian.sv
-v $COMMON/EEnet/VRsrcG.sv
-v ../solution/div2Tx.sv
-v ../solution/txBias.sv
-v ../src/txPreAmp.sv
-v ./vcoSource.sv

./tb.sv
