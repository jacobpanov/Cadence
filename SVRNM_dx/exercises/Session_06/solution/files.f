-clean                              // Deletes previous INCA_lins direcory, if it exists 
../solution/dac.sv                  // updated dac model
../solution/adc.sv                  // updated adc modle 
../solution/adc_dac_TB.sv           // updated testbench
-input ../solution/probes.tcl       // probe TCL file to save and plot signals 
-access +rw                         // Turn on read/write object access 
-gui                                // Performs simulation in graphical mode

