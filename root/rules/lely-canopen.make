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
PACKAGES-$(PTXCONF_LELY_CANOPEN) += lely-canopen

#
# Paths and names
#
LELY_CANOPEN_VERSION		:= 2.3.1
LELY_CANOPEN_MD5		:= a223cdae2d38b1f0c4e5c305eee158fd
LELY_CANOPEN			:= lely-canopen-$(LELY_CANOPEN_VERSION)
LELY_CANOPEN_SUFFIX		:= tar.gz
LELY_CANOPEN_URL		:= https://gitlab.com/lely_industries/lely-core/-/archive/v$(LELY_CANOPEN_VERSION)/lely-core-v$(LELY_CANOPEN_VERSION).$(LELY_CANOPEN_SUFFIX)
LELY_CANOPEN_SOURCE		:= $(SRCDIR)/$(LELY_CANOPEN).$(LELY_CANOPEN_SUFFIX)
LELY_CANOPEN_DIR		:= $(BUILDDIR)/$(LELY_CANOPEN)
LELY_CANOPEN_LICENSE		:= unknown
LELY_CANOPEN_LICENSE_FILES	:=

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#
# autoconf
#
LELY_CANOPEN_CONF_TOOL	:= autoconf
LELY_CANOPEN_CONF_OPT	:=  $(CROSS_AUTOCONF_USR) \
	--disable-tests \
	--disable-wtm \
	--disable-cython

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/lely-canopen.targetinstall:
	@$(call targetinfo)

	@$(call install_init, lely-canopen)
	@$(call install_fixup, lely-canopen,PRIORITY,optional)
	@$(call install_fixup, lely-canopen,SECTION,base)
	@$(call install_fixup, lely-canopen,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, lely-canopen,DESCRIPTION,missing)

	@$(call install_lib, lely-canopen, 0, 0, 0644, liblely-can)
	@$(call install_lib, lely-canopen, 0, 0, 0644, liblely-coapp)
	@$(call install_lib, lely-canopen, 0, 0, 0644, liblely-co)
	@$(call install_lib, lely-canopen, 0, 0, 0644, liblely-ev)
	@$(call install_lib, lely-canopen, 0, 0, 0644, liblely-io2)
	@$(call install_lib, lely-canopen, 0, 0, 0644, liblely-util)

	@$(call install_finish, lely-canopen)

	@$(call touch)

# vim: syntax=make
