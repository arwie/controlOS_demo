#!/bin/sh

SCRIPT=$(realpath $0)
BASEDIR=$(dirname $SCRIPT)

cd $BASEDIR


cat ../../base/configs/platform-x86/x86_64_defconfig ../../base/configs/platform-x86/kernelconfig-common.in kernelconfig.in > kernelconfig
