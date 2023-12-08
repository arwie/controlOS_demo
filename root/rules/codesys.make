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

CODESYS_VERSION		:= 4.10.0.0
ifdef PTXCONF_ARCH_X86_64
CODESYS_SOURCE		:= $(SRCDIR)/codesyscontrol_linux_$(CODESYS_VERSION)_amd64.deb
CODESYS_MD5		:= 8864d9ea911ec4a20a5d9caa1b0943d8
endif
ifdef PTXCONF_ARCH_ARM
CODESYS_SOURCE		:= $(SRCDIR)/codesyscontrol_linuxarm_$(CODESYS_VERSION)_armhf.deb
CODESYS_MD5		:= 0ac68b75e5a8c4686723e4bdd7f89181
endif
ifdef PTXCONF_ARCH_ARM64
CODESYS_SOURCE		:= $(SRCDIR)/codesyscontrol_linuxarm64_$(CODESYS_VERSION)_arm64.deb
CODESYS_MD5		:= a6495614789e4631705265cfbfc484f2
endif
CODESYS			:= codesys-$(CODESYS_VERSION)
CODESYS_LICENSE		:= unknown

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

#$(STATEDIR)/codesys.get:
#	@$(call targetinfo)
#	@$(call touch)

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

	@$(call install_tree, codesys, 0, 0, -, /opt/codesys)

	@$(call install_tree, codesys, 0, 0, -, /var/opt/codesys)
	@$(call install_copy, codesys, 0, 0, 0755, /var/opt/codesys/PlcLogic)

	@$(call install_alternative, codesys, 0, 0, 0644, /etc/CODESYSControl.cfg)
	@$(call install_alternative, codesys, 0, 0, 0644, /usr/lib/tmpfiles.d/codesys.conf)

	@$(call install_alternative, codesys, 0, 0, 0755, /opt/codesys/bin/log-journal.py)
	@$(call install_alternative, codesys, 0, 0, 0644, /usr/lib/systemd/system/codesys-log.service)

	@$(call install_alternative, codesys, 0, 0, 0644, /usr/lib/systemd/system/codesys-proxy.service)
	@$(call install_alternative, codesys, 0, 0, 0644, /usr/lib/systemd/system/codesys-proxy.socket)
	@$(call install_link,        codesys, ../codesys-proxy.socket, /usr/lib/systemd/system/debug.target.wants/codesys-proxy.socket)

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
