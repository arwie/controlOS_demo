#!/bin/sh

# within ptxcontainer container

ccache -Czs

find /home/client/src/ -not -anewer /home/client/src/old -delete
