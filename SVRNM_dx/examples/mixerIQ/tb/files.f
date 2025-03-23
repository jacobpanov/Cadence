-access +rw
-gui
-input input.tcl
-run
-v $COMMON/EEnet/Isrc_ideal_gaussian.sv
-v $COMMON/EEnet/Isrc_ideal.sv
-v ../src/mixerIQ.sv
-v ../src/div2Qgen.sv
-v ./vcoSource.sv
-v ./rfSource.sv

./mixerIQ_tb.sv
