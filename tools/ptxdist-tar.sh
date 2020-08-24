#!/bin/sh

sudo tar -cv $1 | xz -z -T0 - > $(basename $1).txz
