#!/bin/sh

BASEDIR=$(dirname $(realpath $0))

cd $BASEDIR

BASECONFIGS="../../base/configs"

cat $BASECONFIGS/platform-bbe/bb.org_defconfig $BASECONFIGS/kernelconfig-common.in $BASECONFIGS/platform-bbe/kernelconfig-platform.in kernelconfig.in > kernelconfig
