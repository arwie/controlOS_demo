# -*-makefile-*-
#
# Copyright (C) 2019 by Guillermo Rodriguez <guille.rodriguez@gmail.com>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_PYTHON3_PYCPARSER) += python3-pycparser

#
# Paths and names
#
PYTHON3_PYCPARSER_VERSION	:= 2.21
PYTHON3_PYCPARSER_MD5		:= 48f7d743bf018f7bb2ffc5fb976d1492
PYTHON3_PYCPARSER		:= pycparser-$(PYTHON3_PYCPARSER_VERSION)
PYTHON3_PYCPARSER_SUFFIX	:= tar.gz
PYTHON3_PYCPARSER_URL		:= $(call ptx/mirror-pypi, pycparser, $(PYTHON3_PYCPARSER).$(PYTHON3_PYCPARSER_SUFFIX))
PYTHON3_PYCPARSER_SOURCE	:= $(SRCDIR)/$(PYTHON3_PYCPARSER).$(PYTHON3_PYCPARSER_SUFFIX)
PYTHON3_PYCPARSER_DIR		:= $(BUILDDIR)/$(PYTHON3_PYCPARSER)
PYTHON3_PYCPARSER_LICENSE	:= BSD-3-Clause
PYTHON3_PYCPARSER_LICENSE_FILES := \
	file://LICENSE;md5=2c28cdeabcb88f5843d934381b4b4fea

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PYTHON3_PYCPARSER_CONF_TOOL	:= python3

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/python3-pycparser.targetinstall:
	@$(call targetinfo)

	@$(call install_init, python3-pycparser)
	@$(call install_fixup, python3-pycparser, PRIORITY, optional)
	@$(call install_fixup, python3-pycparser, SECTION, base)
	@$(call install_fixup, python3-pycparser, AUTHOR, "Guillermo Rodriguez <guille.rodriguez@gmail.com>")
	@$(call install_fixup, python3-pycparser, DESCRIPTION, missing)

	@$(call install_glob, python3-pycparser, 0, 0, -, \
		$(PYTHON3_SITEPACKAGES)/pycparser,, *.py)

	@$(call install_finish, python3-pycparser)

	@$(call touch)

# vim: syntax=make
