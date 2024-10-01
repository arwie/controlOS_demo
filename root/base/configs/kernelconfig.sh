#!/bin/sh

BASEDIR=$(dirname $(realpath $0))

cd $BASEDIR/..


PLATFORM=configs/platform-$(ptxdist print PTXCONF_PLATFORM)

cat $PLATFORM/kernelconfig.d/* > $PLATFORM/kernelconfig

ptxdist kernelconfig
