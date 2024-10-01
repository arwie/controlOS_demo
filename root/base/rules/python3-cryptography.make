# -*-makefile-*-
#
# Copyright (C) 2023 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_PYTHON3_CRYPTOGRAPHY) += python3-cryptography

#
# Paths and names
#
PYTHON3_CRYPTOGRAPHY_VERSION		:= 41.0.7
PYTHON3_CRYPTOGRAPHY_MD5		:= c06f01c4bc95327c2e4378589ed5a193
PYTHON3_CRYPTOGRAPHY			:= cryptography-$(PYTHON3_CRYPTOGRAPHY_VERSION)
PYTHON3_CRYPTOGRAPHY_SUFFIX		:= tar.gz
PYTHON3_CRYPTOGRAPHY_URL		:= $(call ptx/mirror-pypi, cryptography, $(PYTHON3_CRYPTOGRAPHY).$(PYTHON3_CRYPTOGRAPHY_SUFFIX))
PYTHON3_CRYPTOGRAPHY_SOURCE		:= $(SRCDIR)/$(PYTHON3_CRYPTOGRAPHY).$(PYTHON3_CRYPTOGRAPHY_SUFFIX)
PYTHON3_CRYPTOGRAPHY_DIR		:= $(BUILDDIR)/$(PYTHON3_CRYPTOGRAPHY)
PYTHON3_CRYPTOGRAPHY_CARGO_LOCK		:= src/rust/Cargo.lock
# licenses for the rust dependencies are missing
PYTHON3_CRYPTOGRAPHY_LICENSE		:= ( Apache-2.0 OR BSD-3-Clause ) AND unknown
PYTHON3_CRYPTOGRAPHY_LICENSE_FILES	:= \
	file://LICENSE;md5=8c3617db4fb6fae01f1d253ab91511e4 \
	file://LICENSE.APACHE;md5=4e168cce331e5c827d4c2b68a6200e1b \
	file://LICENSE.BSD;md5=5ae30ba4123bc4f2fa49aa0b0dce887b

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PYTHON3_CRYPTOGRAPHY_CONF_TOOL	:= python3
PYTHON3_CRYPTOGRAPHY_CONF_ENV	= $(CROSS_ENV) \
	OPENSSL_DIR="$(PTXDIST_SYSROOT_TARGET)/usr" \
	PYO3_CROSS_LIB_DIR="$(PTXDIST_SYSROOT_TARGET)/usr/lib" \
	PYO3_PYTHON="python$(PYTHON3_MAJORMINOR)"

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/python3-cryptography.targetinstall:
	@$(call targetinfo)

	@$(call install_init, python3-cryptography)
	@$(call install_fixup, python3-cryptography,PRIORITY,optional)
	@$(call install_fixup, python3-cryptography,SECTION,base)
	@$(call install_fixup, python3-cryptography,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, python3-cryptography,DESCRIPTION,missing)

	@$(call install_glob, python3-cryptography, 0, 0, -, \
		$(PYTHON3_SITEPACKAGES)/cryptography,, *.py)

	@$(call install_finish, python3-cryptography)

	@$(call touch)

# vim: syntax=make
