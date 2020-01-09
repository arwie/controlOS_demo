# -*-makefile-*-
#
# Copyright (C) 2017 by Artur Wiebe <artur@4wiebe.de>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_QEMU) += qemu

#
# Paths and names
#
QEMU_VERSION	:= 2.9.0
QEMU_MD5	:= 86c95eb3b24ffea3a84a4e3a856b4e26
QEMU		:= qemu-$(QEMU_VERSION)
QEMU_SUFFIX	:= tar.xz
QEMU_URL	:= http://download.qemu-project.org/$(QEMU).$(QEMU_SUFFIX)
QEMU_SOURCE	:= $(SRCDIR)/$(QEMU).$(QEMU_SUFFIX)
QEMU_DIR	:= $(BUILDDIR)/$(QEMU)
QEMU_LICENSE	:= unknown


# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#QEMU_MAKE_PAR	:= NO
#QEMU_CONF_ENV	:= $(CROSS_ENV)

#
# autoconf
#
QEMU_CONF_TOOL	:= autoconf
#QEMU_CONF_OPT	:= $(CROSS_AUTOCONF_USR)
QEMU_CONF_OPT	:= \
	--prefix=/usr \
	--cross-prefix=$(COMPILER_PREFIX) \
	--target-list="x86_64-softmmu" \
	--audio-drv-list= \
	--with-coroutine= \
	--without-system-pixman \
	--enable-trace-backends=nop \
	--enable-system \
	--enable-replication \
	--enable-kvm \
	--enable-libusb \
	--enable-vhost-net \
	--disable-vhost-scsi \
	--disable-vhost-vsock \
	--disable-attr \
	--disable-bsd-user \
	--disable-linux-user \
	--disable-xen \
	--disable-xen-pci-passthrough \
	--disable-xen-pv-domain-build \
	--disable-vnc \
	--disable-virtfs \
	--disable-brlapi \
	--disable-curses \
	--disable-curl \
	--disable-bluez \
	--disable-vde \
	--disable-linux-aio \
	--disable-cap-ng \
	--disable-docs \
	--disable-spice \
	--disable-rbd \
	--disable-libiscsi \
	--disable-usb-redir \
	--disable-strip \
	--disable-seccomp \
	--disable-sparse \
	--disable-tools \
	--disable-fdt \
	--disable-sdl \
	--disable-gtk \
	--disable-gcrypt \
	--disable-nettle \
	--disable-gnutls \
	--disable-user \
	--disable-qom-cast-debug \
	--disable-xfsctl \
	--disable-virglrenderer \
	--disable-opengl \
	--disable-jemalloc \
	--disable-tcmalloc \
	--disable-numa \
	--disable-libssh2 \
	--disable-tpm \
	--disable-glusterfs \
	--disable-coroutine-pool \
	--disable-bzip2 \
	--disable-snappy \
	--disable-lzo \
	--disable-smartcard \
	--disable-libnfs \
	--disable-netmap \
	--disable-rdma \
	--disable-hax \
	--disable-cocoa \
	--disable-vte \
	--disable-debug-info \
	--disable-debug-tcg \
	--disable-modules \
	--disable-pie \
	--disable-guest-agent \
	--disable-guest-agent-msi

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/qemu.targetinstall:
	@$(call targetinfo)
	@$(call install_init, qemu)
	@$(call install_fixup, qemu,PRIORITY,optional)
	@$(call install_fixup, qemu,SECTION,base)
	@$(call install_fixup, qemu,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, qemu,DESCRIPTION,missing)

	@$(call install_copy, qemu, 0, 0, 0755, -, /usr/bin/qemu-system-x86_64)
	
	@$(call install_tree, qemu, 0, 0, -, /usr/share/qemu/, no)

	@$(call install_finish, qemu)
	@$(call touch)


# vim: syntax=make
