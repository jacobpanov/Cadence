#!/bin/sh

# Reference flow for running Cadence Xcelium simulator (known as xrun) on ATPG vectors.

reset
export WORKDIR=workdir

TESTMODE="COMPRESSION"
SCANFORMAT="SERIAL"

# Uncomment for GUI Mode
# GUI=-gui

# Uncomment for wavform dump
# SIMV=+simvision

# Directory for simulator internal files
SIMDIR=$WORKDIR/xrun_${TESTMODE}_${SCANFORMAT}

xrun \
   $GUI \
   +nospecify \
   +access+r -status -status3 -profile -rdprofile -mce -mce_pie  \
   +xmstatus \
   +xmtimescale+1ns/1ps \
   +xmoverride_timescale \
   +xmseq_udp_delay+2ps \
   +libext+.v+.V+.z+.Z+.gz \
   +xmlibdirname+$SIMDIR \
   -l $WORKDIR/xrun.sim.${TESTMODE}_${SCANFORMAT}.log \
   +HEARTBEAT \
   +FAILSET \
   $SIMV \
   +miscompare_limit=10 \
   +TESTFILE1=$WORKDIR/testresults/verilog/${TESTMODE}_${SCANFORMAT}/VER.${TESTMODE}.data.scan.ex1.ts1.verilog \
   +TESTFILE2=$WORKDIR/testresults/verilog/${TESTMODE}_${SCANFORMAT}/VER.${TESTMODE}.data.logic.ex1.ts2.verilog \
   -v $WORKDIR/../LIBS/verilog/include_libraries_sim.v \
      $WORKDIR/../RTL/dtmf_chip.test_netlist.v \
      $WORKDIR/testresults/verilog/${TESTMODE}_${SCANFORMAT}/VER.${TESTMODE}.mainsim.v

exit
