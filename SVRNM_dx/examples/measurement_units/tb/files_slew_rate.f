-access +rw
-gui
-input input_slew_rate.tcl
-v ../src/slew_rate_checker.sv
-v ./Clockstim.sv
-v ./SRfilt.sv

./tb_slew_rate.sv
