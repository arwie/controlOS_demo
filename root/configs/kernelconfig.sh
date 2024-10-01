#!/bin/sh

BASEDIR=$(dirname $(realpath $0))

cd $BASEDIR/..


PLATFORM=configs/platform-$(ptxdist print PTXCONF_PLATFORM)

cat base/$PLATFORM/kernelconfig.d/* > $PLATFORM/kernelconfig
cat $PLATFORM/kernelconfig.d/* >> $PLATFORM/kernelconfig
rm $PLATFORM/kernelconfig.diff

ptxdist kernelconfig
