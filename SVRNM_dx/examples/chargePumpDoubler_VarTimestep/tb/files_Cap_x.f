-clean
-access r
-rnm_tech
-nowarn NSVCER
-nowarn SAWSTP
-define TMIN=1e-9
-define TMAX=10e-6
-define REPEAT
-status
-run
-exit
$COMMON/EEnet/CapGx.sv
$COMMON/EEnet/VIRsrcG.sv
$COMMON/EEnet/VRsrcD.sv
$COMMON/EEnet/EEIO.sv
../src/doubler_Cap_x.sv
$COMMON/EEnet/CapDx.sv
doubler_stim.sv
doubler_Cap_x_tb.sv
