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
PACKAGES-$(PTXCONF_PYTHON3_ASYNCUA) += python3-asyncua

#
# Paths and names
#
PYTHON3_ASYNCUA_VERSION		:= 1.1.0
PYTHON3_ASYNCUA_MD5		:= 3131bf0f9554f91c4f63cbdc019fce8b
PYTHON3_ASYNCUA			:= asyncua-$(PYTHON3_ASYNCUA_VERSION)
PYTHON3_ASYNCUA_SUFFIX		:= tar.gz
PYTHON3_ASYNCUA_URL		:= $(call ptx/mirror-pypi, asyncua, $(PYTHON3_ASYNCUA).$(PYTHON3_ASYNCUA_SUFFIX))
PYTHON3_ASYNCUA_SOURCE		:= $(SRCDIR)/$(PYTHON3_ASYNCUA).$(PYTHON3_ASYNCUA_SUFFIX)
PYTHON3_ASYNCUA_DIR		:= $(BUILDDIR)/$(PYTHON3_ASYNCUA)
PYTHON3_ASYNCUA_LICENSE		:= LGPL-3.0-or-later
PYTHON3_ASYNCUA_LICENSE_FILES	:= file://COPYING;md5=e6a600fd5e1d9cbde2d983680233ad02

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PYTHON3_ASYNCUA_CONF_TOOL	:= python3

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/python3-asyncua.targetinstall:
	@$(call targetinfo)

	@$(call install_init, python3-asyncua)
	@$(call install_fixup, python3-asyncua,PRIORITY,optional)
	@$(call install_fixup, python3-asyncua,SECTION,base)
	@$(call install_fixup, python3-asyncua,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, python3-asyncua,DESCRIPTION,missing)

	# asyncua needs its $(PYTHON3_SITEPACKAGES)/*.egg-info directory!
	@$(call install_glob, python3-asyncua, 0, 0, -, \
		$(PYTHON3_SITEPACKAGES),, *.py)

	@$(call install_finish, python3-asyncua)

	@$(call touch)

# vim: syntax=make
