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

  execute "cp ../solutions/$lab/vreadmem_test95.v ." "/dev/null"
  execute "irun vreadmem_test95.v" "/dev/null"
  execute "grep Simulation.is.complete irun.log" "dev/null"
  echo "" >> results.txt; echo ""
  echo "#PASS: $lab" >> results.txt
  echo "#PASS: $lab"

  cp results.txt ../solutions/${lab}/

  echo ""

