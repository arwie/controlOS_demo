# -*-makefile-*-
#
# Copyright (C) 2018 by Steffen Trumtrar <s.trumtrar@pengutronix.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_WPEBACKEND_FDO) += wpebackend-fdo

#
# Paths and names
#
WPEBACKEND_FDO_VERSION		:= 1.16.1
WPEBACKEND_FDO_LIBRARY_VERSION	:= 1.0
WPEBACKEND_FDO_MD5		:= a112358168e03abf4937c0cecfe1dc9d
WPEBACKEND_FDO			:= wpebackend-fdo-$(WPEBACKEND_FDO_VERSION)
WPEBACKEND_FDO_SUFFIX		:= tar.xz
WPEBACKEND_FDO_URL		:= https://wpewebkit.org/releases/$(WPEBACKEND_FDO).$(WPEBACKEND_FDO_SUFFIX)
WPEBACKEND_FDO_SOURCE		:= $(SRCDIR)/$(WPEBACKEND_FDO).$(WPEBACKEND_FDO_SUFFIX)
WPEBACKEND_FDO_DIR		:= $(BUILDDIR)/$(WPEBACKEND_FDO)
WPEBACKEND_FDO_LICENSE		:= BSD-2-Clause
WPEBACKEND_FDO_LICENSE_FILES	:= file://COPYING;md5=1f62cef2e3645e3e74eb05fd389d7a66

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#
# meson
#
WPEBACKEND_FDO_CONF_TOOL	:= meson
WPEBACKEND_FDO_CONF_OPT	:= \
	$(CROSS_MESON_USR) \
	-Dbuild_docs=false

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/wpebackend-fdo.targetinstall:
	@$(call targetinfo)

	@$(call install_init, wpebackend-fdo)
	@$(call install_fixup, wpebackend-fdo,PRIORITY,optional)
	@$(call install_fixup, wpebackend-fdo,SECTION,base)
	@$(call install_fixup, wpebackend-fdo,AUTHOR,"Steffen Trumtrar <s.trumtrar@pengutronix.de>")
	@$(call install_fixup, wpebackend-fdo,DESCRIPTION,missing)

	@$(call install_lib, wpebackend-fdo, 0, 0, 0644, \
		libWPEBackend-fdo-$(WPEBACKEND_FDO_LIBRARY_VERSION))

	@$(call install_link, wpebackend-fdo, \
		libWPEBackend-fdo-$(WPEBACKEND_FDO_LIBRARY_VERSION).so.1, \
		/usr/lib/libWPEBackend-default.so)
	@$(call install_link, wpebackend-fdo, \
		libWPEBackend-fdo-$(WPEBACKEND_FDO_LIBRARY_VERSION).so.1, \
		/usr/lib/libWPEBackend-fdo-$(WPEBACKEND_FDO_LIBRARY_VERSION).so)


	@$(call install_finish, wpebackend-fdo)

	@$(call touch)

# vim: syntax=make
