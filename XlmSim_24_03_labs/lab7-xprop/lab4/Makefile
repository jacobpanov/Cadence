clean:
	rm -rf *.log *.key INCA_* *.shm *.history cov_work/* *.diag xcelium* *.swp xcelium.d/

run_noxprop:
	xrun -clean -sv -mess -access +r -uvm -incdir ./examples -incdir ./sv ./examples/cache_top.sv ./examples/data_mem.sv ./examples/extmem_interface.sv ./examples/main_ctrl.sv ./examples/processor_interface.sv ./examples/tag_cmp.sv ./examples/tag_mem.sv ./examples/demo_top.sv +UVM_TESTNAME=mul_sequence_test -status -log_ncsim xrun_noxprop.log -input tcl.in -rmkeyword checker


run_xprop:
	xrun -clean -sv -mess -access +r -uvm -incdir ./examples -incdir ./sv ./examples/cache_top.sv ./examples/data_mem.sv ./examples/extmem_interface.sv ./examples/main_ctrl.sv ./examples/processor_interface.sv ./examples/tag_cmp.sv ./examples/tag_mem.sv ./examples/demo_top.sv +UVM_TESTNAME=mul_sequence_test -status -xfile xfile.txt -xverbose -ENABLE_XP_DEBUG_CODE -linedebug -log_ncsim xrun_xprop.log -input tcl.in -rmkeyword checker


run_xprop_gui:
	xrun -clean -sv -mess -access +r -uvm -incdir ./examples -incdir ./sv ./examples/cache_top.sv ./examples/data_mem.sv ./examples/extmem_interface.sv ./examples/main_ctrl.sv ./examples/processor_interface.sv ./examples/tag_cmp.sv ./examples/tag_mem.sv ./examples/demo_top.sv +UVM_TESTNAME=mul_sequence_test -status -xfile xfile.txt -xverbose -ENABLE_XP_DEBUG_CODE -log_ncsim xrun_xprop.log -input gui_tcl.in -gui -rmkeyword checker
