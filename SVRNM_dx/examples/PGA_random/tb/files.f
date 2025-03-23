-access +rw
-gui
-run
-input input.tcl
-svseed random
$COMMON/packages/mymath_pkg.sv
../src/cktImpairments_pkg.sv
-v ../src/pga.sv

./pga_TB.sv
