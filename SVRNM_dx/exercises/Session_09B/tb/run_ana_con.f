-access r
-ana anactrl.scs 
-rnm_tech
-nowarn NSVCER
-nowarn SAWSTP
-64bit
-iereport
-status
-define REPEAT
$COMMON/EEnet/EVIRsrcG.vams
$COMMON/EEnet/EVmeas.vams
../src/doubler_full.vams
doubler_stim.sv
doubler_ana_tb.sv
