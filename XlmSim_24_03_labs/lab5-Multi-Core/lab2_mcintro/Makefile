WORKDIR = ../workdir
SIMDIR_S = $(WORKDIR)/xrun_COMPRESSION_SERIAL

XRUN_FILES = +TESTFILE1=$(WORKDIR)/testresults/verilog/COMPRESSION_SERIAL/VER.COMPRESSION.data.scan.ex1.ts1.verilog +TESTFILE2=$(WORKDIR)/testresults/verilog/COMPRESSION_SERIAL/VER.COMPRESSION.data.logic.ex1.ts2.verilog  -incdir $(WORKDIR)/../LIBS/verilog/  -v $(WORKDIR)/../LIBS/verilog/include_libraries_sim.v $(WORKDIR)/../RTL/dtmf_chip.test_netlist.v $(WORKDIR)/testresults/verilog/COMPRESSION_SERIAL/VER.COMPRESSION.mainsim.v

XRUN_OPTS = +nospecify +access+r -profile -rdprofile -status -status3 +xmstatus +xmtimescale+1ns/1ps +xmoverride_timescale +xmseq_udp_delay+2ps +libext+.v+.V +xmlibdirname+$(SIMDIR_S)  +HEARTBEAT +FAILSET +miscompare_limit=10 

XRUN_COMPILE_OPTS = +nospecify +access+r -profile -rdprofile -status -status3 +xmstatus +xmtimescale+1ns/1ps +xmoverride_timescale +xmseq_udp_delay+2ps +libext+.v+.V +xmlibdirname+$(SIMDIR_S)  +HEARTBEAT +FAILSET +miscompare_limit=10 +TESTFILE1=$(WORKDIR)/testresults/verilog/COMPRESSION_SERIAL/VER.COMPRESSION.data.scan.ex1.ts1.verilog +TESTFILE2=$(WORKDIR)/testresults/verilog/COMPRESSION_SERIAL/VER.COMPRESSION.data.logic.ex1.ts2.verilog  -incdir $(WORKDIR)/../LIBS/verilog/  -v $(WORKDIR)/../LIBS/verilog/include_libraries_sim.v $(WORKDIR)/../RTL/dtmf_chip.test_netlist.v $(WORKDIR)/testresults/verilog/COMPRESSION_SERIAL/VER.COMPRESSION.mainsim.v

XRUN_ELAB_OPTS =  +nospecify +access+r -profile -rdprofile -status -status3 +xmstatus +xmtimescale+1ns/1ps +xmoverride_timescale +xmseq_udp_delay+2ps +libext+.v+.V +xmlibdirname+$(SIMDIR_S) +HEARTBEAT +FAILSET +miscompare_limit=10 -top workdir_COMPRESSION -reflib ../workdir/xrun_COMPRESSION_SERIAL/run.d/xllibs/include_libraries_sim

XRUN_SIM_OPTS =  +nospecify +access+r -profile -rdprofile -status -status3 +xmstatus +xmtimescale+1ns/1ps +xmoverride_timescale +xmseq_udp_delay+2ps +libext+.v+.V +xmlibdirname+$(SIMDIR_S)  +HEARTBEAT +FAILSET +miscompare_limit=10 +TESTFILE1=$(WORKDIR)/testresults/verilog/COMPRESSION_SERIAL/VER.COMPRESSION.data.scan.ex1.ts1.verilog +TESTFILE2=$(WORKDIR)/testresults/verilog/COMPRESSION_SERIAL/VER.COMPRESSION.data.logic.ex1.ts2.verilog  -incdir $(WORKDIR)/../LIBS/verilog/  -v $(WORKDIR)/../LIBS/verilog/include_libraries_sim.v $(WORKDIR)/../RTL/dtmf_chip.test_netlist.v $(WORKDIR)/testresults/verilog/COMPRESSION_SERIAL/VER.COMPRESSION.mainsim.v


# Checking resource requirement for Xcelium MC
mc_resource_check:
	`xmroot`/tools/mce/tools/cpuinfo 

# License requirement check for Test
mc_lic_info:clean
	xrun -64bit -mce -licinfo ${XRUN_FILES} ${XRUN_OPTS}

# Single step mode for multi core simulation

mc_default:clean
	xrun -64bit -mce -mce_pie ${XRUN_FILES} ${XRUN_OPTS} -l mc_default.log

# Run Multi-Core in two steps mode

mc_twosteps:clean
	xrun -c -64bit -mce -mce_pie ${XRUN_FILES} ${XRUN_OPTS} -l mc_elab.log
	xrun -R -64bit -mce -mce_pie ${XRUN_FILES} ${XRUN_OPTS} -l mc_sim.log

# Run Multi-Core in three steps xrun mode

 
mc_threesteps:clean
	xrun -64bit -compile  ${XRUN_COMPILE_OPTS} -l mc_compile.log
	xrun -64bit -mce -mce_pie -elaborate ${XRUN_ELAB_OPTS} -l mc_elab.log
	xrun -64bit -mce -R -mce_pie ${XRUN_SIM_OPTS} -l mc_sim.log

# Multi core default run on single socket for build and simulation 

	
mc_default_socket:clean
	xrun -64bit -mce -mce_pie ${XRUN_FILES} ${XRUN_OPTS} -l mc_default.log


# To provide all cores for build and simulation

mc_allcores:clean
	xrun -64bit -mce -mce_pie ${XRUN_FILES} ${XRUN_OPTS} -mce_build_cpu_configuration all-cores -mce_sim_cpu_configuration all-cores-except-one -l mc_default.log

# To control thread/Cores count


mc_thread_control:clean
	xrun -64bit -mce -mce_pie ${XRUN_FILES} ${XRUN_OPTS}  -mce_sim_thread_count 5 -mce_build_thread_count 5 -l mc_default.log


clean:
	rm -rf mcesim.run *.err *.out *.log *.history workdir/xrun_COMPRESSION* workdir/xrun.sim* workdir/*.history workdir/xrun_mce_* $(SIMDIR_S) *.key
