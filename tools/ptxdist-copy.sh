#!/bin/sh

sudo cp -a $1 $2

touch $2/home/client/src/*
touch $2/home/client/src/old
