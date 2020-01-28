#!/bin/sh

SCRIPT=$(readlink -f $0)
BASEDIR=$(dirname $SCRIPT)

cd $BASEDIR

cat x86_64_defconfig kernelconfig-common.in kernelconfig.in > kernelconfig
