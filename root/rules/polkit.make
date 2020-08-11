# -*-makefile-*-
#
# Copyright (C) 2010 by Michael Olbrich <m.olbrich@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_POLKIT) += polkit

#
# Paths and names
#
POLKIT_VERSION	:= 0.105
POLKIT_MD5	:= 9c29e1b6c214f0bd6f1d4ee303dfaed9
POLKIT		:= polkit-$(POLKIT_VERSION)
POLKIT_SUFFIX	:= tar.gz
POLKIT_URL	:= https://www.freedesktop.org/software/polkit/releases/$(POLKIT).$(POLKIT_SUFFIX)
POLKIT_SOURCE	:= $(SRCDIR)/$(POLKIT).$(POLKIT_SUFFIX)
POLKIT_DIR	:= $(BUILDDIR)/$(POLKIT)
POLKIT_LICENSE := GPL-2.0-or-later
POLKIT_LICENSE_FILES := \
	file://COPYING;md5=155db86cdbafa7532b41f390409283eb \
	file://src/polkitd/main.c;startline=1;endline=20;md5=4a13d29c09d1ef6fa53a5c79ac2c6a28

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

POLKIT_CONF_TOOL	:= autoconf
POLKIT_CONF_OPT		:= \
	$(CROSS_AUTOCONF_USR) \
	$(GLOBAL_LARGE_FILE_OPTION) \
	--disable-ansi \
	--disable-verbose-mode \
	--disable-man-pages \
	--disable-gtk-doc \
	--disable-gtk-doc-html \
	--$(call ptx/endis, PTXCONF_POLKIT_SYSTEMD)-systemd \
	--disable-introspection \
	--disable-examples \
	--disable-nls \
	--with-gnu-ld \
	--with-systemdsystemunitdir=$(call ptx/ifdef,PTXCONF_POLKIT_SYSTEMD,/usr/lib/systemd/system) \
	--with-authfw=shadow \
	--with-os-type=ptxdist

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/polkit.targetinstall:
	@$(call targetinfo)

	@$(call install_init, polkit)
	@$(call install_fixup, polkit,PRIORITY,optional)
	@$(call install_fixup, polkit,SECTION,base)
	@$(call install_fixup, polkit,AUTHOR,"Michael Olbrich <m.olbrich@pengutronix.de>")
	@$(call install_fixup, polkit,DESCRIPTION,missing)

# dbus
	@$(call install_copy, polkit, 0, 0, 0644, -, \
		/usr/share/dbus-1/system.d/org.freedesktop.PolicyKit1.conf)
	@$(call install_copy, polkit, 0, 0, 0644, -, \
		/usr/share/dbus-1/system-services/org.freedesktop.PolicyKit1.service)

# config
	@$(call install_copy, polkit, 0, 0, 0700, /etc/polkit-1/localauthority)
	@$(call install_copy, polkit, 0, 0, 0644, -, \
		/etc/polkit-1/localauthority.conf.d/50-localauthority.conf)
	@$(call install_copy, polkit, 0, 0, 0644, -, \
		/etc/polkit-1/nullbackend.conf.d/50-nullbackend.conf)
	@$(call install_copy, polkit, 0, 0, 0644, -, \
		/usr/share/polkit-1/actions/org.freedesktop.policykit.policy)

ifdef PTXCONF_POLKIT_SYSTEMD
	@$(call install_copy, polkit, 0, 0, 0644, -, \
		/usr/lib/systemd/system/polkit.service)
endif

# libs
	@$(call install_lib, polkit, 0, 0, 0644, libpolkit-agent-1)
	@$(call install_lib, polkit, 0, 0, 0644, libpolkit-backend-1)
	@$(call install_lib, polkit, 0, 0, 0644, libpolkit-gobject-1)

	@$(call install_copy, polkit, 0, 0, 0644, -, \
		/usr/lib/polkit-1/extensions/libnullbackend.so)

# binaries
	@$(call install_copy, polkit, 0, 0, 0755, -, /usr/bin/pkaction)
	@$(call install_copy, polkit, 0, 0, 0755, -, /usr/bin/pkcheck)

	@$(call install_copy, polkit, 0, 0, 0755, -, /usr/libexec/polkitd)

# binaries with suid
	@$(call install_copy, polkit, 0, 0, 4755, -, /usr/bin/pkexec)
	@$(call install_copy, polkit, 0, 0, 4755, -, \
		/usr/libexec/polkit-agent-helper-1)

# run-time
	@$(call install_copy, polkit, 0, 0, 700, /var/lib/polkit-1)

	@$(call install_finish, polkit)

	@$(call touch)

# vim: syntax=make
