#!/bin/sh

  fail=0

  pathname=`pwd`
  lab=`basename $pathname`

  ../sources/${lab}/.make_new.sh

  rm -f results.txt > /dev/null 2>&1
  touch results.txt

  execute () {
     echo "$1 >> $2 2>&1" >> results.txt
     echo "$1 >> $2 2>&1"
     $1 >> $2 2>&1 || {
       echo "#FAIL: ${lab}: $1 >> $2 2>&1" >> results.txt
       echo "#FAIL: ${lab}: $1 >> $2 2>&1"
       exit 1
      }
  }

  echo ""

  execute "irun rcvr.v rcvr_test.v -q" "/dev/null"
  execute "grep Message.received:.I.Love.Verilog irun.log" "/dev/null"
  execute "grep TEST.DONE irun.log" "/dev/null"

# run this part only if needed to regenerate synthesis output
# execute "rm rcvr.vg rcvr.sdf" "/dev/null"
# execute "rc -files ../sources/lab6-sdf/.rc_shell.tcl" "/dev/null"

  execute "cp ../solutions/lab-appendixC-sdf/techlib.v ." "/dev/null"
  execute "irun rcvr.vg rcvr_test.v -timescale 1ns/10ps -v techlib.v -vlogext vg" "/dev/null"
  execute "grep Warning\!..Timing.violation irun.log" "/dev/null"
  execute "grep TEST.TIMEOUT irun.log" "/dev/null"

  execute "cp ../solutions/$lab/rcvr_test.v ." "/dev/null"
  execute "irun rcvr.vg rcvr_test.v -maxdelays -sdf_verbose -timescale 1ns/10ps -v techlib.v -vlogext vg" "/dev/null"
  execute "grep Message.received:.I.Love.Verilog irun.log" "/dev/null"
  execute "grep TEST.DONE irun.log" "/dev/null"

  cp results.txt ../solutions/${lab}/

  echo ""

