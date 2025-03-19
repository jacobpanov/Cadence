#!/bin/sh

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

  execute "rm -fr INCA_libs irun.log" "/dev/null"
  execute "cp ../solutions/$lab/test.v ." "/dev/null"
  execute "irun cpu.v test.v -access rwc -input .ncsim.tcl -q" "/dev/null"
  execute "grep address.=.17 irun.log" "/dev/null"
  execute "grep address.=.10 irun.log" "/dev/null"
  execute "grep address.=.0c irun.log" "/dev/null"
  echo "" >> results.txt; echo ""

  echo "#PASS: $lab" >> results.txt
  echo "#PASS: $lab"

  cp results.txt ../solutions/${lab}/

  echo ""

