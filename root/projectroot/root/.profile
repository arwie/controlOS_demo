#!/bin/sh


systemctl --no-block start debug.target

mount -o remount,rw LABEL=ROOT
