# -*-makefile-*-
#
# Copyright (C) 2020 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_WEBENGINE) += webengine

#
# Paths and names
#
WEBENGINE_VERSION	:= 1.0
WEBENGINE			:= webengine-$(WEBENGINE_VERSION)
WEBENGINE_URL		:= file://local_src/webengine
WEBENGINE_DIR		:= $(BUILDDIR)/$(WEBENGINE)
WEBENGINE_BUILD_OOT	:= YES
WEBENGINE_LICENSE	:= unknown

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

#$(WEBENGINE_SOURCE):
#	@$(call targetinfo)
#	@$(call get, WEBENGINE)

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#WEBENGINE_CONF_ENV	:= $(CROSS_ENV)

#
# qmake
#
WEBENGINE_PATH		:= PATH=$(PTXDIST_SYSROOT_CROSS)/bin/qt5:$(CROSS_PATH)
WEBENGINE_CONF_TOOL	:= qmake
WEBENGINE_CONF_OPT	:= $(CROSS_QMAKE_OPT) PREFIX=/usr

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/webengine.targetinstall:
	@$(call targetinfo)
	@$(call install_init, webengine)

	@$(call install_copy, webengine, 0, 0, 0755, $(WEBENGINE_DIR)-build/webengine, /usr/sbin/webengine)

	@$(call install_finish, webengine)
	@$(call touch)

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

#$(STATEDIR)/webengine.clean:
#	@$(call targetinfo)
#	@$(call clean_pkg, WEBENGINE)

# vim: syntax=make
