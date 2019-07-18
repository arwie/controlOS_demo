# -*-makefile-*-
#
# Copyright (C) 2015 by Artur Wiebe
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_MCCOM) += mccom

#
# Paths and names
#
MCCOM_VERSION	:= 1
MCCOM			:= mccom-$(MCCOM_VERSION)
MCCOM_URL		:= lndir://$(PTXDIST_WORKSPACE)/local_src/mccom
MCCOM_DIR		:= $(BUILDDIR)/$(MCCOM)
MCCOM_LICENSE	:= unknown

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

MCCOM_CONF_TOOL	:= NO
MCCOM_MAKE_ENV	:= $(CROSS_ENV) PLATFORM=$(PTXCONF_PLATFORM) TOOLCHAIN=$(PTXDIST_PLATFORMDIR)/selected_toolchain/..

# vim: syntax=make
