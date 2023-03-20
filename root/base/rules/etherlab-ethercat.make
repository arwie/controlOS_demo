# -*-makefile-*-
#
# Copyright (C) 2022 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_ETHERLAB_ETHERCAT) += etherlab-ethercat

#
# Paths and names
#
ETHERLAB_ETHERCAT_VERSION	:= 4933150c17139e5e469197603984ca41ef9dbebe
ETHERLAB_ETHERCAT_MD5		:= 2cd4b871e9fbf7abf252206010e7019c
ETHERLAB_ETHERCAT		:= etherlab-ethercat-$(ETHERLAB_ETHERCAT_VERSION)
ETHERLAB_ETHERCAT_SUFFIX	:= tar.bz2
ETHERLAB_ETHERCAT_URL		:= https://gitlab.com/etherlab.org/ethercat/-/archive/$(ETHERLAB_ETHERCAT_VERSION)/ethercat-$(ETHERLAB_ETHERCAT_VERSION).$(ETHERLAB_ETHERCAT_SUFFIX)
ETHERLAB_ETHERCAT_SOURCE	:= $(SRCDIR)/$(ETHERLAB_ETHERCAT).$(ETHERLAB_ETHERCAT_SUFFIX)
ETHERLAB_ETHERCAT_DIR		:= $(BUILDDIR)/$(ETHERLAB_ETHERCAT)
ETHERLAB_ETHERCAT_LICENSE	:= unknown
ETHERLAB_ETHERCAT_LICENSE_FILES	:=

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#
# autoconf
#
ETHERLAB_ETHERCAT_CONF_TOOL	:= autoconf
ETHERLAB_ETHERCAT_CONF_OPT	=  \
	$(CROSS_AUTOCONF_USR) \
	--enable-tool \
	--enable-userlib \
	--with-systemdsystemunitdir=/usr/lib/systemd/system \
	--enable-kernel \
	--enable-generic \
	--disable-8139too \
	--with-linux-dir=$(KERNEL_BUILD_DIR)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/etherlab-ethercat.targetinstall:
	@$(call targetinfo)

	@$(call install_init, etherlab-ethercat)
	@$(call install_fixup, etherlab-ethercat,PRIORITY,optional)
	@$(call install_fixup, etherlab-ethercat,SECTION,base)
	@$(call install_fixup, etherlab-ethercat,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, etherlab-ethercat,DESCRIPTION,missing)

	@$(call install_lib, etherlab-ethercat, 0, 0, 0644, libethercat)
	
	@$(call install_copy, etherlab-ethercat, 0, 0, 0755, -, /usr/sbin/ethercatctl)
	@$(call install_copy, etherlab-ethercat, 0, 0, 0755, -, /usr/bin/ethercat)

	@$(call install_alternative, etherlab-ethercat, 0, 0, 0644, /etc/ethercat.conf)
	@$(call install_alternative, etherlab-ethercat, 0, 0, 0644, /etc/systemd/network/ethercat.network)
	@$(call install_alternative, etherlab-ethercat, 0, 0, 0644, /usr/lib/systemd/system/ethercat.service)
	@$(call install_alternative, etherlab-ethercat, 0, 0, 0644, /usr/lib/systemd/system/sys-subsystem-net-devices-ethercat.device)

	@$(call install_finish, etherlab-ethercat)

	@$(call touch)

# vim: syntax=make
