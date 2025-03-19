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

  exec_p  () {
     echo "$1 >> $2 2>&1" >> results.txt
     echo "$1 >> $2 2>&1"
     $1 >> $2 2>&1 || {
       echo "#FAIL: ${lab}: $1 >> $2 2>&1" >> results.txt
       echo "#FAIL: ${lab}: $1 >> $2 2>&1"
       fail=1
      }
  }

  echo ""

  for n in 1 2 3; do
    execute "rm -f techlib.v" "/dev/null"
    execute "cp ../solutions/$lab/techlib$n.v ./techlib.v" "/dev/null"
    for test in testdir/* ; do
      execute "rm -f irun.log" "/dev/null"
      exec_p  "irun $test -v techlib.v -q" "/dev/null" && \
      exec_p  "grep TEST.PASSED irun.log" "/dev/null"
    done
    echo "" >> results.txt; echo ""
  done

  if [ $fail = 0 ] ; then
    echo "#PASS: $lab" >> results.txt
    echo "#PASS: $lab"
  else
    echo "#FAIL: $lab" >> results.txt
    echo "#FAIL: $lab"
  fi

  cp results.txt ../solutions/${lab}/

  echo ""

