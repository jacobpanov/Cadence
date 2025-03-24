-clean                    // Deletes previous INCA_lins direcory, if it exists 
-64bit 
../../../common/packages/cds_rnm_pkg.sv
../src/*.sv               // design modules in SV 
./adc_dac_TB.sv                   // Testbench
-input probes.tcl         // probe TCL file to save and plot signals 
-access +rw               // Turn on read/write object access 
-gui                      // Performs simulation in graphical mode

