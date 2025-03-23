-access r
-rnm_tech
-nowarn NSVCER
-nowarn SAWSTP
-iereport
-define TSAMP=90e-9
-define REPEAT
-status
$COMMON/EEnet/CapGeq.sv
$COMMON/EEnet/VIRsrcG.sv
$COMMON/EEnet/VRsrcD.sv
$COMMON/EEnet/EEIO.sv
../src/doubler0_full.sv
$COMMON/EEnet/CapDeq.sv
doubler_stim.sv
doubler_EE_full_tb.sv
