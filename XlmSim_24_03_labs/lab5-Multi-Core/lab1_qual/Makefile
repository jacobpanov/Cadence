
WORKDIR = ../workdir
SIMDIR_S = $(WORKDIR)/xrun_COMPRESSION_SERIAL
XRUN_FILES = +TESTFILE1=$(WORKDIR)/testresults/verilog/COMPRESSION_SERIAL/VER.COMPRESSION.data.scan.ex1.ts1.verilog +TESTFILE2=$(WORKDIR)/testresults/verilog/COMPRESSION_SERIAL/VER.COMPRESSION.data.logic.ex1.ts2.verilog  -incdir $(WORKDIR)/../LIBS/verilog/  -v $(WORKDIR)/../LIBS/verilog/include_libraries_sim.v $(WORKDIR)/../RTL/dtmf_chip.test_netlist.v $(WORKDIR)/testresults/verilog/COMPRESSION_SERIAL/VER.COMPRESSION.mainsim.v

XRUN_OPTS = +nospecify +access+r -profile -rdprofile -status -status3 +xmstatus +xmtimescale+1ns/1ps +xmoverride_timescale +xmseq_udp_delay+2ps +libext+.v+.V +xmlibdirname+$(SIMDIR_S)  +HEARTBEAT +FAILSET +miscompare_limit=10 

sc_est:clean
	xrun ${XRUN_FILES} ${XRUN_OPTS} -64bit -mce_acc_estimation dut_prof.cfg -l sc_est.log

clean:
	rm -rf mcesim.run *.err *.out *.log *.history xmprof.out.mce_xray workdir/xrun_COMPRESSION* workdir/xrun.sim* workdir/*.history workdir/xrun_mce_*
