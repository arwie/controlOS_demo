# -*-makefile-*-
#
# Copyright (C) 2020 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_BOSSAC) += bossac

#
# Paths and names
#
BOSSAC_VERSION	:= 1.9.1-3532de8
BOSSAC_MD5		:= 062581f899dcd385746861b520f47132
BOSSAC			:= bossac-$(BOSSAC_VERSION)
BOSSAC_SUFFIX	:= zip
BOSSAC_URL		:= https://github.com/shumatech/BOSSA/archive/3532de82efd28fadbabc2b258d84dddf14298107.$(BOSSAC_SUFFIX)
BOSSAC_SOURCE	:= $(SRCDIR)/$(BOSSAC).$(BOSSAC_SUFFIX)
BOSSAC_DIR		:= $(BUILDDIR)/$(BOSSAC)
BOSSAC_LICENSE	:= BSD-3-Clause

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

BOSSAC_CONF_TOOL	:= NO
BOSSAC_MAKE_ENV		:= $(CROSS_ENV)
BOSSAC_MAKE_OPT		:= bossac VERSION=$(BOSSAC_VERSION)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/bossac.install:
	@$(call targetinfo)
	@install -v -D -m755 $(BOSSAC_DIR)/bin/bossac \
		$(BOSSAC_PKGDIR)/usr/bin/bossac
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/bossac.targetinstall:
	@$(call targetinfo)
	@$(call install_init, bossac)
	@$(call install_fixup, bossac,PRIORITY,optional)
	@$(call install_fixup, bossac,SECTION,base)
	@$(call install_fixup, bossac,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, bossac,DESCRIPTION,missing)

	@$(call install_copy, bossac, 0, 0, 0755, -, /usr/bin/bossac)

	@$(call install_finish, bossac)
	@$(call touch)


# vim: syntax=make
