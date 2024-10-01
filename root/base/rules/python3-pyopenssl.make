# -*-makefile-*-
#
# Copyright (C) 2024 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_PYTHON3_PYOPENSSL) += python3-pyopenssl

#
# Paths and names
#
PYTHON3_PYOPENSSL_VERSION	:= 24.0.0
PYTHON3_PYOPENSSL_MD5		:= e4e9f1519cbb54dfb6426bde212ca922
PYTHON3_PYOPENSSL		:= pyOpenSSL-$(PYTHON3_PYOPENSSL_VERSION)
PYTHON3_PYOPENSSL_SUFFIX	:= tar.gz
PYTHON3_PYOPENSSL_URL		:= $(call ptx/mirror-pypi, pyopenssl, $(PYTHON3_PYOPENSSL).$(PYTHON3_PYOPENSSL_SUFFIX))
PYTHON3_PYOPENSSL_SOURCE	:= $(SRCDIR)/$(PYTHON3_PYOPENSSL).$(PYTHON3_PYOPENSSL_SUFFIX)
PYTHON3_PYOPENSSL_DIR		:= $(BUILDDIR)/$(PYTHON3_PYOPENSSL)
PYTHON3_PYOPENSSL_LICENSE	:= Apache-2.0
PYTHON3_PYOPENSSL_LICENSE_FILES	:= file://LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PYTHON3_PYOPENSSL_CONF_TOOL	:= python3

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/python3-pyopenssl.targetinstall:
	@$(call targetinfo)

	@$(call install_init, python3-pyopenssl)
	@$(call install_fixup, python3-pyopenssl,PRIORITY,optional)
	@$(call install_fixup, python3-pyopenssl,SECTION,base)
	@$(call install_fixup, python3-pyopenssl,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, python3-pyopenssl,DESCRIPTION,missing)

	@$(call install_glob, python3-pyopenssl, 0, 0, -, \
		$(PYTHON3_SITEPACKAGES),, *.py)

	@$(call install_finish, python3-pyopenssl)

	@$(call touch)

# vim: syntax=make
