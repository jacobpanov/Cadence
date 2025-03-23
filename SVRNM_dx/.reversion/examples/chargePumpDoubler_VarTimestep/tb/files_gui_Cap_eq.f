-clean
-access r
-rnm_tech
-nowarn NSVCER
-nowarn SAWSTP
-define TSAMP=180e-9
-status
-gui
-input probes.tcl
$COMMON/EEnet/CapGeq.sv
$COMMON/EEnet/VIRsrcG.sv
$COMMON/EEnet/VRsrcD.sv
$COMMON/EEnet/EEIO.sv
../src/doubler_Cap_eq.sv
$COMMON/EEnet/CapDeq.sv
doubler_stim.sv
doubler_Cap_eq_tb.sv
