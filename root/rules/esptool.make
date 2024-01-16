# -*-makefile-*-
#
# Copyright (C) 2022 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_ESPTOOL) += esptool

ESPTOOL_VERSION	:= 3.3.1
ESPTOOL_MD5	:= f5abc3bec0fad45421ffc96c6b88a27a
ESPTOOL		:= esptool-$(ESPTOOL_VERSION)
ESPTOOL_SUFFIX	:= tar.gz
ESPTOOL_URL	:= $(call ptx/mirror-pypi, esptool, $(ESPTOOL).$(ESPTOOL_SUFFIX))
ESPTOOL_SOURCE	:= $(SRCDIR)/$(ESPTOOL).$(ESPTOOL_SUFFIX)
ESPTOOL_DIR	:= $(BUILDDIR)/$(ESPTOOL)
ESPTOOL_LICENSE	:= GPL-2.0-or-later

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ESPTOOL_CONF_TOOL    := python3

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/esptool.targetinstall:
	@$(call targetinfo)

	@$(call install_init, esptool)
	@$(call install_fixup,esptool,PRIORITY,optional)
	@$(call install_fixup,esptool,SECTION,base)
	@$(call install_fixup,esptool,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup,esptool,DESCRIPTION,missing)

	@$(call install_copy, esptool, 0, 0, 0755, -, /usr/bin/esptool.py)

	@$(call install_finish,esptool)

	@$(call touch)

# vim: syntax=make
