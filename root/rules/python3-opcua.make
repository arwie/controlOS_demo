# -*-makefile-*-
#
# Copyright (C) 2018 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_PYTHON3_OPCUA) += python3-opcua

PYTHON3_OPCUA_VERSION	:= 0.98.7
PYTHON3_OPCUA_MD5	:= beca06f61d4acd4349a118b81fc37aad
PYTHON3_OPCUA		:= opcua-$(PYTHON3_OPCUA_VERSION)
PYTHON3_OPCUA_SUFFIX	:= tar.gz
PYTHON3_OPCUA_URL	:= https://files.pythonhosted.org/packages/source/o/opcua/$(PYTHON3_OPCUA).$(PYTHON3_OPCUA_SUFFIX)
PYTHON3_OPCUA_SOURCE	:= $(SRCDIR)/$(PYTHON3_OPCUA).$(PYTHON3_OPCUA_SUFFIX)
PYTHON3_OPCUA_DIR	:= $(BUILDDIR)/$(PYTHON3_OPCUA)
PYTHON3_OPCUA_LICENSE	:= LGPL-3.0-only

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

PYTHON3_OPCUA_CONF_TOOL    := python3

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/python3-opcua.targetinstall:
	@$(call targetinfo)

	@$(call install_init, python3-opcua)
	@$(call install_fixup,python3-opcua,PRIORITY,optional)
	@$(call install_fixup,python3-opcua,SECTION,base)
	@$(call install_fixup,python3-opcua,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup,python3-opcua,DESCRIPTION,missing)

	@$(call install_glob, python3-opcua, 0, 0, -, \
		/usr/lib/python$(PYTHON3_MAJORMINOR)/site-packages/opcua,, *.py)

	@$(call install_finish,python3-opcua)

	@$(call touch)

# vim: syntax=make
