#!/bin/sh

BASEDIR=$(dirname $(realpath $0))

cd $BASEDIR


cat x86_64_defconfig ../kernelconfig-common.in kernelconfig-platform.in kernelconfig.in > kernelconfig
