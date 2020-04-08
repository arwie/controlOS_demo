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
QEMU_VERSION	:= 4.1.1
QEMU_MD5	:= 53879f792ef2675c6c5e6cbf5cc1ac6c
QEMU		:= qemu-$(QEMU_VERSION)
QEMU_SUFFIX	:= tar.xz
QEMU_URL	:= http://download.qemu-project.org/$(QEMU).$(QEMU_SUFFIX)
QEMU_SOURCE	:= $(SRCDIR)/$(QEMU).$(QEMU_SUFFIX)
QEMU_DIR	:= $(BUILDDIR)/$(QEMU)
QEMU_LICENSE	:= unknown
QEMU_BUILD_OOT	:= YES


# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#QEMU_MAKE_PAR	:= NO
#QEMU_CONF_ENV	:= $(CROSS_ENV)

#
# autoconf
#
QEMU_CONF_TOOL	:= autoconf
QEMU_CONF_OPT	:= \
	--prefix=/usr \
	--cross-prefix=$(COMPILER_PREFIX) \
	--target-list="x86_64-softmmu" \
	--python=python3 \
	--disable-werror \
	--audio-drv-list= \
	--block-drv-rw-whitelist= \
	--block-drv-ro-whitelist= \
	--enable-trace-backends=nop \
	--disable-tcg-interpreter \
	--with-coroutine= \
	--tls-priority=NORMAL \
	--enable-system \
	--disable-user \
	--disable-linux-user \
	--disable-bsd-user \
	--disable-docs \
	--disable-guest-agent \
	--disable-guest-agent-msi \
	--enable-pie \
	--disable-modules \
	--disable-debug-tcg \
	--disable-debug-info \
	--disable-sparse \
	--disable-gnutls \
	--disable-nettle \
	--disable-gcrypt \
	--disable-sdl \
	--disable-gtk \
	--disable-vte \
	--disable-curses \
	--disable-vnc \
	--disable-vnc-sasl \
	--disable-vnc-jpeg \
	--disable-vnc-png \
	--disable-cocoa \
	--disable-virtfs \
	--disable-mpath \
	--disable-xen \
	--disable-xen-pci-passthrough \
	--disable-brlapi \
	--disable-curl \
	--disable-fdt \
	--disable-bluez \
	--enable-kvm \
	--disable-hax \
	--disable-rdma \
	--disable-pvrdma \
	--disable-netmap \
	--disable-linux-aio \
	--disable-cap-ng \
	--disable-attr \
	--enable-vhost-net \
	--disable-vhost-vsock \
	--disable-vhost-scsi \
	--disable-vhost-crypto \
	--disable-vhost-user \
	--disable-spice \
	--disable-rbd \
	--disable-libiscsi \
	--disable-libnfs \
	--disable-smartcard \
	--disable-libusb \
	--disable-live-block-migration \
	--disable-usb-redir \
	--disable-lzo \
	--disable-snappy \
	--disable-bzip2 \
	--disable-lzfse \
	--disable-seccomp \
	--enable-coroutine-pool \
	--disable-glusterfs \
	--disable-tpm \
	--disable-libssh \
	--disable-numa \
	--disable-libxml2 \
	--disable-tcmalloc \
	--disable-jemalloc \
	--enable-replication \
	--disable-opengl \
	--disable-virglrenderer \
	--disable-xfsctl \
	--disable-qom-cast-debug \
	--disable-tools \
	--disable-dmg \
	--disable-vvfat \
	--disable-qed \
	--disable-parallels \
	--disable-sheepdog \
	--disable-crypto-afalg \
	--disable-capstone \
	--disable-debug-mutex \
	--disable-libpmem

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
