#!/bin/bash

set -e

if [ -n "${pkg_stamp}" ] && ! [[ " ${pkg_build_deps} " =~ " host-gettext " ]]; then
	echo "No host-gettext dependency. Faking autopoint: AUTOPOINT=true."
	export AUTOPOINT=true
fi
export GTKDOCIZE=true

aclocal $ACLOCAL_FLAGS

libtoolize \
	--force \
	--copy

autoreconf \
	--force \
	--install \
	--warnings=cross \
	--warnings=syntax \
	--warnings=obsolete \
	--warnings=unsupported

