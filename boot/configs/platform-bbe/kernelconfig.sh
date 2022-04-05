#!/bin/sh

BASEDIR=$(dirname $(realpath $0))

cd $BASEDIR


cat bb.org_defconfig ../kernelconfig-common.in kernelconfig.in > kernelconfig
