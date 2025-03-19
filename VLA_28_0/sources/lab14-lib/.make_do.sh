#!/bin/sh

  mod=lib

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

  exec_f  () {
     echo "$1 >> $2 2>&1" >> results.txt
     echo "$1 >> $2 2>&1"
     $1 >> $2 2>&1 && {
       echo "#FAIL: ${lab}: $1 >> $2 2>&1" >> results.txt
       echo "#FAIL: ${lab}: $1 >> $2 2>&1"
       exit 1
      }
  }

  [ -z $RCHOME ] && RCHOME=`cds_root rc` && export RCHOME
  [ -d ~/.cadence ] || mkdir ~/.cadence
  [ -f ~/.cadence/.synth_init ] || touch ~/.cadence/.synth_init

  echo ""
  execute "cp ../solutions/$lab/$mod.v ." "/dev/null"
  execute "irun $mod.v ${mod}_test.v" "/dev/null"
  exec_f  "grep TEST.FAILED irun.log" "/dev/null"
  execute "grep TEST.PASSED irun.log" "/dev/null"
  execute "rc -rcl -files rc_shell.tcl" "/dev/null"
  execute "grep Synthesis.succeeded rc.log" "/dev/null"
  execute "rm -fr INCA_libs irun.log" "/dev/null"
  execute "irun *.vg ${mod}_test.v -v ../tutorial.v -vlogext vg" "/dev/null"
  exec_f  "grep TEST.FAILED irun.log" "/dev/null"
  execute "grep TEST.PASSED irun.log" "/dev/null"
  echo "" >> results.txt; echo ""

  echo "#PASS: $lab" >> results.txt
  echo "#PASS: $lab"

  cp results.txt ../solutions/${lab}/

  echo ""

