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
PACKAGES-$(PTXCONF_CODESYS) += codesys

CODESYS_VERSION		:= 4.9.0.0
ifdef PTXCONF_ARCH_X86_64
CODESYS_SOURCE		:= $(SRCDIR)/codesyscontrol_linux_$(CODESYS_VERSION)_amd64.ipk
CODESYS_MD5		:= 0ce8fff286880a383551f4e97bae63d5
endif
ifdef PTXCONF_ARCH_ARM
CODESYS_SOURCE		:= $(SRCDIR)/codesyscontrol_linuxarm_$(CODESYS_VERSION)_armhf.ipk
CODESYS_MD5		:= 9c00115c7f047d439920528cd4f8cedd
endif
ifdef PTXCONF_ARCH_ARM64
CODESYS_SOURCE		:= $(SRCDIR)/codesyscontrol_linuxarm64_$(CODESYS_VERSION)_arm64.ipk
CODESYS_MD5		:= 17b73ec7a5d9d5d347049a68149afbbf
endif
CODESYS			:= codesys-$(CODESYS_VERSION)
CODESYS_DIR		:= $(BUILDDIR)/$(CODESYS)
CODESYS_LICENSE		:= unknown

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

#$(STATEDIR)/codesys.get:
#	@$(call targetinfo)
#	@$(call touch)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

$(STATEDIR)/codesys.extract:
	@$(call targetinfo)
	fakeroot opkg -o $(CODESYS_DIR) install $(CODESYS_SOURCE)
	@$(call touch)

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/codesys.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/codesys.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/codesys.targetinstall:
	@$(call targetinfo)
	@$(call install_init, codesys)
	@$(call install_fixup,codesys,PRIORITY,optional)
	@$(call install_fixup,codesys,SECTION,base)
	@$(call install_fixup,codesys,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup,codesys,DESCRIPTION,missing)

	@$(call install_tree, codesys, 0, 0, $(CODESYS_DIR)/opt, /opt)
	@$(call install_alternative, codesys, 0, 0, 0755, /opt/codesys/scripts/service-setup.py)

	@$(call install_alternative, codesys, 0, 0, 0644, /etc/CODESYSControl.cfg)
	@$(call install_alternative, codesys, 0, 0, 0644, /usr/lib/tmpfiles.d/codesys.conf)

	@$(call install_alternative_tree, codesys, 0, 0,  /usr/share/codesys)

	@$(call install_alternative, codesys, 0, 0, 0644, /usr/lib/systemd/system/codesys.service)
	@$(call install_link,        codesys, ../codesys.service, /usr/lib/systemd/system/multi-user.target.wants/codesys.service)

	@$(call install_finish,codesys)
	@$(call touch)


# vim: syntax=make
