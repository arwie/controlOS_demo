# -*-makefile-*-
#
# Copyright (C) 2026 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_PYPYLON) += pypylon

PYPYLON_VERSION		:= 26.04.1
ifdef PTXCONF_ARCH_X86_64
PYPYLON_MD5		:= f9198b615e6761796360087d6c8d7c0a
PYPYLON			:= pypylon-26.4.1-cp39-abi3-manylinux_2_31_x86_64
endif
ifdef PTXCONF_ARCH_ARM64
PYPYLON_MD5		:= 1f93571e4603729501f7e14e85c5b622
PYPYLON			:= pypylon-26.4.1-cp39-abi3-manylinux_2_31_aarch64
endif
PYPYLON_URL		:= https://github.com/basler/pypylon/releases/download/$(PYPYLON_VERSION)/$(PYPYLON).whl
PYPYLON_SOURCE		:= $(SRCDIR)/$(PYPYLON).whl

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/pypylon.install:
	@$(call targetinfo)

	@mkdir -p $(PYPYLON_PKGDIR)/$(PYTHON3_SITEPACKAGES)
	@unzip -d $(PYPYLON_PKGDIR)/$(PYTHON3_SITEPACKAGES) $(PYPYLON_SOURCE)

	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/pypylon.targetinstall:
	@$(call targetinfo)
	@$(call install_init, pypylon)

	@$(call install_tree, pypylon, 0, 0, -, $(PYTHON3_SITEPACKAGES)/pypylon)

	@$(call install_finish, pypylon)
	@$(call touch)

# vim: syntax=make
