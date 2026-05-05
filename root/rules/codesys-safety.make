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
PACKAGES-$(PTXCONF_CODESYS_SAFETY) += codesys-safety

CODESYS_SAFETY_VERSION			:= 4.20.0.0
ifdef PTXCONF_ARCH_X86_64
CODESYS_SAFETY				:= codesyssafecontrol_linuxsafei386_$(CODESYS_SAFETY_VERSION)_i386
CODESYS_SAFETY_MD5			:= 43ac06e779f37ec85dd4eaaaaa269261
endif
ifdef PTXCONF_ARCH_ARM64
#CODESYS_SAFETY				:= codesyssafecontrol_linuxarm64_$(CODESYS_SAFETY_VERSION)_arm64
#CODESYS_SAFETY_MD5			:= abc
endif
CODESYS_SAFETY_URL			:= https://undefined
CODESYS_SAFETY_SOURCE			:= $(SRCDIR)/$(CODESYS_SAFETY).deb
CODESYS_SAFETY_LICENSE			:= proprietary

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

$(CODESYS_SAFETY_SOURCE):
	@$(call targetinfo)
	@cp -v --update $(PTXDIST_WORKSPACE)/../codesys/$(CODESYS_SAFETY).deb $(CODESYS_SAFETY_SOURCE)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/codesys-safety.install:
	@$(call targetinfo)
	-fakeroot dpkg --force-all --root=$(CODESYS_SAFETY_PKGDIR) --install $(CODESYS_SAFETY_SOURCE)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/codesys-safety.targetinstall:
	@$(call targetinfo)
	@$(call install_init, codesys-safety)
	@$(call install_fixup,codesys-safety,PRIORITY,optional)
	@$(call install_fixup,codesys-safety,SECTION,base)
	@$(call install_fixup,codesys-safety,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup,codesys-safety,DESCRIPTION,missing)

	@$(call install_tree, codesys-safety, 0, 0, -, /opt/codesyssafecontrol)

	# i586 libs
	@$(call install_alternative, codesys-safety, 0, 0, 0755, /opt/codesyssafecontrol/lib/ld-linux.so.2)
	@$(call install_alternative, codesys-safety, 0, 0, 0644, /opt/codesyssafecontrol/lib/libc.so.6)
	@$(call install_alternative, codesys-safety, 0, 0, 0644, /opt/codesyssafecontrol/lib/libm.so.6)
	@$(call install_alternative, codesys-safety, 0, 0, 0644, /opt/codesyssafecontrol/lib/libpthread.so.0)
	@$(call install_alternative, codesys-safety, 0, 0, 0644, /opt/codesyssafecontrol/lib/libdl.so.2)
	@$(call install_alternative, codesys-safety, 0, 0, 0644, /opt/codesyssafecontrol/lib/librt.so.1)
	@$(call install_alternative, codesys-safety, 0, 0, 0644, /opt/codesyssafecontrol/lib/libgcc_s.so.1)

#	@$(call install_tree, codesys-safety, 0, 0, -, /var/opt/codesyssafecontrol)
#	@$(call install_copy, codesys-safety, 0, 0, 0755, /var/opt/codesys/PlcLogic)

	@$(call install_alternative, codesys-safety, 0, 0, 0644, /etc/codesyssafecontrol/CODESYSSafeControl.cfg)
#	@$(call install_alternative, codesys-safety, 0, 0, 0644, /usr/lib/tmpfiles.d/codesys.conf)

	@$(call install_alternative, codesys-safety, 0, 0, 0755, /opt/codesyssafecontrol/scripts/TestTimeProvider.py)
	@$(call install_alternative, codesys-safety, 0, 0, 0644, /usr/lib/systemd/system/codesys-time-provider.service)

#	@$(call install_alternative, codesys-safety, 0, 0, 0644, /usr/lib/systemd/system/codesys-proxy.service)
#	@$(call install_alternative, codesys-safety, 0, 0, 0644, /usr/lib/systemd/system/codesys-proxy.socket)

	@$(call install_alternative, codesys-safety, 0, 0, 0644, /usr/lib/systemd/system/codesyssafecontrol.service)
	@$(call install_link,        codesys-safety, ../codesyssafecontrol.service, /usr/lib/systemd/system/multi-user.target.wants/codesyssafecontrol.service)

	@$(call install_finish,codesys-safety)
	@$(call touch)


# vim: syntax=make
