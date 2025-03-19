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

  execute "irun test.v" "/dev/null"
  execute "diff ../solutions/$lab/outfile1.txt outfile.txt" "/dev/null"
  execute "cp ../solutions/$lab/test.v ." "/dev/null"
  execute "irun test.v" "/dev/null"
  execute "diff ../solutions/$lab/outfile2.txt outfile.txt" "/dev/null"
  echo "" >> results.txt; echo ""

  echo "#PASS: $lab" >> results.txt
  echo "#PASS: $lab"

  cp results.txt ../solutions/${lab}/

  echo ""

