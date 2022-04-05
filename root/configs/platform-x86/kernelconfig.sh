#!/bin/sh

BASEDIR=$(dirname $(realpath $0))

cd $BASEDIR

BASECONFIGS="../../base/configs"

cat $BASECONFIGS/platform-x86/x86_64_defconfig $BASECONFIGS/kernelconfig-common.in $BASECONFIGS/platform-x86/kernelconfig-platform.in kernelconfig.in > kernelconfig
