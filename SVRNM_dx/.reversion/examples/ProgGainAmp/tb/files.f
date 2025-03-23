-access +rw
-gui
-run
-input input.tcl
$COMMON/packages/mymath_pkg.sv
-v ../src/pga.sv

./pga_TB.sv
