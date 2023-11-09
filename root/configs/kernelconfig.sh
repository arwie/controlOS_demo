#!/bin/sh

BASEDIR=$(dirname $(realpath $0))

cd $BASEDIR/..

KERNELCONFIG=$(ptxdist print KERNEL_CONFIG)

cat $KERNELCONFIG.d/* > $KERNELCONFIG

ptxdist kernelconfig
