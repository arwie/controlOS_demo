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
PACKAGES-$(PTXCONF_RUCKIG) += ruckig

#
# Paths and names
#
RUCKIG_VERSION		:= 0.7.1
RUCKIG_MD5		:= 53a16b7db082cd0b01dc0df3f79a3ff5
RUCKIG			:= ruckig-$(RUCKIG_VERSION)
RUCKIG_SUFFIX		:= tar.gz
RUCKIG_URL		:= https://github.com/pantor/ruckig/archive/refs/tags/v$(RUCKIG_VERSION).$(RUCKIG_SUFFIX)
RUCKIG_SOURCE		:= $(SRCDIR)/$(RUCKIG).$(RUCKIG_SUFFIX)
RUCKIG_DIR		:= $(BUILDDIR)/$(RUCKIG)
RUCKIG_LICENSE		:= unknown
RUCKIG_LICENSE_FILES	:=

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#RUCKIG_CONF_ENV	:= $(CROSS_ENV)

#
# cmake
#
RUCKIG_CONF_TOOL	:= cmake
RUCKIG_CONF_OPT		:= \
	$(CROSS_CMAKE_USR) \
	-DBUILD_EXAMPLES:BOOL=OFF \
	-DBUILD_TESTS:BOOL=OFF

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/ruckig.targetinstall:
	@$(call targetinfo)

	@$(call install_init, ruckig)
	@$(call install_fixup, ruckig,PRIORITY,optional)
	@$(call install_fixup, ruckig,SECTION,base)
	@$(call install_fixup, ruckig,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, ruckig,DESCRIPTION,missing)

	@$(call install_lib, ruckig, 0, 0, 0644, libruckig)

	@$(call install_finish, ruckig)

	@$(call touch)

# vim: syntax=make
