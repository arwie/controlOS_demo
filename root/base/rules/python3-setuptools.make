# -*-makefile-*-
#
# Copyright (C) 2019 by Lars Pedersen <lapeddk@gmail.com>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_PYTHON3_SETUPTOOLS) += python3-setuptools

#
# Paths and names
#
PYTHON3_SETUPTOOLS_VERSION	:= 67.4.0
PYTHON3_SETUPTOOLS_MD5		:= a15e7546790b932a94fd9ccca7f839de
PYTHON3_SETUPTOOLS		:= setuptools-$(PYTHON3_SETUPTOOLS_VERSION)
PYTHON3_SETUPTOOLS_SUFFIX	:= tar.gz
PYTHON3_SETUPTOOLS_URL		:= $(call ptx/mirror-pypi, setuptools, $(PYTHON3_SETUPTOOLS).$(PYTHON3_SETUPTOOLS_SUFFIX))
PYTHON3_SETUPTOOLS_SOURCE	:= $(SRCDIR)/$(PYTHON3_SETUPTOOLS).$(PYTHON3_SETUPTOOLS_SUFFIX)
PYTHON3_SETUPTOOLS_DIR		:= $(BUILDDIR)/$(PYTHON3_SETUPTOOLS)
PYTHON3_SETUPTOOLS_LICENSE	:= MIT
PYTHON3_SETUPTOOLS_LICENSE_FILES	:= \
	file://LICENSE;md5=7a7126e068206290f3fe9f8d6c713ea6

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PYTHON3_SETUPTOOLS_CONF_TOOL	:= python3

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/python3-setuptools.targetinstall:
	@$(call targetinfo)

	@$(call install_init, python3-setuptools)
	@$(call install_fixup, python3-setuptools,PRIORITY,optional)
	@$(call install_fixup, python3-setuptools,SECTION,base)
	@$(call install_fixup, python3-setuptools,AUTHOR,"Lars Pedersen <lapeddk@gmail.com>")
	@$(call install_fixup, python3-setuptools,DESCRIPTION,missing)

	@$(call install_glob,python3-setuptools, 0, 0, -, \
		$(PYTHON3_SITEPACKAGES),, *.py *.exe)

	@$(call install_finish, python3-setuptools)

	@$(call touch)

# vim: syntax=make
