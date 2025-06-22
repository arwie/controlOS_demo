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
PACKAGES-$(PTXCONF_GUI_BOOTSTRAP) += gui-bootstrap

#
# Paths and names
#
GUI_BOOTSTRAP_VERSION		:= 5.3.6
GUI_BOOTSTRAP_MD5		:= 1b9352d329303763c1fdc746518e1eed
GUI_BOOTSTRAP			:= bootstrap-$(GUI_BOOTSTRAP_VERSION)
GUI_BOOTSTRAP_SUFFIX		:= zip
GUI_BOOTSTRAP_URL		:= https://github.com/twbs/bootstrap/releases/download/v$(GUI_BOOTSTRAP_VERSION)/$(GUI_BOOTSTRAP)-dist.$(GUI_BOOTSTRAP_SUFFIX)
GUI_BOOTSTRAP_SOURCE		:= $(SRCDIR)/$(GUI_BOOTSTRAP).$(GUI_BOOTSTRAP_SUFFIX)
GUI_BOOTSTRAP_DIR		:= $(BUILDDIR)/$(GUI_BOOTSTRAP)
GUI_BOOTSTRAP_LICENSE		:= MIT

GUI_BOOTSTRAP_INSTALL		:= /usr/lib/gui/bootstrap

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-bootstrap.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-bootstrap.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-bootstrap.targetinstall:
	@$(call targetinfo)
	@$(call install_init, gui-bootstrap)
	@$(call install_fixup, gui-bootstrap,PRIORITY,optional)
	@$(call install_fixup, gui-bootstrap,SECTION,base)
	@$(call install_fixup, gui-bootstrap,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, gui-bootstrap,DESCRIPTION,missing)

	@$(call install_copy, gui-bootstrap, 0, 0, 0644, \
		$(GUI_BOOTSTRAP_DIR)/css/bootstrap.min.css, \
		$(GUI_BOOTSTRAP_INSTALL)/bootstrap.css)
	@$(call install_copy, gui-bootstrap, 0, 0, 0644, \
		$(GUI_BOOTSTRAP_DIR)/js/bootstrap.bundle.min.js, \
		$(GUI_BOOTSTRAP_INSTALL)/index.js)

	@$(call install_finish, gui-bootstrap)
	@$(call touch)

# vim: syntax=make
