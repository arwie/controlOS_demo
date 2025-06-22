# -*-makefile-*-
#
# Copyright (C) 2025 by Artur Wiebe <artur@4wiebe.de>
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_GUI_VUE) += gui-vue

#
# Paths and names
#
GUI_VUE_VERSION		:= 3.5.13
GUI_VUE_MD5		:= 8c27e092f203f3083d86133d7ac7ae21
GUI_VUE			:= vue-$(GUI_VUE_VERSION).js
GUI_VUE_URL		:= https://unpkg.com/vue@$(GUI_VUE_VERSION)/dist/vue.esm-browser.prod.js
GUI_VUE_SOURCE		:= $(SRCDIR)/$(GUI_VUE)
GUI_VUE_LICENSE		:= MIT

GUI_VUE_ROUTER_VERSION	:= 4.5.1
GUI_VUE_ROUTER_MD5	:= 2781220521a4fcd110b2b96ba428dae4
GUI_VUE_ROUTER		:= vue-router-$(GUI_VUE_ROUTER_VERSION).js
GUI_VUE_ROUTER_URL	:= https://unpkg.com/vue-router@$(GUI_VUE_ROUTER_VERSION)/dist/vue-router.esm-browser.prod.js
GUI_VUE_ROUTER_SOURCE	:= $(SRCDIR)/$(GUI_VUE_ROUTER)
GUI_VUE_ROUTER_LICENSE	:= MIT

GUI_VUE_PARTS		+= GUI_VUE_ROUTER
GUI_VUE_INSTALL		:= /usr/lib/gui/vue

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-vue.compile:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-vue.install:
	@$(call targetinfo)
	@$(call touch)

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

$(STATEDIR)/gui-vue.targetinstall:
	@$(call targetinfo)
	@$(call install_init, gui-vue)
	@$(call install_fixup, gui-vue,PRIORITY,optional)
	@$(call install_fixup, gui-vue,SECTION,base)
	@$(call install_fixup, gui-vue,AUTHOR,"Artur Wiebe <artur@4wiebe.de>")
	@$(call install_fixup, gui-vue,DESCRIPTION,missing)

	@$(call install_copy, gui-vue, 0, 0, 0644, \
		$(GUI_VUE_SOURCE), \
		$(GUI_VUE_INSTALL)/index.mjs)

	@$(call install_copy, gui-vue, 0, 0, 0644, \
		$(GUI_VUE_ROUTER_SOURCE), \
		$(GUI_VUE_INSTALL)/router.mjs)

	@$(call install_finish, gui-vue)
	@$(call touch)

# vim: syntax=make
