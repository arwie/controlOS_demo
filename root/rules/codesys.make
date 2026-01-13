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

CODESYS_VERSION			:= 4.15.0.0
ifdef PTXCONF_ARCH_X86_64
CODESYS				:= codesyscontrol_linux_$(CODESYS_VERSION)_amd64
CODESYS_MD5			:= 368a0b203ac95c13e1316bb5d2e2ff6a
endif
ifdef PTXCONF_ARCH_ARM64
CODESYS				:= codesyscontrol_linuxarm64_$(CODESYS_VERSION)_arm64
CODESYS_MD5			:= 91b4f8200d4d4b40dcf7aa0008a9f180
endif
CODESYS_URL			:= https://undefined
CODESYS_SOURCE			:= $(SRCDIR)/$(CODESYS).deb
CODESYS_LICENSE			:= unknown

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(CODESYS_SOURCE):
	@$(call targetinfo)
	@cp -v --update $(PTXDIST_WORKSPACE)/../codesys/$(CODESYS).deb $(CODESYS_SOURCE)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/codesys.install:
	@$(call targetinfo)
	-fakeroot dpkg --force-all --root=$(CODESYS_PKGDIR) --install $(CODESYS_SOURCE)
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

	@$(call install_copy, codesys, 0, 0, 0644, -, /etc/codesyscontrol/3S.dat)
	@$(call install_tree, codesys, 0, 0, -, /opt/codesys)

	@$(call install_tree, codesys, 0, 0, -, /var/opt/codesys)
	@$(call install_copy, codesys, 0, 0, 0755, /var/opt/codesys/PlcLogic)

	@$(call install_alternative, codesys, 0, 0, 0644, /etc/codesyscontrol/CODESYSControl.cfg)
	@$(call install_alternative, codesys, 0, 0, 0644, /usr/lib/tmpfiles.d/codesys.conf)

	@$(call install_alternative, codesys, 0, 0, 0755, /opt/codesys/bin/log-journal.py)
	@$(call install_alternative, codesys, 0, 0, 0644, /usr/lib/systemd/system/codesys-log.service)

	@$(call install_alternative, codesys, 0, 0, 0644, /usr/lib/systemd/system/codesys-proxy.service)
	@$(call install_alternative, codesys, 0, 0, 0644, /usr/lib/systemd/system/codesys-proxy.socket)

	@$(call install_alternative, codesys, 0, 0, 0644, /usr/lib/systemd/system/codesys.service)
	@$(call install_link,        codesys, ../codesys.service, /usr/lib/systemd/system/multi-user.target.wants/codesys.service)

ifdef PTXCONF_CODESYS_DEPLOY
	@$(call install_alternative_tree, codesys, 0, 0, /opt/codesys/PlcLogic)
	@$(call install_alternative, codesys, 0, 0, 0755, /opt/codesys/scripts/select-application)
else
	@$(call install_link, codesys, /var/opt/codesys/PlcLogic, /opt/codesys/PlcLogic)
endif

	@$(call install_finish,codesys)
	@$(call touch)


# vim: syntax=make
