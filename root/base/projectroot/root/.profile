#!/bin/sh


systemctl --no-block start debug.target

mount --options=remount,rw --target=/
