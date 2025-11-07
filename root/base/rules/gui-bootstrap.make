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
GUI_BOOTSTRAP_VERSION		:= 5.3.8
GUI_BOOTSTRAP_MD5		:= 47618f513bb53f5ed4d36a2170d3c478
GUI_BOOTSTRAP			:= bootstrap-$(GUI_BOOTSTRAP_VERSION)
GUI_BOOTSTRAP_SUFFIX		:= zip
GUI_BOOTSTRAP_URL		:= https://github.com/twbs/bootstrap/releases/download/v$(GUI_BOOTSTRAP_VERSION)/$(GUI_BOOTSTRAP)-dist.$(GUI_BOOTSTRAP_SUFFIX)
GUI_BOOTSTRAP_SOURCE		:= $(SRCDIR)/$(GUI_BOOTSTRAP).$(GUI_BOOTSTRAP_SUFFIX)
GUI_BOOTSTRAP_DIR		:= $(BUILDDIR)/$(GUI_BOOTSTRAP)
GUI_BOOTSTRAP_LICENSE		:= MIT

GUI_BOOTSTRAP_VUE_VERSION	:= 0.40.6
GUI_BOOTSTRAP_VUE_MD5		:= 510a7eb50b8acfbda6148a8b7122c348
GUI_BOOTSTRAP_VUE		:= bootstrap-vue-next-$(GUI_BOOTSTRAP_VUE_VERSION)
GUI_BOOTSTRAP_VUE_SUFFIX	:= tgz
GUI_BOOTSTRAP_VUE_URL		:= https://registry.npmjs.org/bootstrap-vue-next/-/$(GUI_BOOTSTRAP_VUE).$(GUI_BOOTSTRAP_VUE_SUFFIX)
GUI_BOOTSTRAP_VUE_SOURCE	:= $(SRCDIR)/$(GUI_BOOTSTRAP_VUE).$(GUI_BOOTSTRAP_VUE_SUFFIX)
GUI_BOOTSTRAP_VUE_DIR		:= $(BUILDDIR)/$(GUI_BOOTSTRAP_VUE)
GUI_BOOTSTRAP_VUE_LICENSE	:= MIT
GUI_BOOTSTRAP_PARTS		+= GUI_BOOTSTRAP_VUE

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

	@$(call install_glob, gui-bootstrap, 0, 0, \
		$(GUI_BOOTSTRAP_VUE_DIR)/dist, \
		$(GUI_BOOTSTRAP_INSTALL)/vue, *.mjs *.css,)
	@$(call install_link, gui-bootstrap, \
		bootstrap-vue-next.mjs, \
		$(GUI_BOOTSTRAP_INSTALL)/vue/index.mjs)

	@$(call install_finish, gui-bootstrap)
	@$(call touch)

# vim: syntax=make
