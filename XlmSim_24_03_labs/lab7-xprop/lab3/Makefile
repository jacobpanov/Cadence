clean:
	rm -rf *.log *.key INCA_* *.shm *.history cov_work/* *.diag xcelium* *.swp xcelium.d/

run_noxprop:
	xrun -clean -mess -access rwc -v93 tb_mux.vhd mux.vhd  -top tb_mux -l xrun.noxprop.log

run_xprop_cat:
	xrun -clean -mess -access rwc -v93 tb_mux.vhd mux.vhd -xfile xfile_cat.txt -top tb_mux -l xrun_xprop_cat.log -input tcl.in -ENABLE_XP_DEBUG_CODE -xverbose

run_xprop_fox:
	xrun -clean -mess -access rwc -v93 tb_mux.vhd mux.vhd -input tcl.in -xfile xfile_fox.txt -top tb_mux -l xrun_xprop_fox.log -ENABLE_XP_DEBUG_CODE -xverbose 
