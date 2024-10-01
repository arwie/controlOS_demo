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
PACKAGES-$(PTXCONF_PYTHON3_CFFI) += python3-cffi

#
# Paths and names
#
PYTHON3_CFFI_VERSION	:= 1.16.0
PYTHON3_CFFI_MD5	:= 0bcaed453da3004d0bea103038345c1e
PYTHON3_CFFI		:= cffi-$(PYTHON3_CFFI_VERSION)
PYTHON3_CFFI_SUFFIX	:= tar.gz
PYTHON3_CFFI_URL	:= $(call ptx/mirror-pypi, cffi, $(PYTHON3_CFFI).$(PYTHON3_CFFI_SUFFIX))
PYTHON3_CFFI_SOURCE	:= $(SRCDIR)/$(PYTHON3_CFFI).$(PYTHON3_CFFI_SUFFIX)
PYTHON3_CFFI_DIR	:= $(BUILDDIR)/$(PYTHON3_CFFI)
PYTHON3_CFFI_LICENSE	:= MIT
PYTHON3_CFFI_LICENSE_FILES := \
	file://LICENSE;md5=5677e2fdbf7cdda61d6dd2b57df547bf

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PYTHON3_CFFI_CONF_TOOL	:= python3

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/python3-cffi.targetinstall:
	@$(call targetinfo)

	@$(call install_init, python3-cffi)
	@$(call install_fixup, python3-cffi, PRIORITY, optional)
	@$(call install_fixup, python3-cffi, SECTION, base)
	@$(call install_fixup, python3-cffi, AUTHOR, "Guillermo Rodriguez <guille.rodriguez@gmail.com>")
	@$(call install_fixup, python3-cffi, DESCRIPTION, missing)

	@$(call install_glob, python3-cffi, 0, 0, -, \
		$(PYTHON3_SITEPACKAGES)/cffi,, *.py *.h)

	@$(call install_lib, python3-cffi, 0, 0, 0644, python$(PYTHON3_MAJORMINOR)/site-packages/_cffi_backend.cpython*)

	@$(call install_finish, python3-cffi)

	@$(call touch)

# vim: syntax=make
