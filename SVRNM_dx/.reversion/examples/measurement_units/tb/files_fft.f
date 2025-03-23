-access +rw
##-run
-gui
-linedebug
-input input_fft.tcl
../src/fft_pkg.sv
-v ../src/fftAnalyzer.sv
-v ./SRfilt.sv
-v ./sine_src.sv

./tb_fft.sv
