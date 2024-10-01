#!/bin/sh

# Copyright (c) 2021 Artur Wiebe <artur@4wiebe.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


BASEDIR=$(dirname $(realpath $0))


# gpg home dir of the development team (where the private key to sign the update file will be stored)
GPGHOME_HOST="$BASEDIR/gpg"

# gpg home dir on the target device (where the public key for update verification will be stored)
GPGHOME_TRGT="$BASEDIR/../root/projectroot/etc/gpg"


# create gpg home on host
rm -rf $GPGHOME_HOST
mkdir  $GPGHOME_HOST

# create gpg home on tartget
rm -rf $GPGHOME_TRGT
mkdir  $GPGHOME_TRGT


# generate host keys
gpg --homedir=$GPGHOME_HOST --batch --passphrase='' --quick-generate-key 'update' default default never
gpg --homedir=$GPGHOME_HOST --batch --passphrase='' --quick-generate-key 'backup' default default never
gpg --homedir=$GPGHOME_HOST --no-random-seed-file --armor --gen-random 2 64 > $GPGHOME_HOST/common.symkey

# export host public keys to target
gpg --homedir=$GPGHOME_HOST --output=$GPGHOME_TRGT/update.pubkey --export 'update'
gpg --homedir=$GPGHOME_HOST --output=$GPGHOME_TRGT/backup.pubkey --export 'backup'
cp $GPGHOME_HOST/common.symkey $GPGHOME_TRGT

# remove unnecessary files
rm -v $GPGHOME_HOST/*~
