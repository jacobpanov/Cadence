-access +rw
-gui
-input input_rise_fall.tcl
-v ../src/rise_fall_time_checker.sv
-v ./Clockstim.sv
-v ./SRfilt.sv

./tb_rise_fall_time.sv
