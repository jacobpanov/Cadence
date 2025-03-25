-access r
-ana anactrl.scs 
-input probes.tcl 
-rnm_tech
-nowarn NSVCER
-nowarn SAWSTP
-64bit
-iereport
../../../common/packages/EE_pkg.sv
$COMMON/EEnet/CapGeq.sv
$COMMON/EEnet/VIRsrcG.sv
$COMMON/EEnet/VRsrcD.sv
$COMMON/EEnet/EEIO.sv
../src/doubler0_full.sv
../src/doubler0e.sv
$COMMON/EEnet/CapDeq.sv
$COMMON/EEnet/EVIRsrcG.vams
$COMMON/EEnet/EVmeas.vams
../src/doubler_full.vams
doubler_stim.sv
doubler0_tb.sv
