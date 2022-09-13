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
PACKAGES-$(PTXCONF_SOEM) += soem

#
# Paths and names
#
SOEM_VERSION		:= 42ec9bf238ae617068a3adafd4c659573bdf29ec
SOEM_MD5		:= 5cb9e8105ee4c372484f9420a9dc466e
SOEM			:= soem-$(SOEM_VERSION)
SOEM_SUFFIX		:= zip
SOEM_URL		:= https://github.com/OpenEtherCATsociety/SOEM/archive/$(SOEM_VERSION).$(SOEM_SUFFIX)
SOEM_SOURCE		:= $(SRCDIR)/$(SOEM).$(SOEM_SUFFIX)
SOEM_DIR		:= $(BUILDDIR)/$(SOEM)
SOEM_LICENSE		:= unknown
SOEM_LICENSE_FILES	:=

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#SOEM_CONF_ENV	:= $(CROSS_ENV)

#
# cmake
#
SOEM_CONF_TOOL	:= cmake
#SOEM_CONF_OPT	:=  \
#	$(CROSS_CMAKE_USR)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/soem.targetinstall:
	@$(call targetinfo)

	@$(call install_init, soem)
	@$(call install_fixup, soem,PRIORITY,optional)
	@$(call install_fixup, soem,SECTION,base)
	@$(call install_fixup, soem,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, soem,DESCRIPTION,missing)

	@$(call install_copy, soem, 0, 0, 0755, -, /usr/bin/slaveinfo)

	@$(call install_finish, soem)

	@$(call touch)

# vim: syntax=make
