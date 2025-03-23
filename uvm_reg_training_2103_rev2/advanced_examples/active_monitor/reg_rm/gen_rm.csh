#!/bin/csh -f 

if ! $?UVMHOME  then
   echo " ***ERROR - $UVMHOME not set - please run setup script"; exit 1
endif

# consolidate UVM variables
if ! $?UVM_HOME  then
  setenv UVM_HOME $UVMHOME
endif

# set IREG_GEN path
if ! $?IREG_GEN  then
   echo " ***ERROR - $IREG_GEN not set - please run setup script"; exit 1
endif

# For a full list of iregGen options, type:   
# $IREG_GEN/bin/iregGen –help

  $IREG_GEN/bin/iregGen \
    -i ./reg_rm.xml \
    -o  reg_rm_pkg.sv \
    -pkg reg_rm_pkg \
    -qt quickTest.sv \
    -ta _c \
    -uvm11a

