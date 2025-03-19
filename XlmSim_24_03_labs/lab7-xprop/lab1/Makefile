clean:
	rm -rf *.log *.key INCA_* *.shm *.history cov_work/* *.diag xcelium* *.swp xcelium.d/

run_noxprop:
	xrun  -clean -mess -access rwc tb.v dut.v -l xrun.noxprop.log

run_xprop_cat:
	xrun  -clean -mess -access rwc tb.v dut.v -input tcl.in -xfile xfile_cat.txt -xverbose -ENABLE_XP_DEBUG_CODE -l xrun_xprop_cat.log

run_xprop_fox:
	xrun  -clean -mess -access rwc tb.v dut.v -input tcl.in -xfile xfile_fox.txt -xverbose -ENABLE_XP_DEBUG_CODE -l xrun_xprop_fox.log
