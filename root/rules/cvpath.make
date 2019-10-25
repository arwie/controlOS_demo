# -*-makefile-*-
#
# Copyright (C) 2019 by Artur Wiebe
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_CVPATH) += cvpath

#
# Paths and names
#
CVPATH_VERSION	:= 1
CVPATH			:= cvpath-$(CVPATH_VERSION)
CVPATH_URL		:= lndir://$(PTXDIST_WORKSPACE)/local_src/cvpath
CVPATH_DIR		:= $(BUILDDIR)/$(CVPATH)
CVPATH_LICENSE	:= unknown

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

CVPATH_CONF_TOOL	:= NO
CVPATH_MAKE_ENV		:= $(CROSS_ENV)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/cvpath.targetinstall:
	@$(call targetinfo)
	@$(call install_init,  cvpath)

	@$(call install_copy, cvpath, 0, 0, 0755, $(CVPATH_DIR)/cvpath, /usr/sbin/cvpath)

	@$(call install_finish, cvpath)
	@$(call touch)

# vim: syntax=make
