#!/bin/sh

  dumpvarlines=459
  dumpportlines=524

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

  execute "cp ../solutions/$lab/test.v ." "/dev/null"
  execute "irun dkm.v test.v" "/dev/null"
  execute "grep TEST.PASSED irun.log" "/dev/null"
  #execute "diff ../solutions/$lab/monitor.txt monitor.txt" "/dev/null"
  #execute "tail -$dumpvarlines ../solutions/$lab/verilog.dump" dumpvarold.txt
  #execute "tail -$dumpvarlines                   verilog.dump" dumpvarnew.txt
  #execute "diff dumpvarold.txt dumpvarnew.txt" "/dev/null"
  #execute "tail -$dumpportlines ../solutions/$lab/verilog.evcd" dumpportold.txt
  #execute "tail -$dumpportlines                   verilog.evcd" dumpportnew.txt
  #execute "diff dumpportold.txt dumpportnew.txt" "/dev/null"
  echo "" >> results.txt; echo ""

  echo "#PASS: $lab" >> results.txt
  echo "#PASS: $lab"

  cp results.txt ../solutions/${lab}/

  echo ""

