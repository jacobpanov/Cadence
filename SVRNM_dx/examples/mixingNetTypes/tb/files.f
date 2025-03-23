
-clean 
-UNBUFFERED 
-noupdate 
-errormax 50 
-status 
-nowarn DLNOHV 
-nowarn DLCLAP 
-abvoff all 
-v93 
-linedebug 
-timescale 1ns/1ps 
-vtimescale 1ns/1ps 
-delay_mode None 
-novitalaccl 
-64bit
-access rw 
-ieinfo 
-noparamerr 
-amspartinfo ./partition.info -rnm_partinfo 
./amsControlSpectre.scs 
-profile 
-gui  
-input input.tcl
-xmsimargs "+amsrawdir ./psf" 
 -simcompatible_ams spectre 
-v ../src/resDemo.sv
-v ../src/resVAMS.vams
-v ./resMeas.sv
./amsTB.vams 
./cds_globals.vams 

