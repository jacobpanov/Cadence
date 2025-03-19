#!/bin/sh

  pathname=`pwd`
  lab=`basename $pathname`

  rm -fr * .simvision > /dev/null 2>&1

  cp -pr ../sources/${lab}/* .
