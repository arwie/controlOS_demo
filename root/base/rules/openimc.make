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
PACKAGES-$(PTXCONF_OPENIMC) += openimc

#
# Paths and names
#
OPENIMC_VERSION		:= 0.1.0
#OPENIMC_MD5		:=
OPENIMC			:= openimc-$(OPENIMC_VERSION)
OPENIMC_SUFFIX		:= 
OPENIMC_URL		:= lndir://$(PTXDIST_WORKSPACE)/local_src/openimc/
#OPENIMC_SOURCE		:= $(SRCDIR)/$(OPENIMC).$(OPENIMC_SUFFIX)
OPENIMC_DIR		:= $(BUILDDIR)/$(OPENIMC)
OPENIMC_LICENSE		:= MIT
OPENIMC_LICENSE_FILES	:=

OPENIMC_PYTHON		:= $(OPENIMC)
OPENIMC_PYTHON_DIR	:= $(OPENIMC_DIR)/python
OPENIMC_PYTHON_PKGDIR	:= $(OPENIMC_PKGDIR)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

OPENIMC_PYTHON_CONF_TOOL	:= python3

OPENIMC_CONF_TOOL	:= cargo
#OPENIMC_CONF_OPT	:= 
OPENIMC_MAKE_ENV	= $(CROSS_ENV) \
	RUSTFLAGS="-L native=$(PTXDIST_SYSROOT_TARGET)/usr/lib" \
	LIBCLANG_PATH="${PTXDIST_SYSROOT_TOOLCHAIN}/../lib" \
	CPATH="$(PTXDIST_SYSROOT_TARGET)/usr/include" \
	ETHERCAT_PATH=$(ETHERLAB_ETHERCAT_DIR) \
	PYO3_CROSS_LIB_DIR="$(PTXDIST_SYSROOT_TARGET)/usr/lib" \
	PYO3_PYTHON=python$(PYTHON3_MAJORMINOR)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/openimc.compile:
	@$(call targetinfo)

	@$(call world/compile, OPENIMC_PYTHON)
	@$(call world/compile, OPENIMC)

	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/openimc.install:
	@$(call targetinfo)

	@$(call world/install, OPENIMC_PYTHON)

	@install -v -m 0644 -D $(OPENIMC_DIR)/target/$(PTXCONF_GNU_TARGET)/release/libopenimc.so \
		$(OPENIMC_PKGDIR)/usr/lib/libopenimc.so

	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/openimc.targetinstall:
	@$(call targetinfo)
	@$(call install_init, openimc)
	@$(call install_fixup, openimc,PRIORITY,optional)
	@$(call install_fixup, openimc,SECTION,base)
	@$(call install_fixup, openimc,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, openimc,DESCRIPTION,missing)

	@$(call install_glob, openimc, 0, 0, -, \
		$(PYTHON3_SITEPACKAGES)/openimc,, *.py)

	@$(call install_link, openimc, /usr/lib/libopenimc.so, \
		$(PYTHON3_SITEPACKAGES)/openimc/openimc.so)

	@$(call install_lib, openimc, 0, 0, 0644, libopenimc)

	@$(call install_finish, openimc)
	@$(call touch)

# vim: syntax=make
