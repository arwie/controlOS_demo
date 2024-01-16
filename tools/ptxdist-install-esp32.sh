#!/bin/sh

# execute from ptxdist (as user)

cd /opt
git clone --depth=1 --shallow-submodules --recursive -b v4.4.4  https://github.com/espressif/esp-idf.git
export IDF_TOOLS_PATH=/opt/esp-idf
cd esp-idf
./install.sh esp32
rm -rf dist/
