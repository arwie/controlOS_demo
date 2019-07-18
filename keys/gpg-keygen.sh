#!/bin/sh

SCRIPT=$(readlink -f $0)
BASEDIR=$(dirname $SCRIPT)


# gpg home dir on the target device (where the public key vor update verification will be stored)
GPGHOME_TRGT="$BASEDIR/../root/projectroot/etc/gpg"

# gpg home dir of the development team (where the private key to sign the update file will be stored)
# this newly created directory needs to be moved to a secure place
GPGHOME_HOST="./gpg"

# key names
KEYNAME_TRGT="TARGET"
KEYNAME_HOST="HOST"



# prepare gpg homedir for HOST
##########################################

# create gpg home for HOST
mkdir  $GPGHOME_HOST
rm -rf $GPGHOME_HOST/*

GPGOPTS_HOST="$GPGHOME_HOST/gpg.conf"

cat > $GPGOPTS_HOST <<+++++
default-recipient $KEYNAME_TRGT
batch
no-greeting
lock-never
no-random-seed-file
no-sig-cache
no-auto-key-locate
+++++



# generate keys for HOST developers
###################################################

echo "creating keys for $KEYNAME_HOST --- this will take a while ..."
gpg2  --homedir $GPGHOME_HOST  --gen-key  <<+++++
Key-Type: default
Subkey-Type: default
Name-Real: $KEYNAME_HOST
Expire-Date: 0
%commit
+++++



# generate keys for the TARGET device
##########################################

# clean gpg home on TARGET
rm -rf $GPGHOME_TRGT/*.gpg

echo "creating keys for $KEYNAME_TRGT --- this will take a while ..."
gpg2  --homedir $GPGHOME_TRGT  --options $GPGOPTS_HOST  --gen-key  <<+++++
Key-Type: default
Subkey-Type: default
Name-Real: $KEYNAME_TRGT
Expire-Date: 0
%commit
+++++



# exchange public keys and trust them
###################################################

# import TARGET public key into HOST keyring
gpg2  --homedir $GPGHOME_TRGT  --options $GPGOPTS_HOST  --export  |  gpg2  --homedir $GPGHOME_HOST  --import

# import HOST public key into TARGET keyring
gpg2  --homedir $GPGHOME_HOST  --export  |  gpg2  --homedir $GPGHOME_TRGT  --options $GPGOPTS_HOST  --import

# trust all public keys in HOST keyring
gpg2  --homedir $GPGHOME_HOST  --fingerprint  --with-colons  --list-keys  |  sed -n "s/fpr:*\(.*\):/\1:6:/p"  |  gpg2  --homedir $GPGHOME_HOST  --import-ownertrust
gpg2  --homedir $GPGHOME_HOST  --update-trustdb

# trust all public keys in TARGET keyring
gpg2  --homedir $GPGHOME_TRGT  --options $GPGOPTS_HOST  --fingerprint  --with-colons  --list-keys  |  sed -n "s/fpr:*\(.*\):/\1:6:/p"  |  gpg2  --homedir $GPGHOME_TRGT  --options $GPGOPTS_HOST  --import-ownertrust
gpg2  --homedir $GPGHOME_TRGT  --options $GPGOPTS_HOST  --update-trustdb



# remove unnecessary files
###################################################

rm -f  $GPGHOME_HOST/*.gpg~
rm -f  $GPGHOME_TRGT/*.gpg~



# generate update signing script
###################################################

SIGNSCRIPT="$GPGHOME_HOST/gpg-sign-encrypt"

cat > $SIGNSCRIPT <<+++++
#!/bin/sh

SCRIPT=\$(readlink -f \$0)
BASEDIR=\$(dirname \$SCRIPT)

if [ "\$#" -ne 1 ] || [ ! -f "\$1" ]; then
  echo "Usage: \$0 path/to/update" >&2
  exit 1
fi

gpg2  --homedir \$BASEDIR  --sign  --encrypt  \$1
+++++

chmod 755 $SIGNSCRIPT

