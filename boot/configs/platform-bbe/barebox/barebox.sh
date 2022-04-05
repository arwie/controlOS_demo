#!/bin/sh

BASEDIR=$(dirname $(realpath $0))

cd $BASEDIR


cat am335x_mlo_defconfig barebox_mlo.in > barebox_mlo.config

cat omap_defconfig barebox.in > barebox.config
