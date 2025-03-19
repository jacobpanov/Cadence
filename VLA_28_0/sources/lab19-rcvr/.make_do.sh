#!/bin/sh

  mod=rcvr

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

  [ -z $RCHOME ] && RCHOME=`cds_root rc` && export RCHOME
  [ -d ~/.cadence ] || mkdir ~/.cadence
  [ -f ~/.cadence/.synth_init ] || touch ~/.cadence/.synth_init

  echo ""
  execute "cp ../solutions/$lab/$mod.v ." "/dev/null"
  execute "irun $mod.v ${mod}_test.v" "/dev/null"
  execute "grep I.Love.Verilog irun.log" "/dev/null"
  execute "grep TEST.DONE irun.log" "/dev/null"
  execute "rc -rcl -files rc_shell.tcl" "/dev/null"
  execute "grep Synthesis.succeeded rc.log" "/dev/null"
  execute "irun $mod.vg ${mod}_test.v -v ../tutorial.v -vlogext vg" "/dev/null"
  execute "grep I.Love.Verilog irun.log" "/dev/null"
  execute "grep TEST.DONE irun.log" "/dev/null"
  echo "" >> results.txt; echo ""

  echo "#PASS: $lab" >> results.txt
  echo "#PASS: $lab"

  cp results.txt ../solutions/${lab}/

  echo ""

