-clean                      // Deletes previous INCA_lins direcory, if it exists 
../src/vco_dig.sv           // original digital vco
../solution/vco_sine.sv     // updated sine vco 
../solution/vco_ds_TB.sv    // Testbench
-input probes.tcl           // probe TCL file to save and plot signals 
-access +rw                 // Turn on read/write object access 
-gui                        // Performs simulation in graphical mode

